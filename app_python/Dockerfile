FROM python:3.12-alpine3.18 AS base
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py ./
USER root
RUN mkdir -p /data && chown -R appuser:appgroup /data
USER appuser
EXPOSE 5000
CMD ["python", "app.py"]
