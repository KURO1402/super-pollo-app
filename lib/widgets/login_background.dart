import 'package:flutter/material.dart';

class LoginBackground extends StatelessWidget {
  final double height;
  const LoginBackground({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipPath(
      clipper: _FlameClipper(),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF4A0A00),
                    Color(0xFF7A1A05),
                    Color(0xFF9B2510),
                    Color(0xFFB83A18),
                  ]
                : const [
                    Color(0xFF8B1A00),
                    Color(0xFFC8300A),
                    Color(0xFFE85520),
                    Color(0xFFF97316),
                  ],
          ),
        ),
      ),
    );
  }
}

class _FlameClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.2,
      size.width,
      size.height * 0.75,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_FlameClipper old) => false;
}
