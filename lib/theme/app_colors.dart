import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Rojo / Naranja
  static const Color brandRed       = Color(0xFFC8300A); // rojo principal
  static const Color brandRedDark   = Color(0xFF8B1A00); // rojo oscuro
  static const Color brandOrange    = Color(0xFFE85520); // naranja vivo
  static const Color brandOrangeTip = Color(0xFFF97316); // punta de llama
  static const Color brandGold      = Color(0xFFFFAA00); // dorado / glow

  // Variantes dark-mode de la llama
  static const Color brandRedDim    = Color(0xFF7A1A05);
  static const Color brandRedDeep   = Color(0xFF4A0A00);
  static const Color brandOrangeDim = Color(0xFFB83A18);

  // ── Fondo azul oscuro (identidad de marca) ───
  static const Color navyDeep  = Color(0xFF050D1A); // dark background
  static const Color navyDark  = Color(0xFF0A1628); // light-mode scaffold bg
  static const Color navyCard  = Color(0xFF0F1E35); // cards en dark
  static const Color navyLight = Color(0xFF162540); // superficie secundaria dark

  static const Color white      = Color(0xFFFFFFFF);
  static const Color offWhite   = Color(0xFFF5F5F5);
  static const Color grey100    = Color(0xFFE8E8E8);
  static const Color grey300    = Color(0xFFB0B0B0);
  static const Color grey500    = Color(0xFF757575);
  static const Color grey700    = Color(0xFF424242);
  static const Color grey900    = Color(0xFF1A1A1A);
  static const Color black      = Color(0xFF000000);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE65100);
  static const Color error   = Color(0xFFC62828);
  static const Color info    = Color(0xFF0277BD);

  static const LinearGradient flameGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandRedDark, brandRed, brandOrange, brandOrangeTip],
  );

  static const LinearGradient flameGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandRedDeep, brandRedDim, Color(0xFF9B2510), brandOrangeDim],
  );
}