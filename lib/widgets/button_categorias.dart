import 'package:flutter/material.dart';
import 'package:super_pollo_app/theme/app_colors.dart';

class CategoriaButtonWidget extends StatelessWidget {
  final String nombre;
  final bool seleccionado;
  final VoidCallback onTap;

  const CategoriaButtonWidget({
    super.key,
    required this.nombre,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final bgColor = seleccionado
        ? colorScheme.primary
        : (isDark ? AppColors.navyLight : AppColors.grey100);

    final borderColor = seleccionado
        ? colorScheme.primary
        : Colors.transparent;

    final textColor = seleccionado
        ? Colors.white
        : (isDark ? AppColors.grey300 : AppColors.grey700);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Center(
          child: Text(
            nombre,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}