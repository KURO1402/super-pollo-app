import 'package:dio/dio.dart';
import 'package:super_pollo_app/utils/token_storage.dart';

class DioClient {
  static final Dio dio = _crearDio();

  static Dio _crearDio() {
    final dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:3001/api',
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    return dio;
  }
}

class WebhookSiteClient {
  static final Dio dio = Dio(BaseOptions(
      baseUrl: 'https://webhook.site/d5116ffb-91cb-4221-8d23-e231d6ccee6c',
      headers: {'Content-Type': 'application/json'}));
}