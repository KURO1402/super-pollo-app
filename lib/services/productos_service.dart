import 'package:dio/dio.dart';
import 'package:super_pollo_app/models/productos_model.dart';
import 'package:super_pollo_app/utils/dio_backend.dart';

class ProductosService {
  final Dio _dio = DioClient.dio;

  Future<List<ProductoModel>> getProductos() async {
    try {
      final response = await _dio.get("/productos/catalogo");

      // Asegúrate de que "productos" esté presente en la respuesta
      if (response.data["productos"] == null) {
        return [];
      }

      final List listadoProductos = response.data["productos"];
      
      return listadoProductos.map((p) => ProductoModel.fromJson(p)).toList();
    } catch (e) {
      throw Exception("Error al cargar productos");
    }
  }
}

