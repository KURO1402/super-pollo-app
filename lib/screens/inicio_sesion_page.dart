import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/input_personalizado.dart';
import '../services/auth_service.dart';
import '../utils/token_storage.dart';

class InicioSesionPage extends StatefulWidget {
  const InicioSesionPage({super.key});

  @override
  State<InicioSesionPage> createState() => _InicioSesionPage();
}

class _InicioSesionPage extends State<InicioSesionPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isHovering = false;
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final response = await authService.login(email, password);

      if (!response.ok) {
        throw Exception(response.mensaje);
      }

      final rol = response.usuario.nombreRol.toLowerCase();

      if (rol != "administrador" && rol != "colaborador") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Acceso denegado. Solo colaboradores o administradores",
            ),
          ),
        );
        return;
      }

      await TokenStorage.saveToken(response.accessToken);

      if (!mounted) return;

      context.go(
        "/menu_principal",
        extra: {
          "nombre": response.usuario.nombreUsuario,
          "apellido": response.usuario.apellidoUsuario,
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Image.asset(
                'assets/images/super_pollo_logo.png',
                width: 170,
                fit: BoxFit.contain,
              ),
              const Text(
                "Gestiona todo al instante",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Bienvenido de nuevo !!",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 70),

              InputPersonalizado(
                label: 'Correo',
                hintText: 'Ingresa tu correo',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                isPassword: false,
              ),

              const SizedBox(height: 50),

              InputPersonalizado(
                label: 'Contraseña',
                hintText: 'Ingresa tu contraseña',
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                isPassword: true,
              ),

              const SizedBox(height: 100),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F6BFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'INICIAR SESIÓN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _isHovering = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _isHovering = false;
                  });
                },
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0F6BFF),
                    overlayColor: Colors.transparent,
                  ),
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: _isHovering
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationColor: const Color(0xFF0F6BFF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
