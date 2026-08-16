import 'package:dio/dio.dart';
import 'package:super_pollo_app/models/estadisticas_model.dart';
import 'package:super_pollo_app/utils/dio_backend.dart';

class EstadisticasService {
  final Dio _dio = DioClient.dio;

  Future<MesasActivasModel> obtenerMesasActivas() async {
    try {
      final response = await _dio.get("/fuente-datos/mesas-activas");
      return MesasActivasModel.fromJson(response.data['resultado']);
    } catch (e) {
      if (e is DioException) {
      }
      throw Exception("Error al obtener las mesas activas");
    }
  }

  Future<VentasHoyModel> obtenerVentasHoy() async {
    try {
      final response = await _dio.get("/fuente-datos/ventas-hoy-movil");
      return VentasHoyModel.fromJson(response.data['resultado']);
    } catch (e) {
      if (e is DioException) {
      }
      throw Exception("Error al obtener las ventas de hoy");
    }
  }
}