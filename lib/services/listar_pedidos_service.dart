import 'package:dio/dio.dart';
import 'package:super_pollo_app/utils/dio_backend.dart';
import 'package:super_pollo_app/models/listar_pedidos_model.dart';

class PedidosService {
  static final Dio _dio = DioClient.dio;

  static Future<PedidosResponse> listarPedidos({
    required String fecha,
    required String hora,
  }) async {
    try {
      final response = await _dio.get(
        '/pedidos',
        queryParameters: {'fecha': fecha, 'hora': hora},
      );
      return PedidosResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return PedidosResponse(ok: true, pedidos: []);
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }
}
