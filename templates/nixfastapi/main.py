#!/usr/bin/env python


from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.middleware.gzip import GZipMiddleware

from pathlib import Path
import uvicorn
from nixfastapi import hello

# Discover the base directory relative to this file
BASE_DIR = Path(__file__).parent

app = FastAPI()
app.add_middleware(GZipMiddleware, minimum_size=1000, compresslevel=9)

app.mount("/static", StaticFiles(directory=BASE_DIR / "static"), name="static")

templates = Jinja2Templates(directory=BASE_DIR / "static" / "templates") 

@app.get("/", response_class=HTMLResponse)
async def read_index(request: Request):
    return templates.TemplateResponse(
        request=request, name="index.html", context={}
    )

@app.get("/favicon.ico")
async def favicon(request: Request):
    return FileResponse(BASE_DIR / "static" / "assets" / "favicon.ico")

if __name__ == "__main__":
    hello()
    uvicorn.run(app, host="0.0.0.0", port=8000)
