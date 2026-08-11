import 'dart:convert';
import 'dart:io';

/// Сервис записи и чтения JSON-файлов резервной копии.
class BackupFileService {
  Future<void> writeJson({
    required File file,
    required Map<String, dynamic> data,
  }) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
  }

  Future<Map<String, dynamic>> readJson(File file) async {
    final content = await file.readAsString();
    final decoded = jsonDecode(content);

    if (decoded is! Map) {
      throw const FormatException('Некорректный формат резервной копии');
    }

    return Map<String, dynamic>.from(decoded);
  }
}
