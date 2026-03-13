import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:super_pollo_app/utils/dio_backend.dart';
import 'package:super_pollo_app/models/listar_pedidos_model.dart';
import 'package:super_pollo_app/utils/token_storage.dart';

class PedidosService {
  static final Dio _dio = DioClient.dio;

  /// Obtiene lista de pedidos para una fecha y hora específica
  static Future<PedidosResponse> listarPedidos({
    required String fecha, // Formato: YYYY-MM-DD
    required String hora, // Formato: HH:MM
  }) async {
    try {
      final token = await TokenStorage.getToken();

      final response = await _dio.get(
        '/pedidos',
        queryParameters: {'fecha': fecha, 'hora': hora},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final jsonString = jsonEncode(response.data);
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        return PedidosResponse.fromJson(data);
      } else {
        throw Exception('Error al obtener pedidos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return PedidosResponse(ok: true, pedidos: []);
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
