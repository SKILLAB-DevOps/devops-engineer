import azure.functions as func
import fastapi

app = fastapi.FastAPI()


@app.get("/docs")
async def index():
    return {
        "info": "Try /hello/name for parameterized route.",
    }


@app.get("/hello/{name}")
async def get_name(name: str):
    return {
        "name": name,
    }


async def main(req: func.HttpRequest, context: func.Context) -> func.HttpResponse:
    """Each request is redirected to the ASGI handler."""
    return await func.AsgiMiddleware(app).handle_async(req, context)
