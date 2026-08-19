import 'package:dio/dio.dart';
import 'package:super_pollo_app/utils/dio_backend.dart';
import 'package:super_pollo_app/models/pedido_mesa_model.dart';

class PedidosMesaService {
  final Dio _dio = DioClient.dio;

  /// Devuelve el pedido activo de una mesa específica, o null si no tiene ninguno.
  Future<PedidoMesaModel?> getPedidoPorMesa(int idMesa) async {
    try {
      final response = await _dio.get('/pedidos/mesa/$idMesa');
      final data = response.data;

      if (data['ok'] == true && data['pedido'] != null) {
        return PedidoMesaModel.fromJson(data['pedido']);
      }
      return null;
    } on DioException catch (e) {
      // Si el backend responde 404 cuando la mesa no tiene pedido activo,
      // lo tratamos como "sin pedido" en vez de error.
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception(
        e.response?.data['message'] ?? 'Error al obtener el pedido de la mesa',
      );
    }
  }
}