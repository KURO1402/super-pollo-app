import 'package:dio/dio.dart';
import 'package:super_pollo_app/utils/dio_backend.dart';

class EditarPedidoRequest {
  final List<Map<String, dynamic>> mesas;
  final List<Map<String, dynamic>> productos;

  EditarPedidoRequest({
    required this.mesas,
    required this.productos,
  });

  Map<String, dynamic> toJson() => {
        'mesas': mesas,
        'productos': productos,
      };
}

class EditarPedidoResponse {
  final bool ok;
  final String mensaje;

  EditarPedidoResponse({required this.ok, required this.mensaje});

  factory EditarPedidoResponse.fromJson(Map<String, dynamic> json) {
    return EditarPedidoResponse(
      ok: json['ok'] ?? false,
      mensaje: json['mensaje'] ?? json['message'] ?? '',
    );
  }
}

class EditarPedidoService {
  final Dio _dio = DioClient.dio;

  Future<EditarPedidoResponse> editarPedido({
    required int idPedido,
    required EditarPedidoRequest request,
  }) async {
    try {
      final response = await _dio.put(
        '/pedidos/pedido/$idPedido',
        data: request.toJson(),
      );
      return EditarPedidoResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al actualizar el pedido');
    }
  }
}