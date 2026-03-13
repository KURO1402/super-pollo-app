import 'package:dio/dio.dart';
import 'package:super_pollo_app/models/pedido_model.dart';
import 'package:super_pollo_app/utils/dio_backend.dart';

class PedidosService {
  final Dio _dio = DioClient.dio;

  Future<PedidoModel> insertarPedido({
    required List<Map<String, dynamic>> mesas,
    required List<Map<String, dynamic>> productos,
  }) async {
    try {
      final response = await _dio.post(
        "/pedidos/crear-pedido",
        data: {
          "mesas": mesas,
          "productos": productos.map((p) => {
            "idProducto": p['idProducto'],
            "cantidad": p['cantidad'],
          }).toList(),
        },
      );
      return PedidoModel.fromJson(response.data);
    } catch (e) { 
      if (e is DioException) {
      }
      throw Exception("Error al registrar el pedido");
    }
  }
}