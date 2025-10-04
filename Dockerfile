FROM python:3.12-slim AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

#set working directory
WORKDIR /app

#install uv
RUN pip install uv

COPY pyproject.toml ./
RUN uv sync --no-install-project --no-editable

COPY . ./

#RUN uv sync --no-editable --no-dev --locked

FROM python:3.12-slim

#set working directory
WORKDIR /app

COPY --from=builder --chown=appuser:appuser /app/.venv /app/.venv
COPY --from=builder --chown=appuser:appuser /app /app

RUN useradd -m appuser
USER appuser

ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

EXPOSE 8000

CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]