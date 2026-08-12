import 'package:dio/dio.dart';

/// Унифицированный клиент удалённого каталога.
class CatalogApiClient {
  final Dio dio;

  CatalogApiClient({Dio? dio}) : dio = dio ?? Dio();

  Future<dynamic> getJson(String url) async {
    final response = await dio.get<dynamic>(url);
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw DioException.badResponse(
        statusCode: status,
        requestOptions: response.requestOptions,
        response: response,
      );
    }
    return response.data;
  }
}

/// Минимальная проверка серверного каталога.
class CatalogSyncService {
  final CatalogApiClient client;

  const CatalogSyncService(this.client);

  Future<dynamic> load(String url) => client.getJson(url);
}
