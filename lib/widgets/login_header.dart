import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          width: 165,
          height: 165,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Fondo transparente — el logo flota sobre el degradado rojo
            color: Colors.transparent,
            boxShadow: [
              // Glow exterior dorado que combina con el rojo
              BoxShadow(
                color: const Color(0xFFFFAA00).withOpacity(0.35),
                blurRadius: 28,
                spreadRadius: 6,
              ),
              // Sombra interior oscura para profundidad
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/super_pollo_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Gestiona todo al instante',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Bienvenido de nuevo!!',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.orange.shade100 : Colors.orange.shade200,
          ),
        ),
      ],
    );
  }
}
