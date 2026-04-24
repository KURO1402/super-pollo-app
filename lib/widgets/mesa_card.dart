import 'package:flutter/material.dart';
import 'package:super_pollo_app/models/mesas_model.dart';

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

  _EstadoConfig get _estadoConfig {
    if (mesa.estadoLocal == 'ocupado') {
      return _EstadoConfig(
        label: 'Ocupada',
        color: const Color(0xFFE53935),
        bgColor: const Color(0xFFFFEBEE),
        icon: Icons.block_rounded,
      );
    }

    if (mesa.estadoMesa == 'reservada') {
      return _EstadoConfig(
        label: 'Reservada',
        color: const Color(0xFFE67E22),
        bgColor: const Color(0xFFFFF3E0),
        icon: Icons.event_busy_rounded,
      );
    }

    return _EstadoConfig(
      label: 'Disponible',
      color: const Color(0xFF2E7D32),
      bgColor: const Color(0xFFE8F5E9),
      icon: Icons.check_circle_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _estadoConfig;

    final screenW = MediaQuery.of(context).size.width;
    
    final double cardHeight;
    if (screenW < 320) {
      cardHeight = 130;
    } else if (screenW < 360) {
      cardHeight = 140;
    } else if (screenW < 400) {
      cardHeight = 150;
    } else {
      cardHeight = 160;
    }

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
    final double gap3 = screenW < 320 ? 3 : (isSmall ? 5 : 8);

    return SizedBox(
      height: cardHeight,
      child: GestureDetector(
        onTap: _isUnavailable ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1565C0).withOpacity(0.06)
                : _isUnavailable
                    ? config.bgColor
                    : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1565C0)
                  : _isUnavailable
                      ? config.color.withOpacity(0.4)
                      : const Color(0xFFE8E8E8),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.table_restaurant_rounded,
                  size: iconSize,
                  color: isSelected
                      ? const Color(0xFF1565C0)
                      : _isUnavailable
                          ? config.color
                          : const Color(0xFF424242),
                ),
                SizedBox(height: gap1),
                Text(
                  mesa.nombre,
                  style: TextStyle(
                    fontSize: nameFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: _isUnavailable ? config.color : const Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: gap2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: capacityIconSize,
                      color: _isUnavailable
                          ? config.color.withOpacity(0.6)
                          : const Color(0xFF757575),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${mesa.capacidadMesa} per.',
                      style: TextStyle(
                        fontSize: capacityFontSize,
                        color: _isUnavailable
                            ? config.color.withOpacity(0.6)
                            : const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
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
                      Icon(config.icon, size: badgeIconSize, color: config.color),
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
  final Color bgColor;
  final IconData icon;

  _EstadoConfig({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
  });
}