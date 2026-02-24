import 'package:dio/dio.dart';
import 'package:super_pollo_app/models/mesas_model.dart';
import 'package:super_pollo_app/utils/dio_backend.dart';

class MesasService {
  final Dio _dio = DioClient.dio;

  Future<List<MesasModel>> getMesas() async {
    try{
      final response = await _dio.get("/mesas");

      if (response.data["mesas"] == null) {
        return [];
      }

      final List listadoMesas = response.data["mesas"];
      return listadoMesas.map((p) => MesasModel.fromJson(p)).toList();
    }catch (e) {
      throw Exception("Error al cargar mesas");
    }
  }
}