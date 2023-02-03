# celery -A back beat --loglevel=info &
# celery -A back worker --loglevel=info &
uvicorn server.asgi:application --reload --port 8000 --host 0.0.0.0