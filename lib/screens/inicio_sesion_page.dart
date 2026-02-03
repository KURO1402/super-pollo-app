import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/input_personalizado.dart';

class InicioSesionPage extends StatefulWidget {
  const InicioSesionPage({super.key});

  @override
  State<InicioSesionPage> createState() => _InicioSesionPage();
}

class _InicioSesionPage extends State<InicioSesionPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isHovering = false; // Para controlar el hover en el TextButton

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 70.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 80),
              Image.asset(
                'assets/images/super_pollo_logo.png',
                width: 170,
                fit: BoxFit.contain,
              ),
              Text(
                "Gestiona todo al instante",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Bienvenido de nuevo !!",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 70),
              InputPersonalizado(
                label: 'Correo',
                hintText: 'Ingresa tu correo',
                controller: TextEditingController(),
                keyboardType: TextInputType.emailAddress,
                isPassword: false,
              ),
              SizedBox(height: 50),
              InputPersonalizado(
                label: 'Contraseña',
                hintText: 'Ingresa tu contraseña',
                controller: TextEditingController(),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                isPassword: true,
              ),
              SizedBox(height: 100),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go("/menu_principal");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F6BFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'INICIAR SESIÓN',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Aplicando el efecto hover al TextButton con hover desactivado
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _isHovering = true; // Activamos el hover
                  });
                },
                onExit: (_) {
                  setState(() {
                    _isHovering = false; // Desactivamos el hover
                  });
                },
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0F6BFF),
                    overlayColor:
                        Colors.transparent, // Desactivamos el hover por defecto
                  ),
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: _isHovering
                          ? TextDecoration.underline
                          : TextDecoration.none, // Aplica el subrayado
                      decorationColor: const Color(
                        0xFF0F6BFF,
                      ), // Color de la línea
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
