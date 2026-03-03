import 'package:dio/dio.dart';
import 'package:super_pollo_app/models/mesas_model.dart';
import 'package:super_pollo_app/utils/dio_backend.dart';

import 'package:super_pollo_app/models/mesas_response_model.dart';
import 'package:super_pollo_app/utils/dio_backend.dart';
import 'package:super_pollo_app/utils/token_storage.dart';


class MesasService {
  final Dio _dio = DioClient.dio;
  Future<MesasResponseModel> getMesasPedido(String fecha, String hora) async {
    try {
      final token = await TokenStorage.getToken();

      final response = await _dio.get(
        '/pedidos/mesas',
        queryParameters: {'fecha': fecha, 'hora': hora},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return MesasResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error al obtener las mesas',
      );
    }
  }
}
