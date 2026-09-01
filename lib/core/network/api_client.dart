import 'package:dio/dio.dart';

/// Базовый HTTP-клиент Collection Catalog API.
///
/// Для локальной разработки сервер работает на компьютере в локальной сети.
/// Адрес можно переопределить при запуске приложения:
/// --dart-define=COLLECTION_API_BASE_URL=http://<адрес-сервера>:8000
class CollectionApiClient {
  // Сервер Collection Catalog на текущем компьютере разработчика.
  static const _defaultBaseUrl = 'http://192.168.0.7:8000';

  final Dio dio;

  CollectionApiClient({String? baseUrl})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? const String.fromEnvironment(
              'COLLECTION_API_BASE_URL',
              defaultValue: _defaultBaseUrl,
            ),
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            headers: const {
              'Accept': 'application/json',
            },
            responseType: ResponseType.json,
          ),
        );

  Future<Map<String, dynamic>> getCollections() async {
    final response = await dio.get<Map<String, dynamic>>('/api/collections');
    final data = response.data;

    if (data == null) {
      throw const FormatException('API вернул пустой ответ /api/collections');
    }

    return data;
  }
}
