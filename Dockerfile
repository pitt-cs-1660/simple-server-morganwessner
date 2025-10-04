FROM python:3.12 AS builder

#install uv package manager
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

#copy dependency files
COPY pyproject.toml ./

#install dependencies
RUN uv venv && \
    uv sync --no-install-project --no-editable

FROM python:3.12-slim

#set up virtual environment variables
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:${PATH}"
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

WORKDIR /app

#copy the virtual environment
COPY --from=builder /app/.venv /app/.venv
COPY cc_simple_server/ ./cc_simple_server/
COPY tests/ ./tests/

#create non-root user
RUN useradd -m appuser
RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]