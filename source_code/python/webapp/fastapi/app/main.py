#!/usr/bin/env python3
from fastapi import FastAPI

app = FastAPI()


@app.get("/")
async def read_root():
    return {"msg": "Hello world"}


@app.get("/name/{name}")
async def read_item(name: str):
    return {"msg": f"Hello {name}"}
