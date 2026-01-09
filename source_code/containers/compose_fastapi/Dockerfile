# syntax=docker/dockerfile:1
FROM python:3.12-alpine

WORKDIR /code

ENV PYTHONUNBUFFERED=1

RUN apk add --no-cache gcc musl-dev linux-headers

COPY requirements.txt requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

COPY . .

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "5000"]