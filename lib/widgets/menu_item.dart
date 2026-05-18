import 'package:flutter/material.dart';
import 'package:super_pollo_app/theme/app_colors.dart';

class MenuItemWidget extends StatelessWidget {
  final String itemName;
  final String description;
  final String price;
  final int quantity;
  final List<String> images;
  final VoidCallback onIncrementar;
  final VoidCallback onDecrementar;

  const MenuItemWidget({
    super.key,
    required this.itemName,
    required this.description,
    required this.price,
    required this.quantity,
    required this.images,
    required this.onIncrementar,
    required this.onDecrementar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;

    // Tamaños responsivos (sin cambios)
    final double imgSize       = isSmall ? 70  : 85;
    final double nameFontSize  = isSmall ? 13  : 15;
    final double descFontSize  = isSmall ? 11  : 13;
    final double priceFontSize = isSmall ? 13  : 15;
    final double hMargin       = isSmall ? 6   : 12;
    final double vMargin       = isSmall ? 4   : 6;
    final double padding       = isSmall ? 8   : 12;
    final double innerGap      = isSmall ? 8   : 12;
    final double btnSize       = isSmall ? 26  : 30;
    final double btnIconSize   = isSmall ? 15  : 18;
    final double counterFontSize = isSmall ? 13 : 15;
    final double counterHPad   = isSmall ? 6   : 10;

    final cardBg = isDark ? AppColors.navyCard : Colors.white;
    final imageFallbackBg = isDark ? AppColors.navyLight : AppColors.grey100;
    final imageFallbackIcon = isDark ? AppColors.grey500 : AppColors.grey300;

    return Container(
      margin: EdgeInsets.symmetric(vertical: vMargin, horizontal: hMargin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagen del producto
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: images.isNotEmpty
                ? Image.network(
                    images[0],
                    width: imgSize,
                    height: imgSize,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _ImageFallback(
                      size: imgSize,
                      bgColor: imageFallbackBg,
                      iconColor: imageFallbackIcon,
                    ),
                  )
                : _ImageFallback(
                    size: imgSize,
                    bgColor: imageFallbackBg,
                    iconColor: imageFallbackIcon,
                  ),
          ),

          SizedBox(width: innerGap),

          // Info del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  itemName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: descFontSize,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: priceFontSize,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: isSmall ? 6 : 8),

          // Contador
          _CounterWidget(
            quantity: quantity,
            onIncrementar: onIncrementar,
            onDecrementar: onDecrementar,
            btnSize: btnSize,
            btnIconSize: btnIconSize,
            counterFontSize: counterFontSize,
            hPadding: counterHPad,
          ),
        ],
      ),
    );
  }
}

// ── Fallback de imagen ────────────────────────────────────────────────────────
class _ImageFallback extends StatelessWidget {
  final double size;
  final Color bgColor;
  final Color iconColor;

  const _ImageFallback({
    required this.size,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: bgColor,
      child: Icon(Icons.fastfood_rounded, color: iconColor, size: size * 0.4),
    );
  }
}

// ── Contador ──────────────────────────────────────────────────────────────────
class _CounterWidget extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrementar;
  final VoidCallback onDecrementar;
  final double btnSize;
  final double btnIconSize;
  final double counterFontSize;
  final double hPadding;

  const _CounterWidget({
    required this.quantity,
    required this.onIncrementar,
    required this.onDecrementar,
    required this.btnSize,
    required this.btnIconSize,
    required this.counterFontSize,
    required this.hPadding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? AppColors.navyLight : AppColors.grey100;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPadding * 0.4, vertical: 4),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrementar,
            child: _ActionButton(
              icon: Icons.remove,
              isPrimary: false,
              size: btnSize,
              iconSize: btnIconSize,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPadding * 0.6),
            child: Text(
              '$quantity',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: counterFontSize,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          GestureDetector(
            onTap: onIncrementar,
            child: _ActionButton(
              icon: Icons.add,
              isPrimary: true,
              size: btnSize,
              iconSize: btnIconSize,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botón +/- ─────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final bool isPrimary;
  final double size;
  final double iconSize;

  const _ActionButton({
    required this.icon,
    required this.isPrimary,
    required this.size,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // Botón "+" → color de marca; botón "-" → superficie neutra
    final bgColor = isPrimary
        ? colorScheme.primary
        : (isDark ? AppColors.navyCard : Colors.white);

    final iconColor = isPrimary
        ? Colors.white
        : colorScheme.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          if (!isPrimary)
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.10),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Icon(icon, size: iconSize, color: iconColor),
    );
  }
}