from __future__ import annotations

import argparse
import gzip
import hashlib
import json
import logging
import os
import random
import shutil
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from typing import Any

import requests

VERSION = "1.4.0"
BULK_INDEX_URL = "https://api.scryfall.com/bulk-data"
DEFAULT_ROOT = Path("G:/CollectionServer/collections/mtg")
USER_AGENT = f"CollectionCatalog-MTG-Parser/{VERSION} (local catalog importer)"

IMAGE_CONNECT_TIMEOUT = 15
IMAGE_READ_TIMEOUT = 35
IMAGE_RETRIES = 3
IMAGE_CHUNK_SIZE = 256 * 1024
DOWNLOAD_CHUNK_SIZE = 1024 * 1024
DEFAULT_IMAGE_WORKERS = 2


def configure_console() -> None:
    if os.name != "nt":
        return
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except AttributeError:
        pass


def setup_logging(log_path: Path) -> logging.Logger:
    log_path.parent.mkdir(parents=True, exist_ok=True)
    logger = logging.getLogger("mtg_parser")
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


def create_session() -> requests.Session:
    session = requests.Session()
    session.headers.update({
        "User-Agent": USER_AGENT,
        "Accept": "application/json;q=0.9,*/*;q=0.8",
        "Connection": "keep-alive",
    })
    adapter = requests.adapters.HTTPAdapter(pool_connections=16, pool_maxsize=16, max_retries=0)
    session.mount("https://", adapter)
    session.mount("http://", adapter)
    return session


def request_json(session: requests.Session, url: str, logger: logging.Logger) -> dict[str, Any]:
    logger.info("GET: %s", url)
    response = session.get(url, timeout=60)
    response.raise_for_status()
    data = response.json()
    if not isinstance(data, dict):
        raise RuntimeError("Ответ Scryfall не является JSON-объектом.")
    return data


def find_bulk_file(bulk_index: dict[str, Any], bulk_type: str) -> dict[str, Any]:
    data = bulk_index.get("data", [])
    if not isinstance(data, list):
        raise RuntimeError("Scryfall Bulk Data имеет неожиданный формат.")
    for item in data:
        if isinstance(item, dict) and item.get("type") == bulk_type:
            return item
    raise RuntimeError(f"В Scryfall Bulk Data не найден тип: {bulk_type}")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        while chunk := file.read(4 * 1024 * 1024):
            digest.update(chunk)
    return digest.hexdigest()


