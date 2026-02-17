import 'usuario_model.dart';

class LoginResponseModel {
  final bool ok;
  final String mensaje;
  final UsuarioModel usuario;
  final String accessToken;

  LoginResponseModel({
    required this.ok,
    required this.mensaje,
    required this.usuario,
    required this.accessToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      ok: json['ok'],
      mensaje: json['mensaje'],
      usuario: UsuarioModel.fromJson(json['usuario']),
      accessToken: json['accessToken'],
    );
  }
}
