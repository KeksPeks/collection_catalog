from __future__ import annotations

import argparse
import hashlib
import json
import logging
import os
import sys
import tempfile
import time
from pathlib import Path
from typing import Any
from urllib.parse import urlparse

import requests

VERSION = "1.0.0"
BULK_INDEX_URL = "https://api.scryfall.com/bulk-data"
DEFAULT_ROOT = Path(r"G:\CollectionServer\collections\mtg")
USER_AGENT = "CollectionCatalog-MTG-Importer/1.0 (+https://github.com/KeksPeks/collection_catalog)"


def configure_console() -> None:
    """Настраивает консоль для корректного вывода Unicode в Windows PowerShell/ISE."""
    if os.name == "nt":
        try:
            sys.stdout.reconfigure(encoding="utf-8", errors="replace")
            sys.stderr.reconfigure(encoding="utf-8", errors="replace")
        except AttributeError:
            pass


def setup_logging(log_path: Path) -> logging.Logger:
    log_path.parent.mkdir(parents=True, exist_ok=True)
    logger = logging.getLogger("scryfall_parser")
    logger.setLevel(logging.INFO)
    logger.handlers.clear()

    formatter = logging.Formatter("[%(asctime)s] %(levelname)s: %(message)s", "%Y-%m-%d %H:%M:%S")

    console = logging.StreamHandler(sys.stdout)
    console.setFormatter(formatter)
    logger.addHandler(console)

    file_handler = logging.FileHandler(log_path, encoding="utf-8")
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    return logger


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def request_json(session: requests.Session, url: str, logger: logging.Logger) -> dict[str, Any]:
    response = session.get(url, timeout=60)
    response.raise_for_status()
    return response.json()


def find_bulk_file(index: dict[str, Any], bulk_type: str) -> dict[str, Any]:
    for item in index.get("data", []):
        if item.get("type") == bulk_type:
            return item
    raise RuntimeError(f"В Scryfall Bulk Data не найден тип: {bulk_type}")


def download_file(session: requests.Session, url: str, destination: Path, logger: logging.Logger) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    temp_path = destination.with_suffix(destination.suffix + ".part")
    logger.info("Скачивание: %s", url)
    with session.get(url, stream=True, timeout=120) as response:
        response.raise_for_status()
        with temp_path.open("wb") as output:
            for chunk in response.iter_content(chunk_size=1024 * 1024):
                if chunk:
                    output.write(chunk)
    temp_path.replace(destination)


def load_cards_json(path: Path, logger: logging.Logger) -> list[dict[str, Any]]:
    logger.info("Чтение bulk-файла карточек: %s", path)
    with path.open("r", encoding="utf-8") as fh:
        data = json.load(fh)
    if not isinstance(data, list):
        raise RuntimeError("Scryfall bulk-файл карточек имеет неожиданный формат")
    return data


def build_catalog(cards: list[dict[str, Any]]) -> dict[str, Any]:
    # Храним полный исходный объект Scryfall, чтобы не терять поля.
    # Дополнительно создаём компактный индекс для быстрого поиска.
    index: list[dict[str, Any]] = []
    for card in cards:
        index.append(
            {
                "id": card.get("id"),
                "name": card.get("name"),
                "set_id": card.get("set_id"),
                "set": card.get("set"),
                "set_name": card.get("set_name"),
                "collector_number": card.get("collector_number"),
                "rarity": card.get("rarity"),
                "lang": card.get("lang"),
                "released_at": card.get("released_at"),
                "image_uris": card.get("image_uris"),
            }
        )
    return {
        "schema_version": 1,
        "source": "Scryfall",
        "source_url": "https://scryfall.com/",
        "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "card_count": len(cards),
        "cards": cards,
        "index": index,
    }


