# Build stage
FROM python:3.12 AS builder

RUN pip install uv

WORKDIR /app

COPY pyproject.toml .

# Create virtual environment and install dependencies without sourcing
RUN uv venv /venv && uv pip install -e .

# Copy application source code (including tests)
COPY . .

# Final stage
FROM python:3.12-slim

WORKDIR /app

# Copy virtual environment and application source code, including tests
COPY --from=builder /venv /venv
COPY --from=builder /app/tests ./tests
COPY --from=builder /app .

# Create a non-root user
RUN useradd -m appuser
USER appuser

# Set PATH to prefer virtual environment binaries
ENV PATH="/venv/bin:$PATH"

EXPOSE 8000

CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]