def write_json_atomic(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary_name = tempfile.mkstemp(prefix=path.name + ".", suffix=".tmp", dir=path.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as file:
            json.dump(data, file, ensure_ascii=False, indent=2)
            file.write("\n")
        os.replace(temporary_name, path)
    finally:
        if os.path.exists(temporary_name):
            try:
                os.unlink(temporary_name)
            except OSError:
                pass


def download_bulk_file(session: requests.Session, url: str, destination: Path, logger: logging.Logger) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    temporary_path = destination.with_name(destination.name + ".part")
    temporary_path.unlink(missing_ok=True)
    logger.info("Скачивание Bulk-файла: %s", url)
    try:
        with session.get(url, stream=True, timeout=600) as response:
            response.raise_for_status()
            downloaded = 0
            with temporary_path.open("wb") as output:
                for chunk in response.iter_content(chunk_size=DOWNLOAD_CHUNK_SIZE):
                    if chunk:
                        output.write(chunk)
                        downloaded += len(chunk)
            if downloaded <= 0:
                raise RuntimeError("Скачанный Bulk-файл имеет нулевой размер.")
        os.replace(temporary_path, destination)
        logger.info("Bulk-файл сохранён: %s", destination)
    except Exception:
        temporary_path.unlink(missing_ok=True)
        raise


def process_cards_bulk(source_path: Path, destination_path: Path, logger: logging.Logger) -> tuple[int, int, dict[str, Any]]:
    destination_path.parent.mkdir(parents=True, exist_ok=True)
    temporary_path = destination_path.with_name(destination_path.name + ".part")
    card_count = 0
    error_count = 0
    language_counts: dict[str, int] = {}
    set_counts: dict[str, int] = {}
    cards_with_images = 0
    cards_without_images = 0
    first_card: dict[str, Any] | None = None
    try:
        with gzip.open(source_path, "rt", encoding="utf-8", errors="strict") as source:
            with temporary_path.open("w", encoding="utf-8", newline="\n") as destination:
                for line_number, line in enumerate(source, start=1):
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        card = json.loads(line)
                    except json.JSONDecodeError as exc:
                        error_count += 1
                        logger.error("Ошибка JSON в строке %d: %s", line_number, exc)
                        continue
                    if not isinstance(card, dict):
                        error_count += 1
                        logger.error("Строка %d не является JSON-объектом.", line_number)
                        continue
                    for field in ("id", "name", "set", "set_name", "collector_number"):
                        if field not in card:
                            error_count += 1
                            logger.warning("Карточка в строке %d не содержит поле: %s", line_number, field)
                    if get_card_image_urls(card):
                        cards_with_images += 1
                    else:
                        cards_without_images += 1
                    destination.write(json.dumps(card, ensure_ascii=False, separators=(",", ":")) + "\n")
                    card_count += 1
                    if first_card is None:
                        first_card = card
                    lang = card.get("lang")
                    if lang:
                        language_counts[str(lang)] = language_counts.get(str(lang), 0) + 1
                    set_code = card.get("set")
                    if set_code:
                        set_counts[str(set_code)] = set_counts.get(str(set_code), 0) + 1
        if card_count <= 0 or not temporary_path.exists() or temporary_path.stat().st_size <= 0:
            raise RuntimeError("Не удалось создать непустой cards.jsonl.")
        os.replace(temporary_path, destination_path)
    except Exception:
        temporary_path.unlink(missing_ok=True)
        raise
    return card_count, error_count, {
        "languages": dict(sorted(language_counts.items())),
        "unique_sets": len(set_counts),
        "sets": dict(sorted(set_counts.items())),
        "cards_with_images": cards_with_images,
        "cards_without_images": cards_without_images,
        "first_card_id": first_card.get("id") if first_card else None,
        "first_card_name": first_card.get("name") if first_card else None,
    }


def get_card_image_urls(card: dict[str, Any]) -> list[dict[str, str]]:
    card_id = card.get("id")
    if not card_id:
        return []
    card_id = str(card_id)
    image_uris = card.get("image_uris")
    if isinstance(image_uris, dict) and image_uris.get("normal"):
        return [{"face": "single", "url": str(image_uris["normal"]), "filename": f"{card_id}.jpg"}]
    result: list[dict[str, str]] = []
    faces = card.get("card_faces")
    if isinstance(faces, list):
        for index, face in enumerate(faces):
            if not isinstance(face, dict):
                continue
            uris = face.get("image_uris")
            if not isinstance(uris, dict) or not uris.get("normal"):
                continue
            suffix = "front" if index == 0 else "back" if index == 1 else f"face{index + 1}"
            result.append({"face": suffix, "url": str(uris["normal"]), "filename": f"{card_id}_{suffix}.jpg"})
    return result


def is_valid_image_file(path: Path) -> bool:
    if not path.exists():
        return False
    try:
        if path.stat().st_size < 1024:
            return False
        with path.open("rb") as file:
            return file.read(3) == b"\xff\xd8\xff"
    except OSError:
        return False


def curl_available() -> str | None:
    return shutil.which("curl.exe") or shutil.which("curl")


def download_image_with_curl(url: str, destination: Path, logger: logging.Logger) -> bool:
    curl = curl_available()
    if not curl:
        return False
    temporary_path = destination.with_name(destination.name + ".curl.part")
    temporary_path.unlink(missing_ok=True)
    command = [
        curl,
        "--ipv4",
        "--fail",
        "--location",
        "--silent",
        "--show-error",
        "--connect-timeout", str(IMAGE_CONNECT_TIMEOUT),
        "--max-time", str(IMAGE_READ_TIMEOUT),
        "--user-agent", USER_AGENT,
        "--output", str(temporary_path),
        url,
    ]
    try:
        completed = subprocess.run(command, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=IMAGE_READ_TIMEOUT + IMAGE_CONNECT_TIMEOUT + 5)
        if completed.returncode != 0:
            error = completed.stderr.strip() or f"curl завершился с кодом {completed.returncode}"
            logger.warning("curl не смог скачать %s: %s", destination.name, error)
            return False
        if not is_valid_image_file(temporary_path):
            logger.warning("curl получил некорректный JPEG: %s", destination.name)
            return False
        destination.parent.mkdir(parents=True, exist_ok=True)
        os.replace(temporary_path, destination)
        return True
    except Exception as exc:
        logger.warning("Ошибка curl для %s: %s", destination.name, exc)
        return False
    finally:
        temporary_path.unlink(missing_ok=True)


def download_image_with_requests(session: requests.Session, url: str, destination: Path) -> tuple[bool, str | None]:
    temporary_path = destination.with_name(destination.name + ".requests.part")
    temporary_path.unlink(missing_ok=True)
    try:
        with session.get(url, stream=True, timeout=(IMAGE_CONNECT_TIMEOUT, IMAGE_READ_TIMEOUT)) as response:
            response.raise_for_status()
            content_type = response.headers.get("Content-Type", "").lower()
            if content_type and not content_type.startswith("image/"):
                raise RuntimeError(f"Scryfall вернул не изображение: {content_type}")
            with temporary_path.open("wb") as output:
                for chunk in response.iter_content(chunk_size=IMAGE_CHUNK_SIZE):
                    if chunk:
                        output.write(chunk)
        if not is_valid_image_file(temporary_path):
            raise RuntimeError("Скачанный файл не является корректным JPEG.")
        os.replace(temporary_path, destination)
        return True, None
    except Exception as exc:
        temporary_path.unlink(missing_ok=True)
        return False, str(exc)


def download_image(session: requests.Session, url: str, destination: Path, logger: logging.Logger, transport: str) -> bool:
    destination.parent.mkdir(parents=True, exist_ok=True)
    if is_valid_image_file(destination):
        return True
    last_error: str | None = None
    for attempt in range(1, IMAGE_RETRIES + 1):
        if transport in ("auto", "curl") and curl_available():
            logger.info("Попытка %d/%d через curl IPv4: %s", attempt, IMAGE_RETRIES, destination.name)
            if download_image_with_curl(url, destination, logger):
                return True
        if transport in ("auto", "requests"):
            ok, error = download_image_with_requests(session, url, destination)
            if ok:
                return True
            last_error = error
            logger.warning("requests: ошибка изображения %s, попытка %d/%d: %s", destination.name, attempt, IMAGE_RETRIES, error)
        if attempt < IMAGE_RETRIES:
            time.sleep(0.5 * attempt + random.uniform(0.2, 0.7))
    logger.error("Не удалось скачать изображение: %s", destination)
    if last_error:
        logger.error("Последняя ошибка: %s", last_error)
    return False


def download_single_image_task(image_info: dict[str, str], images_dir: Path, logger: logging.Logger, transport: str) -> dict[str, Any]:
    filename = image_info["filename"]
    destination = images_dir / filename
    session = create_session()
    try:
        if is_valid_image_file(destination):
            return {"filename": filename, "face": image_info["face"], "success": True, "skipped": True, "downloaded": False}
        logger.info("Загрузка изображения: %s", filename)
        success = download_image(session, image_info["url"], destination, logger, transport)
        return {"filename": filename, "face": image_info["face"], "success": success, "skipped": False, "downloaded": success}
    finally:
        session.close()


def download_images_only(cards_path: Path, images_dir: Path, image_index_path: Path, logger: logging.Logger, image_limit: int | None, image_workers: int, transport: str) -> dict[str, int]:
    if not cards_path.exists():
        raise RuntimeError(f"cards.jsonl не найден: {cards_path}")
    images_dir.mkdir(parents=True, exist_ok=True)
    image_index_path.parent.mkdir(parents=True, exist_ok=True)
    image_workers = max(1, min(image_workers, 16))
    selected: list[dict[str, str]] = []
    cards_processed = cards_with_images = cards_without_images = 0
    with cards_path.open("r", encoding="utf-8") as source:
        for line_number, line in enumerate(source, start=1):
            if not line.strip():
                continue
            try:
                card = json.loads(line)
            except json.JSONDecodeError as exc:
                logger.error("Ошибка JSON в строке %d: %s", line_number, exc)
                continue
            if not isinstance(card, dict):
                continue
            cards_processed += 1
            urls = get_card_image_urls(card)
            if not urls:
                cards_without_images += 1
                continue
            cards_with_images += 1
            for info in urls:
                selected.append(info)
                if image_limit is not None and len(selected) >= image_limit:
                    break
            if image_limit is not None and len(selected) >= image_limit:
                break
    selected = selected[:image_limit] if image_limit is not None else selected
    results: list[dict[str, Any]] = []
    with ThreadPoolExecutor(max_workers=image_workers, thread_name_prefix="mtg-image") as executor:
        future_map = {executor.submit(download_single_image_task, info, images_dir, logger, transport): info for info in selected}
        for completed, future in enumerate(as_completed(future_map), start=1):
            info = future_map[future]
            try:
                result = future.result()
            except Exception as exc:
                logger.error("Критическая ошибка задачи изображения %s: %s", info.get("filename", "?"), exc)
                result = {"filename": info.get("filename", ""), "face": info.get("face", ""), "success": False, "skipped": False, "downloaded": False}
            results.append(result)
            if completed % 10 == 0 or completed == len(selected):
                logger.info("Загрузка: %d/%d", completed, len(selected))
    downloaded = sum(bool(item.get("downloaded")) for item in results)
    skipped = sum(bool(item.get("skipped")) for item in results)
    failed = sum(not item.get("success") for item in results)
    result_by_filename = {str(item.get("filename", "")): item for item in results}
    temporary_index = image_index_path.with_name(image_index_path.name + ".part")
    try:
        with temporary_index.open("w", encoding="utf-8", newline="\n") as index:
            for info in selected:
                result = result_by_filename.get(info["filename"])
                if not result:
                    continue
                success = bool(result.get("success"))
                file_value = None
                if success:
                    file_value = str((images_dir / info["filename"]).relative_to(image_index_path.parent.parent)).replace("\\", "/")
                index.write(json.dumps({"filename": info["filename"], "face": info["face"], "url": info["url"], "file": file_value, "exists": success}, ensure_ascii=False, separators=(",", ":")) + "\n")
        os.replace(temporary_index, image_index_path)
    except Exception:
        temporary_index.unlink(missing_ok=True)
        raise
    return {"cards_processed": cards_processed, "cards_with_images": cards_with_images, "images_found": len(selected), "images_downloaded": downloaded, "images_skipped": skipped, "images_failed": failed, "cards_without_images": cards_without_images}


def load_existing_state(state_file: Path) -> dict[str, Any]:
    if not state_file.exists():
        return {}
    try:
        data = json.loads(state_file.read_text(encoding="utf-8"))
        return data if isinstance(data, dict) else {}
    except Exception:
        return {}


def update_state_images(state_file: Path, statistics: dict[str, int], logger: logging.Logger) -> None:
    state = load_existing_state(state_file)
    state["parser_version"] = VERSION
    state["last_image_run_utc"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    state["images"] = statistics
    write_json_atomic(state_file, state)
    logger.info("state.json обновлён.")


def build_state(cards_bulk: dict[str, Any], source_path: Path, output_path: Path, card_count: int, error_count: int, statistics: dict[str, Any], image_statistics: dict[str, int]) -> dict[str, Any]:
    return {"parser_version": VERSION, "source": "Scryfall", "last_run_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), "cards": {"bulk_type": cards_bulk.get("type"), "bulk_id": cards_bulk.get("id"), "name": cards_bulk.get("name"), "description": cards_bulk.get("description"), "updated_at": cards_bulk.get("updated_at"), "jsonl_download_uri": cards_bulk.get("jsonl_download_uri"), "compressed_size": cards_bulk.get("compressed_size"), "source_local_size": source_path.stat().st_size, "source_sha256": sha256_file(source_path), "output_local_size": output_path.stat().st_size, "count": card_count, "errors": error_count}, "statistics": statistics, "images": image_statistics}


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="MTG / Scryfall Bulk Data parser with image downloader")
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT, help="Корень серверного каталога.")
    parser.add_argument("--keep-raw", action="store_true", help="Оставить исходный default-cards.jsonl.gz.")
    parser.add_argument("--no-images", action="store_true", help="Не скачивать изображения при полном импорте.")
    parser.add_argument("--images-only", action="store_true", help="Только изображения; Bulk и cards.jsonl не изменяются.")
    parser.add_argument("--image-limit", type=int, default=None, help="Количество изображений для теста.")
    parser.add_argument("--image-workers", type=int, default=DEFAULT_IMAGE_WORKERS, help="Количество параллельных загрузчиков изображений.")
    parser.add_argument("--image-transport", choices=("auto", "curl", "requests"), default="auto", help="Транспорт изображений. auto сначала использует curl IPv4, затем requests.")
    return parser.parse_args()


def check_storage_root(root: Path, logger: logging.Logger) -> bool:
    if not Path("G:/").exists():
        logger.error("Диск G: не найден.")
        return False
    logger.info("Диск G: найден.")
    try:
        root.mkdir(parents=True, exist_ok=True)
    except OSError as exc:
        logger.error("Не удалось открыть серверный каталог %s: %s", root, exc)
        return False
    return True


def run_images_only(args: argparse.Namespace, logger: logging.Logger) -> int:
    root = args.root
    database_dir = root / "database"
    images_dir = root / "images"
    cards_file = database_dir / "cards.jsonl"
    image_index_file = database_dir / "image_index.jsonl"
    state_file = root / "state.json"
    logger.info("============================================================")
    logger.info("РЕЖИМ: ТОЛЬКО ИЗОБРАЖЕНИЯ")
    logger.info("Версия парсера: %s", VERSION)
    logger.info("Каталог карточек: %s", cards_file)
    logger.info("Каталог изображений: %s", images_dir)
    logger.info("Параллельных загрузчиков: %d", args.image_workers)
    if args.image_limit is not None:
        logger.info("Ограничение: %d изображений", args.image_limit)
    logger.info("Транспорт изображений: %s", args.image_transport)
    if curl_available():
        logger.info("curl.exe найден: будет доступен резервный/основной IPv4-канал.")
    else:
        logger.warning("curl.exe не найден. Будет использован requests.")
    if not cards_file.exists():
        logger.error("cards.jsonl не найден.")
        return 1
    logger.info("cards.jsonl найден. Размер: %.2f MB", cards_file.stat().st_size / 1024 / 1024)
    logger.info("Bulk-файл повторно скачиваться НЕ будет.")
    logger.info("cards.jsonl повторно создаваться НЕ будет.")
    logger.info("Уже существующие корректные JPEG повторно скачиваться НЕ будут.")
    logger.info("Таймаут подключения: %d сек.", IMAGE_CONNECT_TIMEOUT)
    logger.info("Таймаут чтения: %d сек.", IMAGE_READ_TIMEOUT)
    logger.info("Количество попыток: %d", IMAGE_RETRIES)
    try:
        statistics = download_images_only(cards_file, images_dir, image_index_file, logger, args.image_limit, args.image_workers, args.image_transport)
        logger.info("СКАЧИВАНИЕ ИЗОБРАЖЕНИЙ ЗАВЕРШЕНО")
        logger.info("Карточек обработано: %d", statistics["cards_processed"])
        logger.info("Карточек с изображениями: %d", statistics["cards_with_images"])
        logger.info("Изображений найдено: %d", statistics["images_found"])
        logger.info("Новых изображений: %d", statistics["images_downloaded"])
        logger.info("Уже существовало: %d", statistics["images_skipped"])
        logger.info("Ошибок изображений: %d", statistics["images_failed"])
        logger.info("Индекс изображений: %s", image_index_file)
        update_state_images(state_file, statistics, logger)
        return 0
    except Exception as exc:
        logger.exception("Ошибка режима images-only: %s", exc)
        return 1


def run_full_import(args: argparse.Namespace, logger: logging.Logger) -> int:
    root = args.root
    database_dir = root / "database"
    raw_dir = root / "raw"
    images_dir = root / "images"
    cards_file = database_dir / "cards.jsonl"
    image_index_file = database_dir / "image_index.jsonl"
    raw_file = raw_dir / "default-cards.jsonl.gz"
    state_file = root / "state.json"
    session = create_session()
    try:
        bulk_index = request_json(session, BULK_INDEX_URL, logger)
        cards_bulk = find_bulk_file(bulk_index, "default_cards")
        uri = cards_bulk.get("jsonl_download_uri")
        if not uri:
            raise RuntimeError("Scryfall не вернул jsonl_download_uri для default_cards.")
        download_bulk_file(session, str(uri), raw_file, logger)
        with gzip.open(raw_file, "rb") as gzip_file:
            if not gzip_file.read(1024):
                raise RuntimeError("GZIP-файл не содержит данных.")
        card_count, error_count, statistics = process_cards_bulk(raw_file, cards_file, logger)
        image_statistics = {"cards_processed": 0, "cards_with_images": 0, "images_found": 0, "images_downloaded": 0, "images_skipped": 0, "images_failed": 0, "cards_without_images": 0}
        if not args.no_images:
            image_statistics = download_images_only(cards_file, images_dir, image_index_file, logger, None, args.image_workers, args.image_transport)
        state = build_state(cards_bulk, raw_file, cards_file, card_count, error_count, statistics, image_statistics)
        write_json_atomic(state_file, state)
        if not args.keep_raw:
            raw_file.unlink(missing_ok=True)
        logger.info("ИМПОРТ УСПЕШНО ЗАВЕРШЁН. Карточек: %d", card_count)
        return 0
    except requests.RequestException as exc:
        logger.exception("Ошибка HTTP/Scryfall: %s", exc)
        return 1
    except Exception as exc:
        logger.exception("Ошибка парсера: %s", exc)
        return 1
    finally:
        session.close()


def main() -> int:
    configure_console()
    args = parse_arguments()
    root = args.root
    logger = setup_logging(root / "logs" / "parser.log")
    logger.info("============================================================")
    logger.info("MTG / SCRYFALL PARSER %s", VERSION)
    logger.info("============================================================")
    logger.info("Рабочий каталог: %s", root)
    logger.info("Источник: %s", BULK_INDEX_URL)
    logger.info("Python: %s", sys.version.split()[0])
    if not check_storage_root(root, logger):
        return 1
    args.image_workers = max(1, min(args.image_workers, 16))
    if args.image_limit is not None and args.image_limit < 1:
        logger.error("image-limit должен быть >= 1.")
        return 1
    return run_images_only(args, logger) if args.images_only else run_full_import(args, logger)


if __name__ == "__main__":
    raise SystemExit(main())
