from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse

from app.catalog import (
    get_categories,
    get_collection_types,
    get_collections,
    get_item_file_path,
    get_item_files,
    get_item_image_path,
    get_item_images,
    get_items,
)
from app.database import get_connection
from app.storage import check_file, resolve_download_path, resolve_image_path


app = FastAPI(title="Collection Catalog Server", version="1.0.0")


@app.get("/")
def root():
    return {"status": "ok", "service": "Collection Catalog Server", "version": "1.0.0"}


@app.get("/api/health")
def health():
    return {"status": "ok"}


@app.get("/api/health/db")
def database_health():
    try:
        with get_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT current_database(), current_user, version()")
                database, user, version = cursor.fetchone()
        return {
            "status": "ok",
            "database": database,
            "user": user,
            "postgresql": version,
        }
    except Exception as error:
        raise HTTPException(status_code=503, detail="Database unavailable") from error


@app.get("/api/collection-types")
def collection_types():
    return {"status": "ok", "items": get_collection_types()}


@app.get("/api/categories")
def categories():
    return {"status": "ok", "items": get_categories()}


@app.get("/api/collections")
def collections():
    return {"status": "ok", "items": get_collections()}


@app.get("/api/items")
def items(collection_id: int | None = None):
    return {"status": "ok", "items": get_items(collection_id)}


@app.get("/api/items/{item_id}/images")
def item_images(item_id: int):
    rows = get_item_images(item_id)
    for row in rows:
        row["url"] = f"/api/images/{row['id']}"
    return {"status": "ok", "items": rows}


@app.get("/api/images/{image_id}")
def image_file(image_id: int):
    row = get_item_image_path(image_id)
    if row is None:
        raise HTTPException(status_code=404, detail="Изображение не найдено")
    try:
        path = check_file(resolve_image_path(row["path"]))
    except (ValueError, FileNotFoundError) as error:
        raise HTTPException(status_code=404, detail="Файл изображения недоступен") from error
    return FileResponse(path, filename=path.name)


@app.get("/api/items/{item_id}/files")
def item_files(item_id: int):
    rows = get_item_files(item_id)
    for row in rows:
        row["url"] = f"/api/files/{row['id']}"
    return {"status": "ok", "items": rows}


@app.get("/api/files/{file_id}")
def download_file(file_id: int):
    row = get_item_file_path(file_id)
    if row is None:
        raise HTTPException(status_code=404, detail="Файл не найден")
    try:
        path = check_file(resolve_download_path(row["path"]))
    except (ValueError, FileNotFoundError) as error:
        raise HTTPException(status_code=404, detail="Файл недоступен") from error
    return FileResponse(path, filename=path.name)
