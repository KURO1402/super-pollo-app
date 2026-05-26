import 'package:dio/dio.dart';
import 'package:super_pollo_app/utils/dio_backend.dart';

class CancelarPedidoResponse {
  final bool ok;
  final String mensaje;

  CancelarPedidoResponse({required this.ok, required this.mensaje});

  factory CancelarPedidoResponse.fromJson(Map<String, dynamic> json) {
    return CancelarPedidoResponse(
      ok: json['ok'] ?? false,
      mensaje: json['mensaje'] ?? json['message'] ?? '',
    );
  }
}

class CancelarPedidoService {
  final Dio _dio = DioClient.dio;

  Future<CancelarPedidoResponse> cancelarPedido(int idPedido) async {
    try {
      final response = await _dio.patch('/pedidos/pedido/$idPedido/cancelar');
      return CancelarPedidoResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error al cancelar el pedido',
      );
    }
  }
}