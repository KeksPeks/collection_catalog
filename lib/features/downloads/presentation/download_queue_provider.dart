import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/download_task.dart';

/// Очередь загрузки каталогов.
///
/// Пока источник каталогов локальный, загрузка выполняется быстро. Провайдер
/// уже отделён от UI, поэтому позже сюда можно подключить HTTP-загрузчик.
class DownloadQueueNotifier extends Notifier<List<DownloadTask>> {
  @override
  List<DownloadTask> build() => const [];

  void add(String catalogId, String catalogName) {
    if (state.any((task) => task.catalogId == catalogId)) return;
    state = [
      ...state,
      DownloadTask(
        catalogId: catalogId,
        catalogName: catalogName,
      ),
    ];
  }

  void remove(String catalogId) {
    state = state
        .where((task) => task.catalogId != catalogId)
        .toList(growable: false);
  }
}

final downloadQueueProvider =
    NotifierProvider<DownloadQueueNotifier, List<DownloadTask>>(
  DownloadQueueNotifier.new,
);
