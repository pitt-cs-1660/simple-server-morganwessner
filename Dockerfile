
FROM python:3.12 AS builder

RUN pip install uv

WORKDIR /app

COPY pyproject.toml .

RUN uv venv /venv && \
    . /venv/bin/activate && \
    uv pip install -e .

# final stage
FROM python:3.12-slim

WORKDIR /app

COPY --from=builder /venv /venv
COPY --from=builder /app/tests ./tests

COPY . .

RUN useradd -m appuser
USER appuser

ENV PATH="/venv/bin:$PATH"

EXPOSE 8000

CMD ["uvicorn", "cc_simple_server.server:app", "--host", "0.0.0.0", "--port", "8000"]





