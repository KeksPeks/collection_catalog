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
  static Future<File> _write(String name,List<int> bytes)async{final dir=await getApplicationDocumentsDirectory();final folder=Directory(p.join(dir.path,'collection_exports'));await folder.create(recursive:true);final file=File(p.join(folder.path,name));if(!await file.exists())await file.create(recursive:true);await file.writeAsBytes(bytes,flush:true);return file;}
  static Future<File> exportJson(Map<String,dynamic> snapshot)async{final file=await _write('collection_backup_${_stamp()}.json',utf8.encode(const JsonEncoder.withIndent('  ').convert(snapshot)));await _share(file);return file;}
  static Future<File> exportCsv(List<List<dynamic>> rows)async{final csv=ListToCsvConverter(fieldDelimiter:';',eol:'\n').convert(rows);final file=await _write('collection_export_${_stamp()}.csv',utf8.encode('\uFEFF$csv'));await _share(file);return file;}
  static Future<File> exportExcel(List<List<dynamic>> rows)async{final excel=Excel.createExcel();final sheet=excel[excel.getDefaultSheet()??'Sheet1'];for(final row in rows){sheet.appendRow(row.map((v)=>v is int?IntCellValue(v):v is double?DoubleCellValue(v):TextCellValue(v?.toString()??'')).toList());}final bytes=excel.encode();if(bytes==null)throw StateError('Не удалось сформировать Excel');final file=await _write('collection_export_${_stamp()}.xlsx',bytes);await _share(file);return file;}
  static Future<File> exportPdf(List<List<dynamic>> rows,{String title='Collection Catalog'})async{final document=pw.Document();document.addPage(pw.MultiPage(build:(context)=>[pw.Text(title),pw.SizedBox(height:12),pw.TableHelper.fromTextArray(data:rows.map((r)=>r.map((v)=>v?.toString()??'').toList()).toList())]));final file=await _write('collection_export_${_stamp()}.pdf',await document.save());await _share(file);return file;}
  static Future<File> exportZip(Map<String,dynamic> snapshot)async{final archive=Archive();final jsonBytes=utf8.encode(const JsonEncoder.withIndent('  ').convert(snapshot));archive.addFile(ArchiveFile('collection_backup.json',jsonBytes.length,jsonBytes));final readme=utf8.encode('Collection Catalog backup. Personal state is separated from centralized catalog structure.');archive.addFile(ArchiveFile('README.txt',readme.length,readme));final bytes=ZipEncoder().encode(archive);final file=await _write('collection_backup_${_stamp()}.zip',bytes);await _share(file);return file;}
  static Future<void> _share(File file)async{await SharePlus.instance.share(ShareParams(files:[XFile(file.path)],title:'Collection Catalog'));}
  static String _stamp()=>DateTime.now().toIso8601String().replaceAll(':','-').replaceAll('.','-');
}
