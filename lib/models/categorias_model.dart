class CategoriaModel {
  final int idCategoria;
  final String nombre;

  CategoriaModel({
    required this.idCategoria,
    required this.nombre,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      idCategoria: json['id_categoria'],
      nombre: json['nombre_categoria'],
    );
  }
}
