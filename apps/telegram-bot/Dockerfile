FROM python:3.12-alpine

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=nobody:nobody bot.py .

# Run as non-root user
USER nobody

CMD ["python", "bot.py"]
