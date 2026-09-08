# -*- coding: utf-8 -*-
import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')
"""
FlexiConvert Python Backend
FastAPI server replacing the Node.js backend.

Routes:
  GET  /health                         → Health check
  GET  /api/v1/keys/cloudconvert       → Rotating CloudConvert API key
  POST /api/v1/uploads                 → Upload file for QR codes
  GET  /api/v1/uploads/files/{filename}→ Serve an uploaded file
  POST /api/v1/jobs/upload             → Submit a document/PDF conversion job
  GET  /api/v1/jobs/{job_id}/status    → Poll conversion job status
  GET  /api/v1/jobs/{job_id}/download  → Download completed job output
  DELETE /api/v1/jobs/{job_id}         → Delete a job
"""

import os
import uuid
import json
import asyncio
import shutil
import tempfile
from pathlib import Path
from datetime import datetime, timezone
from typing import Optional

from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI, File, UploadFile, Form, HTTPException, BackgroundTasks, Request
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import aiofiles
import httpx

# ── Firebase Admin ────────────────────────────────────────────────────────────
import firebase_admin
from firebase_admin import credentials, firestore

def _init_firebase():
    if firebase_admin._apps:
        return  # already initialised
    try:
        cred = credentials.Certificate({
            "type": "service_account",
            "project_id": os.getenv("FIREBASE_PROJECT_ID"),
            "private_key_email": os.getenv("FIREBASE_CLIENT_EMAIL"),
            "private_key": os.getenv("FIREBASE_PRIVATE_KEY", "").replace("\\n", "\n"),
            "client_email": os.getenv("FIREBASE_CLIENT_EMAIL"),
            "token_uri": "https://oauth2.googleapis.com/token",
        })
        firebase_admin.initialize_app(cred)
        print("[OK] Firebase Admin initialised")
    except Exception as e:
        print(f"[WARN] Firebase init failed (API key rotation won't track): {e}")

_init_firebase()

# ── Directories ───────────────────────────────────────────────────────────────
BASE_DIR   = Path(__file__).parent
UPLOADS_DIR = BASE_DIR / "uploads"
OUTPUTS_DIR = BASE_DIR / "outputs"
UPLOADS_DIR.mkdir(exist_ok=True)
OUTPUTS_DIR.mkdir(exist_ok=True)

# In-memory job store  {job_id: {...}}
_jobs: dict[str, dict] = {}

