# Use an official Python runtime as a parent image
FROM python:3.10-slim

# Set environment variables to prevent Python from writing .pyc files and buffering stdout
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PORT=10000

# Install system dependencies:
# - ffmpeg for media conversions
# - tesseract-ocr for PDF text extraction
# - libreoffice for document conversions
# - libgl1-mesa-glx for OpenCV (used by pytesseract/PIL if needed)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    tesseract-ocr \
    libreoffice \
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Copy requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose the port (Render sets $PORT automatically)
EXPOSE $PORT

# Start the FastAPI server using Uvicorn
CMD uvicorn main:app --host 0.0.0.0 --port $PORT
