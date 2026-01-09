#!/usr/bin/env python3
from litestar import Litestar, get


@get("/")
def hello_world() -> dict[str, str]:
    return {"hello": "world"}


app = Litestar(route_handlers=[hello_world])