# ── App ───────────────────────────────────────────────────────────────────────
app = FastAPI(
    title="FlexiConvert API",
    version="2.0.0",
    description="Python backend for FlexiConvert – replaces the Node.js server",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Serve uploaded files as static assets
app.mount("/api/v1/uploads/files", StaticFiles(directory=UPLOADS_DIR), name="uploads")


# ══════════════════════════════════════════════════════════════════════════════
# HEALTH
# ══════════════════════════════════════════════════════════════════════════════

@app.get("/health", tags=["Health"])
async def health():
    return {"status": "ok", "timestamp": datetime.now(timezone.utc).isoformat()}


# ══════════════════════════════════════════════════════════════════════════════
# API KEY ROTATION  –  /api/v1/keys/cloudconvert
# ══════════════════════════════════════════════════════════════════════════════

@app.get("/api/v1/keys/cloudconvert", tags=["API Keys"])
async def get_cloudconvert_key():
    """
    Returns a rotating CloudConvert API key.
    Tracks usage in Firestore so we never exceed the free limit per key.
    Falls back to returning the first available key if Firebase is unavailable.
    """
    keys = [
        os.getenv(f"CLOUDCONVERT_API_KEY_{i}")
        for i in range(1, 6)
    ]
    keys = [k for k in keys if k]  # remove empty

    if not keys:
        raise HTTPException(status_code=500, detail="No CloudConvert API keys configured")

    limit_per_key  = int(os.getenv("CONVERSIONS_PER_KEY", "10"))
    max_conversions = len(keys) * limit_per_key

    # ── Try Firestore tracking ──────────────────────────────────────────────
    try:
        db = firestore.client()
        stats_ref = db.collection("conversion_stats").document("global")

        @firestore.transactional
        def _increment(transaction):
            snap = stats_ref.get(transaction=transaction)
            count = (snap.to_dict() or {}).get("totalConversions", 0) + 1
            transaction.set(stats_ref, {"totalConversions": count}, merge=True)
            return count

        transaction = db.transaction()
        current_count = _increment(transaction)

        if current_count > max_conversions:
            raise HTTPException(status_code=429, detail="Daily limit reached. Try again tomorrow.")

        key_index    = (current_count - 1) // limit_per_key
        selected_key = keys[min(key_index, len(keys) - 1)]

        return {
            "success": True,
            "apiKey": selected_key,
            "currentCount": current_count,
            "maxConversions": max_conversions,
        }

    except HTTPException:
        raise
    except Exception as e:
        # Firebase unavailable -> return first key without tracking
        print(f"[WARN] Firestore unavailable, returning first key: {e}")
        return {"success": True, "apiKey": keys[0], "currentCount": -1, "maxConversions": max_conversions}


# ══════════════════════════════════════════════════════════════════════════════
# FILE UPLOADS  –  /api/v1/uploads
# Used by: QR Generator (image, audio, PDF, Excel upload)
# ══════════════════════════════════════════════════════════════════════════════

@app.post("/api/v1/uploads", tags=["Uploads"])
async def upload_file(request: Request, file: UploadFile = File(...)):
    """
    Accepts a file upload, saves it to the uploads folder, and returns
    a public URL the Flutter app can embed in a QR code.
    Max size: 100 MB.
    """
    MAX_SIZE = 100 * 1024 * 1024  # 100 MB

    content = await file.read()
    if len(content) > MAX_SIZE:
        raise HTTPException(status_code=413, detail="File too large. Max 100 MB.")

    safe_name = file.filename.replace(" ", "_") if file.filename else "file"
    filename  = f"{uuid.uuid4().hex}-{safe_name}"
    dest      = UPLOADS_DIR / filename

    async with aiofiles.open(dest, "wb") as f:
        await f.write(content)

    base_url = str(request.base_url).rstrip("/")
    file_url = f"{base_url}/api/v1/uploads/files/{filename}"

    return {"success": True, "url": file_url}


# ══════════════════════════════════════════════════════════════════════════════
# DOCUMENT / PDF CONVERSION JOBS
# Replaces the Node.js BullMQ job queue with async background tasks.
#
# Supported toolTypes:
#   pdf_to_docx  | pdf_to_xlsx  | pdf_to_pptx
#   docx_to_pdf  | xlsx_to_pdf  | pptx_to_pdf
#   pdf_ocr      (makes a scanned PDF searchable)
# ══════════════════════════════════════════════════════════════════════════════

@app.post("/api/v1/jobs/upload", tags=["Jobs"])
async def create_job(
    background_tasks: BackgroundTasks,
    tool_type: str = Form(...),
    device_name: Optional[str] = Form(None),
    params: Optional[str] = Form(None),
    files: list[UploadFile] = File(...),
):
    """
    Upload one or more files and start a conversion job.
    Returns a job_id immediately; poll /status for progress.
    """
    if not files:
        raise HTTPException(status_code=400, detail="No files uploaded")

    parsed_params = json.loads(params) if params else {}
    job_id        = uuid.uuid4().hex

    # Save input files
    input_paths: list[str] = []
    for upload in files:
        ext      = Path(upload.filename or "file").suffix or ".bin"
        filename = f"{uuid.uuid4().hex}{ext}"
        dest     = UPLOADS_DIR / filename
        async with aiofiles.open(dest, "wb") as f:
            await f.write(await upload.read())
        input_paths.append(str(dest))

    _jobs[job_id] = {
        "id":          job_id,
        "toolType":    tool_type,
        "deviceName":  device_name,
        "inputFiles":  input_paths,
        "params":      parsed_params,
        "status":      "pending",
        "progress":    0,
        "outputFiles": [],
        "error":       None,
        "createdAt":   datetime.now(timezone.utc).isoformat(),
    }

    background_tasks.add_task(_run_conversion, job_id)
    return {"success": True, "job": _jobs[job_id]}


@app.get("/api/v1/jobs/{job_id}/status", tags=["Jobs"])
async def get_job_status(job_id: str):
    job = _jobs.get(job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    return {"success": True, "job": job}


@app.get("/api/v1/jobs/{job_id}/download", tags=["Jobs"])
async def download_job(job_id: str):
    job = _jobs.get(job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    if job["status"] != "completed" or not job["outputFiles"]:
        raise HTTPException(status_code=400, detail="Job not completed or no output")

    output_path = job["outputFiles"][0]
    if not os.path.exists(output_path):
        raise HTTPException(status_code=404, detail="Output file missing on server")

    return FileResponse(
        output_path,
        filename=Path(output_path).name,
        media_type="application/octet-stream",
    )


@app.delete("/api/v1/jobs/{job_id}", tags=["Jobs"])
async def delete_job(job_id: str):
    job = _jobs.pop(job_id, None)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    # Clean up files
    for p in job.get("inputFiles", []) + job.get("outputFiles", []):
        try:
            os.remove(p)
        except Exception:
            pass

    return {"success": True, "message": "Job deleted"}


# ══════════════════════════════════════════════════════════════════════════════
# BACKGROUND CONVERSION WORKER
# ══════════════════════════════════════════════════════════════════════════════

async def _run_conversion(job_id: str):
    """Background task that actually converts the document."""
    job = _jobs.get(job_id)
    if not job:
        return

    def _update(status: str, progress: float = 0, output: str | None = None, error: str | None = None):
        job["status"]   = status
        job["progress"] = progress
        if output:
            job["outputFiles"].append(output)
        if error:
            job["error"] = error

    try:
        _update("processing", 0.1)
        tool    = job["toolType"]
        inp     = job["inputFiles"][0]
        out_dir = OUTPUTS_DIR / job_id
        out_dir.mkdir(parents=True, exist_ok=True)

        output_path = await asyncio.get_event_loop().run_in_executor(
            None, _convert_sync, tool, inp, str(out_dir), job["params"]
        )

        _update("completed", 1.0, output=output_path)
        print(f"[OK] Job {job_id} completed -> {output_path}")

    except Exception as e:
        _update("failed", error=str(e))
        print(f"[FAIL] Job {job_id} failed: {e}")


def _apply_ocr(input_path: str, out_dir: str, name: str) -> str:
    import pytesseract
    from PIL import Image
    from reportlab.pdfgen import canvas as rl_canvas
    from reportlab.lib.pagesizes import A4
    import fitz
    import tempfile
    import os

    doc     = fitz.open(input_path)
    out     = f"{out_dir}/{name}_ocr.pdf"
    c       = rl_canvas.Canvas(out, pagesize=A4)
    w, h    = A4

    for page in doc:
        pix  = page.get_pixmap(dpi=200)
        tmp  = tempfile.NamedTemporaryFile(suffix=".png", delete=False)
        pix.save(tmp.name)

        img      = Image.open(tmp.name)
        ocr_data = pytesseract.image_to_data(img, output_type=pytesseract.Output.DICT)
        c.drawImage(tmp.name, 0, 0, width=w, height=h)

        for i, word in enumerate(ocr_data["text"]):
            if not word.strip():
                continue
            x   = ocr_data["left"][i]   / img.width  * w
            y_t = ocr_data["top"][i]    / img.height * h
            c.setFillColorRGB(1, 1, 1, 0)
            c.setFont("Helvetica", max(6, int(ocr_data["height"][i] / img.height * h)))
            c.drawString(x, h - y_t, word)

        os.unlink(tmp.name)
        c.showPage()

    c.save()
    return out


def _convert_sync(tool_type: str, input_path: str, out_dir: str, params: dict) -> str:
    """
    Synchronous conversion logic (runs in executor thread).
    Uses pdf2docx, python-docx, openpyxl, python-pptx, and LibreOffice (subprocess).
    """
    inp  = Path(input_path)
    name = inp.stem

    # If OCR is requested for PDF to Office, do it first
    use_ocr = params.get("useOcr") == True
    if use_ocr and tool_type in ("pdf_to_docx", "pdf_to_xlsx", "pdf_to_pptx"):
        input_path = _apply_ocr(input_path, out_dir, name)
        inp = Path(input_path)

    # ── PDF OCR (standalone tool) ────────────────────────────────────────────
    if tool_type == "pdf_ocr":
        return _apply_ocr(input_path, out_dir, name)

    # ── PDF → Word (.docx) ──────────────────────────────────────────────────
    if tool_type == "pdf_to_docx":
        from pdf2docx import Converter
        out = f"{out_dir}/{name}.docx"
        cv  = Converter(input_path)
        cv.convert(out, start=0, end=None)
        cv.close()
        return out

    # ── PDF → Excel (.xlsx) ─────────────────────────────────────────────────
    if tool_type == "pdf_to_xlsx":
        # Extract text with pdfminer and put into xlsx
        from pdfminer.high_level import extract_text
        import openpyxl
        text = extract_text(input_path)
        wb   = openpyxl.Workbook()
        ws   = wb.active
        ws.title = "Extracted Text"
        for i, line in enumerate(text.splitlines(), start=1):
            ws.cell(row=i, column=1, value=line)
        out = f"{out_dir}/{name}.xlsx"
        wb.save(out)
        return out

    # ── PDF → PowerPoint (.pptx) ────────────────────────────────────────────
    if tool_type == "pdf_to_pptx":
        # Extract text, one slide per page paragraph group
        from pdfminer.high_level import extract_text_to_fp
        from pdfminer.layout import LAParams
        from io import StringIO
        from pptx import Presentation
        from pptx.util import Inches, Pt

        buf = StringIO()
        with open(input_path, "rb") as f:
            extract_text_to_fp(f, buf, laparams=LAParams())
        text   = buf.getvalue()
        chunks = [c.strip() for c in text.split("\n\n") if c.strip()]

        prs = Presentation()
        blank_layout = prs.slide_layouts[6]
        for chunk in chunks[:50]:  # max 50 slides
            slide   = prs.slides.add_slide(blank_layout)
            txBox   = slide.shapes.add_textbox(Inches(0.5), Inches(0.5), Inches(9), Inches(6.5))
            tf      = txBox.text_frame
            tf.word_wrap = True
            tf.text = chunk[:500]

        out = f"{out_dir}/{name}.pptx"
        prs.save(out)
        return out

    # ── Word/Excel/PPT → PDF  (uses LibreOffice headless) ───────────────────
    if tool_type in ("docx_to_pdf", "xlsx_to_pdf", "pptx_to_pdf"):
        import subprocess
        result = subprocess.run(
            ["libreoffice", "--headless", "--convert-to", "pdf",
             "--outdir", out_dir, input_path],
            capture_output=True, text=True, timeout=120,
        )
        if result.returncode != 0:
            raise RuntimeError(f"LibreOffice error: {result.stderr}")
        out = f"{out_dir}/{name}.pdf"
        return out



    raise ValueError(f"Unsupported tool_type: '{tool_type}'")
