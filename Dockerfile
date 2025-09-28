# Base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install system utilities for networking tests
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends iputils-ping netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . /app

# Expose app port
EXPOSE 8080

# Run the application
CMD ["python", "app.py"]

