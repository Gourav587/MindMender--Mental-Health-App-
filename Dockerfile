FROM python:3.13-slim
ENV PYTHONUNBUFFERED=1 HF_HUB_OFFLINE=1
WORKDIR /app

# CPU-only torch: Cloud Run has no GPU, and the default build carries GPU libraries that make the image far bigger
RUN pip install --no-cache-dir torch==2.14.1 --index-url https://download.pytorch.org/whl/cpu
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Only what the server needs. Never .env, .venv or .git.
COPY models/chat ./models/chat
COPY safety.py main.py ./
COPY site ./site

CMD exec uvicorn main:app --host 0.0.0.0 --port ${PORT:-8080}
