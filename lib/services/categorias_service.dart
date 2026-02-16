import 'package:dio/dio.dart';
import 'package:super_pollo_app/models/categorias_model.dart';
import 'package:super_pollo_app/utils/dio_backend.dart';

class CategoriasService {
  final Dio _dio = DioClient.dio;

  Future<List<CategoriaModel>> getCategorias() async {
    try {
      final response = await _dio.get("/categorias-producto");

      if (response.data["categorias"] == null) {
        return [];
      }

      final List listadoCategorias = response.data["categorias"];
      
      return listadoCategorias.map((p) => CategoriaModel.fromJson(p)).toList();
    } catch (e) {
      throw Exception("Error al cargar categorias");
    }
  }
}