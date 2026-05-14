import 'package:dio/dio.dart';
import 'package:super_pollo_app/models/usuario_detail_model.dart';
import 'package:super_pollo_app/utils/dio_backend.dart';

class UsuarioService {
  final Dio _dio = DioClient.dio;

  Future<UsuarioDetailModel> obtenerUsuario() async {
    try {
      final response = await _dio.get("/usuarios/usuario");
      return UsuarioDetailModel.fromJson(response.data['usuario']);
    } on DioException catch (e) {
      throw Exception("Error al obtener los datos del usuario");
    }
  }
}
