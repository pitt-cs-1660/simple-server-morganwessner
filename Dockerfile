FROM python:3.12 AS builder

# Install uv (modern fast package manager for Python)
RUN pip install uv

# Set working directory
WORKDIR /app

# Copy dependency file(s)
COPY pyproject.toml ./

# Create a virtual environment and install dependencies inside it
RUN uv venv .venv && \
    .venv/bin/uv pip install -e . --no-cache-dir


FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy the virtual environment from builder
COPY --from=builder /app/.venv /app/.venv

# Copy source code
COPY . .

# Create a non-root user for security
RUN useradd -m appuser
USER appuser

# Expose FastAPI default port
EXPOSE 8000

CMD ["/app/.venv/bin/python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
