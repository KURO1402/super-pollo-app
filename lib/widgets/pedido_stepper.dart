import 'package:flutter/material.dart';
import 'package:super_pollo_app/theme/app_colors.dart';

class PedidoStep {
  final String label;
  final IconData icon;
  const PedidoStep({required this.label, required this.icon});
}

const List<PedidoStep> kPedidoSteps = [
  PedidoStep(label: 'Mesas', icon: Icons.table_restaurant_rounded),
  PedidoStep(label: 'Menú', icon: Icons.restaurant_menu_rounded),
  PedidoStep(label: 'Resumen', icon: Icons.receipt_long_rounded),
];

class PedidoStepper extends StatelessWidget {
  final int currentStep;
  final Set<int> completedSteps;
  final void Function(int stepIndex)? onStepTapped;

  const PedidoStepper({
    super.key,
    required this.currentStep,
    required this.completedSteps,
    this.onStepTapped,
  });

  bool _isAccessible(int index) =>
      index == currentStep || completedSteps.contains(index);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.navyCard : Colors.white;
    final borderColor = isDark ? AppColors.navyLight : const Color(0xFFEEEEEE);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: List.generate(kPedidoSteps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final leftStep = i ~/ 2;
            final rightStep = leftStep + 1;
            final isConnected = completedSteps.contains(leftStep) ||
                completedSteps.contains(rightStep);
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 2,
                decoration: BoxDecoration(
                  color: isConnected
                      ? Theme.of(context).colorScheme.primary
                      : (isDark ? AppColors.navyLight : const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }

          final stepIndex = i ~/ 2;
          final step = kPedidoSteps[stepIndex];
          final isCurrent = stepIndex == currentStep;
          final isCompleted = completedSteps.contains(stepIndex);
          final accessible = _isAccessible(stepIndex);

          return _StepBubble(
            step: step,
            isCurrent: isCurrent,
            isCompleted: isCompleted,
            isAccessible: accessible,
            onTap: accessible && onStepTapped != null
                ? () => onStepTapped!(stepIndex)
                : null,
          );
        }),
      ),
    );
  }
}

class _StepBubble extends StatelessWidget {
  final PedidoStep step;
  final bool isCurrent;
  final bool isCompleted;
  final bool isAccessible;
  final VoidCallback? onTap;

  const _StepBubble({
    required this.step,
    required this.isCurrent,
    required this.isCompleted,
    required this.isAccessible,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // Colores de burbuja según estado
    final Color bubbleColor;
    final Color iconColor;
    final Color labelColor;

    if (isCurrent) {
      bubbleColor = colorScheme.primary;
      iconColor = Colors.white;
      labelColor = colorScheme.primary;
    } else if (isCompleted) {
      bubbleColor = colorScheme.primary.withOpacity(0.12);
      iconColor = colorScheme.primary;
      labelColor = colorScheme.primary;
    } else {
      // Paso inactivo — se adapta al tema
      bubbleColor = isDark ? AppColors.navyLight : const Color(0xFFF0F0F0);
      iconColor = isDark ? AppColors.grey500 : AppColors.grey300;
      labelColor = isDark ? AppColors.grey500 : AppColors.grey300;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bubbleColor,
              shape: BoxShape.circle,
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: isCompleted && !isCurrent
                  ? Icon(Icons.check_rounded, color: iconColor, size: 18)
                  : Icon(step.icon, color: iconColor, size: 18),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: labelColor,
              letterSpacing: -0.2,
            ),
            child: Text(step.label),
          ),
        ],
      ),
    );
  }
}