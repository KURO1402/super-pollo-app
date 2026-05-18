import 'package:flutter/material.dart';
import 'package:super_pollo_app/models/mesas_model.dart';
import 'package:super_pollo_app/theme/app_colors.dart';

class MesaCard extends StatelessWidget {
  final MesaModel mesa;
  final bool isSelected;
  final VoidCallback? onTap;

  const MesaCard({
    super.key,
    required this.mesa,
    required this.isSelected,
    this.onTap,
  });

  bool get _isUnavailable =>
      mesa.estadoLocal == 'ocupado' || mesa.estadoMesa == 'reservada';

  _EstadoConfig _estadoConfig(bool isDark) {
    if (mesa.estadoLocal == 'ocupado') {
      return _EstadoConfig(
        label: 'Ocupada',
        color: AppColors.error,
        bgColor: isDark ? const Color(0xFF3E0A0A) : const Color(0xFFFFEBEE),
        icon: Icons.block_rounded,
      );
    }
    if (mesa.estadoMesa == 'reservada') {
      return _EstadoConfig(
        label: 'Reservada',
        color: AppColors.warning,
        bgColor: isDark ? const Color(0xFF3E2800) : const Color(0xFFFFF3E0),
        icon: Icons.event_busy_rounded,
      );
    }
    return _EstadoConfig(
      label: 'Disponible',
      color: AppColors.success,
      bgColor: isDark ? const Color(0xFF0A2E0D) : const Color(0xFFE8F5E9),
      icon: Icons.check_circle_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final config = _estadoConfig(isDark);

    // Colores de la card según estado
    final cardBg = isSelected
        ? colorScheme.primary.withOpacity(0.08)
        : _isUnavailable
            ? config.bgColor
            : (isDark ? AppColors.navyCard : Colors.white);

    final borderColor = isSelected
        ? colorScheme.primary
        : _isUnavailable
            ? config.color.withOpacity(0.4)
            : (isDark ? AppColors.navyLight : AppColors.grey100);

    final iconColor = isSelected
        ? colorScheme.primary
        : _isUnavailable
            ? config.color
            : (isDark ? AppColors.grey300 : AppColors.grey700);

    final nameColor = _isUnavailable
        ? config.color
        : (isDark ? AppColors.offWhite : const Color(0xFF1A1A1A));

    final capacityColor = _isUnavailable
        ? config.color.withOpacity(0.6)
        : AppColors.grey500;

    // Tamaños responsivos (sin cambios en la lógica)
    final screenW = MediaQuery.of(context).size.width;
    final double cardHeight = screenW < 320
        ? 130
        : screenW < 360
            ? 140
            : screenW < 400
                ? 150
                : 160;
    final bool isSmall = screenW < 360;
    final double iconSize = screenW < 320 ? 20 : (isSmall ? 22 : 28);
    final double nameFontSize = screenW < 320 ? 12 : (isSmall ? 13 : 15);
    final double capacityFontSize = screenW < 320 ? 9 : (isSmall ? 10 : 12);
    final double capacityIconSize = screenW < 320 ? 9 : (isSmall ? 10 : 12);
    final double badgeFontSize = screenW < 320 ? 8 : (isSmall ? 9 : 11);
    final double badgeIconSize = screenW < 320 ? 8 : (isSmall ? 9 : 11);
    final double hPadding = screenW < 320 ? 6 : (isSmall ? 8 : 12);
    final double vPadding = screenW < 320 ? 5 : (isSmall ? 7 : 10);
    final double gap1 = screenW < 320 ? 3 : (isSmall ? 4 : 6);
    final double gap2 = screenW < 320 ? 1 : (isSmall ? 1 : 2);

    return SizedBox(
      height: cardHeight,
      child: GestureDetector(
        onTap: _isUnavailable ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: hPadding, vertical: vPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícono de mesa
                Icon(Icons.table_restaurant_rounded,
                    size: iconSize, color: iconColor),

                SizedBox(height: gap1),

                // Nombre de la mesa
                Text(
                  mesa.nombre,
                  style: TextStyle(
                    fontSize: nameFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: nameColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: gap2),

                // Capacidad
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: capacityIconSize, color: capacityColor),
                    const SizedBox(width: 3),
                    Text(
                      '${mesa.capacidadMesa} per.',
                      style: TextStyle(
                          fontSize: capacityFontSize, color: capacityColor),
                    ),
                  ],
                ),

                const Spacer(),

                // Badge de estado
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenW < 320 ? 4 : (isSmall ? 6 : 10),
                    vertical: screenW < 320 ? 2 : (isSmall ? 3 : 4),
                  ),
                  decoration: BoxDecoration(
                    color: config.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(config.icon,
                          size: badgeIconSize, color: config.color),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          config.label,
                          style: TextStyle(
                            fontSize: badgeFontSize,
                            fontWeight: FontWeight.w600,
                            color: config.color,
                            letterSpacing: 0.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EstadoConfig {
  final String label;
  final Color color;
  final Color bgColor; // ya incluye variante dark/light según el constructor
  final IconData icon;

  _EstadoConfig({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
  });
}