# MTG / Scryfall importer

Первый серверный импортёр Collection Catalog.

## Назначение

Загрузка полного каталога Magic: The Gathering из Scryfall Bulk Data в серверное хранилище:

`G:\CollectionServer\collections\mtg`

## Результат

```text
G:\CollectionServer\collections\mtg\
├── database\
│   ├── cards.json
│   └── sets.json
├── images\
├── logs\
│   └── scryfall_parser.log
└── state.json
```

Временные bulk-файлы хранятся в `raw\` только во время импорта и удаляются после успешного завершения, если не указан `--keep-bulk`.

## Запуск

Из каталога репозитория:

```powershell
python server\catalog_importers\mtg\scryfall_parser.py
```

С изображениями:

```powershell
python server\catalog_importers\mtg\scryfall_parser.py --images
```

Для первого теста рекомендуется запуск **без `--images`**: сначала проверяем получение и сохранение полного каталога. После успешной проверки отдельно запускаем загрузку изображений.

## Требования

Python 3.10+ и пакет `requests`.

```powershell
python -m pip install requests
```

## Правила

- основной путь — `G:\CollectionServer\collections\mtg`;
- существующие изображения не перезаписываются;
- JSON записывается атомарно через временный файл;
- полный исходный объект Scryfall сохраняется в `cards.json`, чтобы не терять поля;
- состояние последнего импорта сохраняется в `state.json`;
- лог пишется в UTF-8;
- для массовой загрузки используется Bulk Data, а не перебор карточек через API.

Scryfall рекомендует использовать bulk data для больших объёмов данных и просит не превышать 10 запросов в секунду к API. Источник: https://scryfall.com/docs/faqs/i-m-having-trouble-accessing-the-scryfall-api-or-i-m-blocked
