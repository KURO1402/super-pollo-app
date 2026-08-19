import 'package:dio/dio.dart';
import 'package:super_pollo_app/utils/token_storage.dart';
import 'package:super_pollo_app/main.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

const String _baseUrl = 'https://superpollohyo.com/api';
const String _apiKey = String.fromEnvironment(
  'API_KEY',
  defaultValue: 'superpollo_movil_k3y_2026_xZ9mQ',
);

Future<void> _cerrarSesionYRedirigir() async {
  await TokenStorage.clearTokens();
  final context = navigatorKey.currentContext;
  if (context != null && context.mounted) {
    context.go('/');
  }
}

class DioClient {
  static final Dio dio = _crearDio();

  static Dio _crearDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {'Content-Type': 'application/json', 'x-api-key': _apiKey},
      ),
    );
    
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
        ),
      );
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        onError: (DioException error, handler) async {
          final statusCode = error.response?.statusCode;

          // Solo intentar renovar si es 401 (accessToken expirado)
          if (statusCode == 401) {
            try {
              final refreshToken = await TokenStorage.getRefreshToken();

              if (refreshToken == null) {
                await _cerrarSesionYRedirigir();
                return handler.next(error);
              }

              final dioRefresh = Dio(BaseOptions(baseUrl: _baseUrl));
              final response = await dioRefresh.post(
                '/auth/movil/renovar-token',
                data: {'refreshToken': refreshToken},
                options: Options(headers: {'x-api-key': _apiKey}),
              );

              final nuevoAccessToken = response.data['accessToken'];
              final currentRefresh = await TokenStorage.getRefreshToken();

              await TokenStorage.saveTokens(
                accessToken: nuevoAccessToken,
                refreshToken: currentRefresh!,
              );

              error.requestOptions.headers['Authorization'] =
                  'Bearer $nuevoAccessToken';

              final retryResponse = await dio.fetch(error.requestOptions);
              return handler.resolve(retryResponse);
            } on DioException catch (e) {
              if (e.response?.statusCode == 403) {
                await _cerrarSesionYRedirigir();
              }
              return handler.next(error);
            } catch (e) {
              // Error inesperado renovando → login
              await _cerrarSesionYRedirigir();
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }
}
