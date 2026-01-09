import time
import redis
from fastapi import FastAPI
from starlette.responses import PlainTextResponse

app = FastAPI()
cache = redis.Redis(host="redis", port=6379)


def get_hit_count():
    retries = 5
    while True:
        try:
            return cache.incr("hits")
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                raise exc
            retries -= 1
            time.sleep(0.5)


@app.get("/", response_class=PlainTextResponse)
def hello():
    count = get_hit_count()
    return f"Hello World! I have been seen {count} times.\n"
