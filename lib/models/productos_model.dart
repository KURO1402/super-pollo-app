class ProductoModel {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final List<String> imagenes;

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenes,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id_producto'],
      nombre: json['nombre_producto'],
      descripcion: json['descripcion_producto'],
      precio: double.parse(json['precio_producto']),
      imagenes: List<String>.from(
        json['imagenes'].map(
          (img) => img['url_imagen'],
        ),
      ),
    );
  }
}
