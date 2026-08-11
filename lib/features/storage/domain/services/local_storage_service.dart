import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Локальное файловое хранилище приложения.
class LocalStorageService {
  Future<Directory> _root() async {
    final base = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(base.path, 'collection_files'));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<String> saveFile({
    required String sourcePath,
    required String itemId,
    String? fileName,
  }) async {
    final root = await _root();
    final itemDirectory = Directory(p.join(root.path, itemId));
    if (!await itemDirectory.exists()) {
      await itemDirectory.create(recursive: true);
    }

    final source = File(sourcePath);
    final name = fileName ?? p.basename(sourcePath);
    final destination = File(p.join(itemDirectory.path, name));
    await source.copy(destination.path);
    return destination.path;
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<bool> exists(String path) => File(path).exists();
}
