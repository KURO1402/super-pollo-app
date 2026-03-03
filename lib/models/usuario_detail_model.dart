class UsuarioDetailModel {
  final int idUsuario;
  final String nombreUsuario;
  final String apellidoUsuario;
  final String correoUsuario;
  final String telefonoUsuario;
  final int idRol;
  final String nombreRol;
  final List<RolModel> roles;

  UsuarioDetailModel({
    required this.idUsuario,
    required this.nombreUsuario,
    required this.apellidoUsuario,
    required this.correoUsuario,
    required this.telefonoUsuario,
    required this.idRol,
    required this.nombreRol,
    required this.roles,
  });

  factory UsuarioDetailModel.fromJson(Map<String, dynamic> json) {
    var list = json['roles'] as List;
    List<RolModel> rolesList = list.map((i) => RolModel.fromJson(i)).toList();

    return UsuarioDetailModel(
      idUsuario: json['id_usuario'],
      nombreUsuario: json['nombre_usuario'],
      apellidoUsuario: json['apellido_usuario'],
      correoUsuario: json['correo_usuario'],
      telefonoUsuario: json['telefono_usuario'],
      idRol: json['id_rol'],
      nombreRol: json['nombre_rol'],
      roles: rolesList,
    );
  }
}

// Modelo para los roles
class RolModel {
  final String nombreRol;
  final String fechaInicio;
  final String fechaFin;

  RolModel({
    required this.nombreRol,
    required this.fechaInicio,
    required this.fechaFin,
  });

  factory RolModel.fromJson(Map<String, dynamic> json) {
    return RolModel(
      nombreRol: json['nombre_rol'],
      fechaInicio: json['fecha_inicio'],
      fechaFin: json['fecha_fin'],
    );
  }
}