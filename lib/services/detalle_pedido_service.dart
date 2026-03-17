import 'package:dio/dio.dart';
import 'package:super_pollo_app/models/detalle_pedido_model.dart';
import 'package:super_pollo_app/utils/dio_backend.dart';

class DetallePedidoService {
  final Dio _dio = DioClient.dio;

  Future<DetallePedidoModel> getDetallePedido(int idPedido) async {
    try {
      final response = await _dio.get('/pedidos/pedido/$idPedido');
      return DetallePedidoModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener el detalle del pedido');
    }
  }
}