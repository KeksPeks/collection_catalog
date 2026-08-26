import 'package:dio/dio.dart';

/// Модель серверного изображения предмета.
class ServerImage {
  final int id;
  final int itemId;
  final String imageType;
  final int? width;
  final int? height;
  final int? fileSize;
  final String url;

  const ServerImage({
    required this.id,
    required this.itemId,
    required this.imageType,
    required this.width,
    required this.height,
    required this.fileSize,
    required this.url,
  });

  factory ServerImage.fromJson(Map<String, dynamic> json) {
    return ServerImage(
      id: json['id'] as int,
      itemId: json['item_id'] as int,
      imageType: (json['image_type'] as String?) ?? 'application/octet-stream',
      width: json['width'] as int?,
      height: json['height'] as int?,
      fileSize: json['file_size'] as int?,
      url: json['url'] as String,
    );
  }
}

/// Модель файла предмета, доступного через сервер.
class ServerFile {
  final int id;
  final int itemId;
  final String fileType;
  final int? fileSize;
  final String url;

  const ServerFile({
    required this.id,
    required this.itemId,
    required this.fileType,
    required this.fileSize,
    required this.url,
  });

  factory ServerFile.fromJson(Map<String, dynamic> json) {
    return ServerFile(
      id: json['id'] as int,
      itemId: json['item_id'] as int,
      fileType: (json['file_type'] as String?) ?? 'application/octet-stream',
      fileSize: json['file_size'] as int?,
      url: json['url'] as String,
    );
  }
}

/// Клиент медиа-API Collection Catalog Server.
class ServerMediaService {
  /// Адрес сервера в локальной сети пользователя.
  static const String baseUrl = 'http://192.168.0.7:8000';

  final Dio _dio;

  ServerMediaService({Dio? dio}) : _dio = dio ?? Dio();

  String absoluteUrl(String relativeUrl) {
    if (relativeUrl.startsWith('http://') || relativeUrl.startsWith('https://')) {
      return relativeUrl;
    }
    return '$baseUrl${relativeUrl.startsWith('/') ? '' : '/'}$relativeUrl';
  }

  Future<List<ServerImage>> getImages(int itemId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$baseUrl/api/items/$itemId/images',
    );
    final data = response.data;
    if (data == null || data['status'] != 'ok') {
      throw StateError('Сервер не вернул список изображений');
    }

    final rawItems = data['items'];
    if (rawItems is! List) return const [];

    return rawItems
        .whereType<Map<String, dynamic>>()
        .map(ServerImage.fromJson)
        .toList(growable: false);
  }

  Future<List<ServerFile>> getFiles(int itemId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$baseUrl/api/items/$itemId/files',
    );
    final data = response.data;
    if (data == null || data['status'] != 'ok') {
      throw StateError('Сервер не вернул список файлов');
    }

    final rawItems = data['items'];
    if (rawItems is! List) return const [];

    return rawItems
        .whereType<Map<String, dynamic>>()
        .map(ServerFile.fromJson)
        .toList(growable: false);
  }

  String imageUrl(ServerImage image) => absoluteUrl(image.url);

  String fileUrl(ServerFile file) => absoluteUrl(file.url);
}
