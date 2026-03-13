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

    return GestureDetector(
      onTap: _isUnavailable ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1565C0).withOpacity(0.06)
              : _isUnavailable
              ? const Color(0xFFF5F5F5)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1565C0)
                : _isUnavailable
                ? const Color(0xFFE0E0E0)
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.table_restaurant_rounded,
                size: 28,
                color: isSelected
                    ? const Color(0xFF1565C0)
                    : _isUnavailable
                    ? const Color(0xFFBDBDBD)
                    : const Color(0xFF424242),
              ),
              const SizedBox(height: 6),
              Text(
                mesa.nombre,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: _isUnavailable
                      ? const Color(0xFF9E9E9E)
                      : const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 12,
                    color: _isUnavailable
                        ? const Color(0xFFBDBDBD)
                        : const Color(0xFF757575),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${mesa.capacidadMesa} personas',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isUnavailable
                          ? const Color(0xFFBDBDBD)
                          : const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: config.bgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(config.icon, size: 11, color: config.color),
                    const SizedBox(width: 4),
                    Text(
                      config.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: config.color,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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