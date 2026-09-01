# MTG parser — рабочие заметки

## 2026-09-01

- Версия парсера обновлена до 1.4.0.
- `--images-only` по-прежнему не изменяет `cards.jsonl` и Bulk-файл.
- Для загрузки изображений добавлен транспорт `curl.exe` с принудительным IPv4.
- `--image-transport auto` использует curl IPv4 как основной канал и requests как резервный.
- Добавлен параметр `--image-transport auto|curl|requests`.
- Существующие корректные JPEG не скачиваются повторно.
- Временные `.part` файлы удаляются после неудачной загрузки.
- Рабочее хранилище: `G:\CollectionServer\collections\mtg`.
- Локальный исходник: `D:\FlutterProjects\collection_catalog_tools\mtg`.
