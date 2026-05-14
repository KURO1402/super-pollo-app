import 'package:dio/dio.dart';
import 'package:super_pollo_app/models/login_response_model.dart';
import 'package:super_pollo_app/utils/dio_backend.dart';
import 'package:super_pollo_app/utils/token_storage.dart';

class AuthService {
  final Dio _dio = DioClient.dio;

  Future<LoginResponseModel> login(String email, String clave) async {
    try {
      final response = await _dio.post(
        '/auth/movil/login',
        data: {'email': email, 'clave': clave},
      );

      final loginResponse = LoginResponseModel.fromJson(response.data);

      // Guardar ambos tokens
      await TokenStorage.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
      );

      return loginResponse;
    } on DioException catch (e) {
      throw Exception(e.response?.data['mensaje'] ?? 'Error al iniciar sesión');
    }
  }

  Future<void> logout() async {
    await TokenStorage.clearTokens();
  }
}
