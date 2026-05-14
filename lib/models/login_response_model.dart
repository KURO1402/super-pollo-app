class LoginResponseModel {
  final bool ok;
  final String mensaje;
  final UsuarioSesionModel usuario;
  final String accessToken;
  final String refreshToken;

  LoginResponseModel({
    required this.ok,
    required this.mensaje,
    required this.usuario,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      ok: json['ok'],
      mensaje: json['mensaje'],
      usuario: UsuarioSesionModel.fromJson(json['usuario']),
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}

class UsuarioSesionModel {
  final int idUsuario;
  final String nombreUsuario;
  final String apellidoUsuario;
  final int idRol;
  final String nombreRol;

  UsuarioSesionModel({
    required this.idUsuario,
    required this.nombreUsuario,
    required this.apellidoUsuario,
    required this.idRol,
    required this.nombreRol,
  });

  factory UsuarioSesionModel.fromJson(Map<String, dynamic> json) {
    return UsuarioSesionModel(
      idUsuario: json['id_usuario'],
      nombreUsuario: json['nombre_usuario'],
      apellidoUsuario: json['apellido_usuario'],
      idRol: json['id_rol'],
      nombreRol: json['nombre_rol'],
    );
  }
}
