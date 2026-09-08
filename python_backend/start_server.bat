@echo off
set PYTHONUTF8=1
echo =========================================
echo  FlexiConvert Python Backend Setup
echo =========================================
echo.
echo [1] Checking Python installation...
py --version 2>nul
if %ERRORLEVEL% neq 0 (
    echo.
    echo ERROR: Python is not installed or not in PATH.
    echo Please install Python from https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)

echo.
echo [2] Creating virtual environment (if not exists)...
if not exist venv (
    py -m venv venv
)
call venv\Scripts\activate.bat

echo.
echo [3] Installing / updating dependencies...
pip install -r requirements.txt

echo.
echo [4] Starting FastAPI server on http://localhost:8000
echo      API Docs: http://localhost:8000/docs
echo      (Press Ctrl+C to stop)
echo.
uvicorn main:app --host 0.0.0.0 --port 8000 --reload

