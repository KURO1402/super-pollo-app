import 'package:flutter/material.dart';
import 'package:super_pollo_app/main.dart';
import 'package:super_pollo_app/models/notificacion_model.dart';

class NotificacionBanner {
  static void mostrar(NotificacionModel notif) {
    Color color;
    IconData icon;
    String subtitulo;

    switch (notif.tipo) {
      case 'editar':
        color = Colors.orange;
        icon = Icons.edit_outlined;
        subtitulo = 'Un pedido fue modificado';
        break;
      case 'cancelar':
        color = Colors.red;
        icon = Icons.cancel_outlined;
        subtitulo = 'Un pedido fue cancelado';
        break;
      default: // agregar
        color = const Color(0xFF1565C0);
        icon = Icons.receipt_long_outlined;
        subtitulo = 'Se registró un nuevo pedido';
    }

    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        // margin con top alto para que aparezca en la parte superior
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(
                scaffoldMessengerKey.currentContext!,
              ).size.height -
              160,
        ),
        padding: EdgeInsets.zero,
        content: GestureDetector(
          onTap: () {
            scaffoldMessengerKey.currentState?.clearSnackBars();
            router.push('/notificaciones'); // ← navega a notificaciones al tocar
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        notif.titulo,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitulo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}