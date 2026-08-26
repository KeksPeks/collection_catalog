from pathlib import Path

SERVER_ROOT = Path(r"G:\CollectionServer").resolve()
IMAGES_ROOT = (SERVER_ROOT / "images").resolve()
DOWNLOADS_ROOT = (SERVER_ROOT / "downloads").resolve()


def _safe_path(root: Path, stored_path: str) -> Path:
    if not stored_path:
        raise ValueError("Пустой путь к файлу")

    raw = Path(stored_path)
    if raw.is_absolute():
        raise ValueError("Абсолютные пути запрещены")

    candidate = (root / raw).resolve()
    try:
        candidate.relative_to(root)
    except ValueError as error:
        raise ValueError("Путь выходит за пределы разрешённого хранилища") from error

    return candidate


def resolve_image_path(stored_path: str) -> Path:
    return _safe_path(IMAGES_ROOT, stored_path)


def resolve_download_path(stored_path: str) -> Path:
    return _safe_path(DOWNLOADS_ROOT, stored_path)


def check_file(path: Path) -> Path:
    if not path.exists():
        raise FileNotFoundError("Файл не найден")
    if not path.is_file():
        raise ValueError("Объект не является файлом")
    return path
