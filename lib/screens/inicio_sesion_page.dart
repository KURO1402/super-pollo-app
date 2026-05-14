import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../widgets/custom_modal.dart';
import '../widgets/login_background.dart';
import '../widgets/login_card.dart';
import '../widgets/login_header.dart';

class InicioSesionPage extends StatefulWidget {
  const InicioSesionPage({super.key});

  @override
  State<InicioSesionPage> createState() => _InicioSesionPageState();
}

class _InicioSesionPageState extends State<InicioSesionPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  static const Map<String, dynamic> _modalCamposIncompletos = {
    'title': 'Campos incompletos',
    'message': 'Completa todos los campos',
    'icon': Icons.warning_amber_rounded,
    'color': Colors.orange,
  };

  static const Map<String, dynamic> _modalAccesoDenegado = {
    'title': 'Acceso denegado',
    'message': 'Solo colaboradores o administradores',
    'icon': Icons.block_flipped,
    'color': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      context.showCustomModal(
        title: _modalCamposIncompletos['title'],
        message: _modalCamposIncompletos['message'],
        icon: _modalCamposIncompletos['icon'],
        color: _modalCamposIncompletos['color'],
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService().login(email, password);

      if (!response.ok) {
        setState(() => _isLoading = false);
        context.showCustomModal(
          title: 'Error',
          message: response.mensaje,
          icon: Icons.error_outline,
          color: Colors.red,
        );
        return;
      }

      final rol = response.usuario.nombreRol.toLowerCase();
      if (rol != "administrador" && rol != "colaborador") {
        setState(() => _isLoading = false);
        context.showCustomModal(
          title: _modalAccesoDenegado['title'],
          message: _modalAccesoDenegado['message'],
          icon: _modalAccesoDenegado['icon'],
          color: _modalAccesoDenegado['color'],
        );
        return;
      }

      if (!mounted) return;
      context.go(
        '/menu_principal',
        extra: {
          'nombre': response.usuario.nombreUsuario,
          'apellido': response.usuario.apellidoUsuario,
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      final msg = e.toString().replaceFirst('Exception: ', '');
      context.showCustomModal(
        title: msg.contains('Correo o contraseña')
            ? 'Credenciales incorrectas'
            : 'Error',
        message: msg,
        icon: msg.contains('Correo o contraseña')
            ? Icons.lock_outline
            : Icons.error_outline,
        color: msg.contains('Correo o contraseña') ? Colors.orange : Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF050D1A) // azul muy oscuro para dark
          : const Color(0xFF0A1628), // azul oscuro para light
      body: Stack(
        children: [
          // Fondo con forma curva superior
          LoginBackground(height: size.height * 0.39),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.04),

                  // Logo y textos
                  const LoginHeader(),

                  SizedBox(height: size.height * 0.05),

                  // Card con formulario
                  LoginCard(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    isLoading: _isLoading,
                    onLogin: _login,
                    onForgotPassword: () {},
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
