import 'package:dio/dio.dart';
import 'package:super_pollo_app/models/login_response_model.dart';
import 'package:super_pollo_app/utils/dio_backend.dart';

class AuthService {
  final Dio _dio = DioClient.dio;

  Future<LoginResponseModel> login(String email, String clave) async {
    try {
      final response = await _dio.post(
        "/auth/login",
        data: {"email": email, "clave": clave},
      );

      return LoginResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data["mensaje"] ?? "Error al iniciar sesión");
    }
  }
}
