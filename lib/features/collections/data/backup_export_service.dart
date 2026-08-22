import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class BackupExportService {
  BackupExportService._();

  static Future<File> _write(String name, List<int> bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDirectory = Directory(p.join(directory.path, 'collection_exports'));
    await exportDirectory.create(recursive: true);
    final file = File(p.join(exportDirectory.path, name));
    if (!await file.exists()) await file.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<File> exportJson(Map<String, dynamic> snapshot) async {
    final bytes = utf8.encode(const JsonEncoder.withIndent('  ').convert(snapshot));
    final file = await _write('collection_backup_${_stamp()}.json', bytes);
    await _share(file);
    return file;
  }

  static Future<File> exportCsv(List<List<dynamic>> rows) async {
    final codec = Csv(fieldDelimiter: ';', lineDelimiter: '\n');
    final bytes = utf8.encode('\uFEFF${codec.encode(rows)}');
    final file = await _write('collection_export_${_stamp()}.csv', bytes);
    await _share(file);
    return file;
  }

  static Future<File> exportExcel(List<List<dynamic>> rows) async {
    final excel = Excel.createExcel();
    final sheetName = excel.getDefaultSheet() ?? 'Sheet1';
    final sheet = excel[sheetName];
    for (final row in rows) {
      sheet.appendRow(row.map(_cell).toList());
    }
    final bytes = excel.encode();
    if (bytes == null) throw StateError('Не удалось сформировать Excel');
    final file = await _write('collection_export_${_stamp()}.xlsx', bytes);
    await _share(file);
    return file;
  }

  static Future<File> exportPdf(List<List<dynamic>> rows, {String title = 'Collection Catalog'}) async {
    final document = pw.Document();
    final safeRows = rows.map((row) => row.map((value) => value?.toString() ?? '').toList()).toList();
    document.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(title, style: pw.Theme.of(context).header2),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(data: safeRows),
        ],
      ),
    );
    final file = await _write('collection_export_${_stamp()}.pdf', await document.save());
    await _share(file);
    return file;
  }

  static Future<File> exportZip(Map<String, dynamic> snapshot) async {
    final archive = Archive();
    final jsonBytes = utf8.encode(const JsonEncoder.withIndent('  ').convert(snapshot));
    archive.addFile(ArchiveFile('collection_backup.json', jsonBytes.length, jsonBytes));
    final readme = utf8.encode('Collection Catalog backup. Personal state is stored separately from centralized catalog structure.');
    archive.addFile(ArchiveFile('README.txt', readme.length, readme));
    final bytes = ZipEncoder().encode(archive);
    final file = await _write('collection_backup_${_stamp()}.zip', bytes);
    await _share(file);
    return file;
  }

  static Future<void> _share(File file) async {
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], title: 'Collection Catalog'));
  }

  static dynamic _cell(dynamic value) {
    if (value is int) return IntCellValue(value);
    if (value is double) return DoubleCellValue(value);
    if (value is bool) return BoolCellValue(value);
    return TextCellValue(value?.toString() ?? '');
  }

  static String _stamp() => DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
}
