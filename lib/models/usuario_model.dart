class UsuarioModel {
  final int idUsuario;
  final String nombreUsuario;
  final String apellidoUsuario;
  final int idRol;
  final String nombreRol;

  UsuarioModel({
    required this.idUsuario,
    required this.nombreUsuario,
    required this.apellidoUsuario,
    required this.idRol,
    required this.nombreRol,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      idUsuario: json['id_usuario'],
      nombreUsuario: json['nombre_usuario'],
      apellidoUsuario: json['apellido_usuario'],
      idRol: json['id_rol'],
      nombreRol: json['nombre_rol'],
    );
  }
}