def write_json_atomic(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp_name = tempfile.mkstemp(prefix=path.name + ".", suffix=".tmp", dir=path.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as fh:
            json.dump(payload, fh, ensure_ascii=False, indent=2)
            fh.write("\n")
        os.replace(temp_name, path)
    finally:
        if os.path.exists(temp_name):
            os.unlink(temp_name)


def download_images(
    session: requests.Session,
    cards: list[dict[str, Any]],
    image_dir: Path,
    logger: logging.Logger,
    delay: float,
    image_size: str,
) -> tuple[int, int]:
    image_dir.mkdir(parents=True, exist_ok=True)
    downloaded = 0
    skipped = 0
    seen: set[str] = set()

    for number, card in enumerate(cards, start=1):
        image_uris = card.get("image_uris") or {}
        url = image_uris.get(image_size) or image_uris.get("normal")
        if not url or url in seen:
            continue
        seen.add(url)

        parsed = urlparse(url)
        suffix = Path(parsed.path).suffix or ".jpg"
        card_id = str(card.get("id") or number)
        target = image_dir / f"{card_id}{suffix}"
        if target.exists() and target.stat().st_size > 0:
            skipped += 1
            continue

        try:
            download_file(session, url, target, logger)
            downloaded += 1
        except requests.RequestException as exc:
            logger.error("Ошибка изображения %s: %s", card_id, exc)
            if target.exists():
                target.unlink(missing_ok=True)
        if delay > 0:
            time.sleep(delay)

        if number % 500 == 0:
            logger.info("Изображения: обработано %d карточек, скачано %d, пропущено %d", number, downloaded, skipped)

    return downloaded, skipped


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Импорт полного каталога Magic: The Gathering из Scryfall Bulk Data")
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT, help="Корень каталога на серверном диске G:")
    parser.add_argument("--images", action="store_true", help="Скачать изображения карточек")
    parser.add_argument("--image-size", choices=["small", "normal", "large", "png", "border_crop", "art_crop"], default="normal")
    parser.add_argument("--image-delay", type=float, default=0.05, help="Пауза между запросами изображений в секундах")
    parser.add_argument("--keep-bulk", action="store_true", help="Не удалять временный bulk JSON после импорта")
    return parser.parse_args()


def main() -> int:
    configure_console()
    args = parse_args()
    root: Path = args.root
    database_dir = root / "database"
    raw_dir = root / "raw"
    image_dir = root / "images"
    log_path = root / "logs" / "scryfall_parser.log"
    state_path = root / "state.json"

    logger = setup_logging(log_path)
    logger.info("MTG / Scryfall parser %s", VERSION)
    logger.info("Путь каталога: %s", root)
    logger.info("Источник: %s", BULK_INDEX_URL)

    session = requests.Session()
    session.headers.update(
        {
            "User-Agent": USER_AGENT,
            "Accept": "application/json;q=0.9,*/*;q=0.8",
        }
    )

    try:
        index = request_json(session, BULK_INDEX_URL, logger)
        cards_bulk = find_bulk_file(index, "default_cards")
        sets_bulk = find_bulk_file(index, "sets")

        root.mkdir(parents=True, exist_ok=True)
        raw_dir.mkdir(parents=True, exist_ok=True)

        cards_raw = raw_dir / "default-cards.json"
        sets_raw = raw_dir / "sets.json"
        download_file(session, cards_bulk["download_uri"], cards_raw, logger)
        download_file(session, sets_bulk["download_uri"], sets_raw, logger)

        cards = load_cards_json(cards_raw, logger)
        catalog = build_catalog(cards)
        write_json_atomic(database_dir / "cards.json", catalog)

        sets = load_cards_json(sets_raw, logger)
        write_json_atomic(
            database_dir / "sets.json",
            {
                "schema_version": 1,
                "source": "Scryfall",
                "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                "set_count": len(sets),
                "sets": sets,
            },
        )

        state = {
            "parser_version": VERSION,
            "source": "Scryfall",
            "last_run_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "default_cards": {
                "updated_at": cards_bulk.get("updated_at"),
                "size": cards_bulk.get("size"),
                "sha256": sha256_file(cards_raw),
                "card_count": len(cards),
            },
            "sets": {
                "updated_at": sets_bulk.get("updated_at"),
                "size": sets_bulk.get("size"),
                "sha256": sha256_file(sets_raw),
                "set_count": len(sets),
            },
        }
        write_json_atomic(state_path, state)

        if args.images:
            downloaded, skipped = download_images(
                session, cards, image_dir, logger, max(0.0, args.image_delay), args.image_size
            )
            state["images"] = {"downloaded": downloaded, "skipped": skipped, "size": args.image_size}
            write_json_atomic(state_path, state)

        if not args.keep_bulk:
            cards_raw.unlink(missing_ok=True)
            sets_raw.unlink(missing_ok=True)

        logger.info("Готово. Карточек: %d; наборов: %d", len(cards), len(sets))
        return 0
    except Exception as exc:
        logger.exception("Импорт завершён с ошибкой: %s", exc)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
