/// Задача загрузки каталога.
class DownloadTask {
  final String catalogId;
  final String catalogName;
  final double progress;

  const DownloadTask({
    required this.catalogId,
    required this.catalogName,
    this.progress = 0,
  });
}
