import 'package:dio/dio.dart';
import 'package:super_pollo_app/models/usuario_detail_model.dart';
import 'package:super_pollo_app/utils/dio_backend.dart';
import 'package:super_pollo_app/utils/token_storage.dart'; // Importa el almacenamiento del token

class UsuarioService {
  final Dio _dio = DioClient.dio;

  // Método para obtener los datos del usuario
  Future<UsuarioDetailModel> obtenerUsuario() async {
    try {
      // Obtener el token directamente desde el almacenamiento local
      final token = await TokenStorage.getToken();
      
      // Realizar la solicitud a la API pasando el token en el header
      final response = await _dio.get(
        "/usuarios/usuario",
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      // Devolver el modelo de usuario a partir de la respuesta
      return UsuarioDetailModel.fromJson(response.data['usuario']);
    } on DioException catch (e) {
      // Capturar el error y mostrarlo en la consola
      throw Exception("Error al obtener los datos del usuario");
    }
  }
}