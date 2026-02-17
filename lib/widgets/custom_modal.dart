import 'package:flutter/material.dart';

class CustomModal extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final bool isSuccess;
  final VoidCallback? onClose;
  final Duration? autoCloseDuration;

  const CustomModal({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.isSuccess = false,
    this.onClose,
    this.autoCloseDuration,
  });

  @override
  Widget build(BuildContext context) {
    // Auto-close si se especifica una duración
    if (autoCloseDuration != null) {
      Future.delayed(autoCloseDuration!, () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
          onClose?.call();
        }
      });
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono circular más pequeño
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),

            // Título más pequeño
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 6),

            // Mensaje con fuente más pequeña
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),

            // Botón de cerrar más pequeño
            if (!isSuccess) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: 120, // Ancho fijo más pequeño
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onClose?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(
                      100,
                      36,
                    ), // Tamaño mínimo más pequeño
                  ),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Extensión para facilitar el uso del modal
extension ModalExtension on BuildContext {
  void showCustomModal({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    bool isSuccess = false,
    VoidCallback? onClose,
    Duration? autoCloseDuration,
  }) {
    showDialog(
      context: this,
      barrierDismissible: !isSuccess,
      builder: (context) => CustomModal(
        title: title,
        message: message,
        icon: icon,
        color: color,
        isSuccess: isSuccess,
        onClose: onClose,
        autoCloseDuration: autoCloseDuration,
      ),
    );
  }
}
