# Estágio 1 — dependências
FROM python:3.11-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Estágio 2 — imagem final
FROM python:3.11-slim

WORKDIR /app

# Copia apenas o necessário do estágio anterior
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/uvicorn /usr/local/bin/uvicorn

COPY main.py .

# Usuário não-root por segurança
RUN useradd -m -u 1000 bancox
USER bancox

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]