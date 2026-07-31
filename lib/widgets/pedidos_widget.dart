import 'package:flutter/material.dart';
import 'package:super_pollo_app/models/listar_pedidos_model.dart';
import 'package:super_pollo_app/services/cancelar_pedido_service.dart';
import 'package:super_pollo_app/theme/app_colors.dart';
import 'package:super_pollo_app/utils/pedidos_state.dart';

// ── OrderCardWidget ───────────────────────────────────────────────────────────
class OrderCardWidget extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onTap;

  const OrderCardWidget({super.key, required this.pedido, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = isDark ? AppColors.navyCard : Colors.white;
    final borderColor = isDark ? AppColors.navyLight : const Color(0xFFEEEEEE);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Número de mesa
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.table_restaurant_rounded,
                        size: 16, color: colorScheme.primary),
                    const SizedBox(height: 2),
                    Text(
                      pedido.mesaPrincipal,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Info del pedido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mesas: ${pedido.mesas.join(', ')}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            letterSpacing: -0.3,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: pedido.colorEstado.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            pedido.estadoLabel,
                            style: TextStyle(
                              fontSize: 11,
                              color: pedido.colorEstado,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${pedido.totalItems} ${pedido.totalItems == 1 ? 'item' : 'items'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      pedido.tiempoDesdeActualizacion,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),

              // Monto + flecha
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'S/ ${pedido.precioPrecuenta}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? AppColors.grey500 : AppColors.grey300,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── OrderDetailsModal ─────────────────────────────────────────────────────────
class OrderDetailsModal extends StatefulWidget {
  final Pedido pedido;
  final VoidCallback? onEditarPedido;
  final VoidCallback? onPedidoCancelado;

  const OrderDetailsModal({
    super.key,
    required this.pedido,
    this.onEditarPedido,
    this.onPedidoCancelado,
  });

  @override
  State<OrderDetailsModal> createState() => _OrderDetailsModalState();
}

class _OrderDetailsModalState extends State<OrderDetailsModal> {
  final _cancelarService = CancelarPedidoService();
  bool _isCanceling = false;

  Pedido get pedido => widget.pedido;

  Future<void> _cancelarPedido(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.navyCard : Colors.white;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '¿Cancelar pedido?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
        ),
        content: Text(
          'Esta acción no se puede deshacer. ¿Deseas cancelar el pedido #${pedido.idPedido}?',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx, false),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.navyLight : AppColors.grey100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Volver',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx, true),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Sí, cancelar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmar != true || !context.mounted) return;

    setState(() => _isCanceling = true);
    try {
      final response = await _cancelarService.cancelarPedido(pedido.idPedido);
      if (!context.mounted) return;
      if (response.ok) {
        Navigator.pop(context); // cierra el modal
        widget.onPedidoCancelado?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.mensaje.isNotEmpty
                ? response.mensaje
                : 'Pedido cancelado correctamente'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.mensaje.isNotEmpty
                ? response.mensaje
                : 'No se pudo cancelar el pedido'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCanceling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final sheetBg = isDark ? AppColors.navyDeep : const Color(0xFFFAFAFA);
    final sectionBg = isDark ? AppColors.navyCard : Colors.white;
    final handleColor = isDark ? AppColors.navyLight : const Color(0xFFE0E0E0);
    final dividerColor = isDark ? AppColors.navyLight : const Color(0xFFF0F0F0);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 6),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: handleColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                // Header
                Container(
                  color: sectionBg,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mesas: ${pedido.mesas.join(', ')}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontSize: 22,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pedido #${pedido.idPedido}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: pedido.colorEstado.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: pedido.colorEstado.withOpacity(0.4)),
                            ),
                            child: Text(
                              pedido.estadoLabel.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: pedido.colorEstado,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.shopping_bag_outlined,
                            label:
                                '${pedido.totalItems} ${pedido.totalItems == 1 ? 'item' : 'items'}',
                          ),
                          const SizedBox(width: 10),
                          _InfoChip(
                            icon: Icons.access_time_rounded,
                            label: pedido.tiempoDesdeActualizacion,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Productos
                Container(
                  color: sectionBg,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 18, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Productos',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      for (var i = 0; i < pedido.detalles.length; i++) ...[
                        _buildOrderItemWidget(context, pedido.detalles[i],
                            colorScheme, isDark),
                        if (i < pedido.detalles.length - 1)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1, color: dividerColor),
                          ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Total
                Container(
                  color: sectionBg,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total a pagar',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 16),
                      ),
                      Text(
                        'S/ ${pedido.precioPrecuenta}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Botones de acción
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Cerrar
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.navyLight
                                      : AppColors.grey100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'Cerrar',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Editar — solo si el pedido puede editarse
                          if (pedido.puedeEditarse) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onEditarPedido?.call();
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.edit_outlined,
                                            color: Colors.white, size: 16),
                                        SizedBox(width: 6),
                                        Text(
                                          'Editar',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Cancelar — solo si el pedido puede editarse
                      if (pedido.puedeEditarse) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _isCanceling
                              ? null
                              : () => _cancelarPedido(context),
                          child: Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(
                                  isDark ? 0.15 : 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: Center(
                              child: _isCanceling
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: AppColors.error,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.cancel_outlined,
                                            color: AppColors.error, size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          'Cancelar pedido',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildOrderItemWidget(
    BuildContext context,
    DetallePedido detalle,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '${detalle.cantidadPedido}x',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            detalle.nombreProducto,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500, fontSize: 15),
          ),
        ),
        Text(
          'S/ ${detalle.subtotal}',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyLight : AppColors.grey100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.grey500),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class OrderListWidget extends StatelessWidget {
  final List<Pedido> pedidos;
  final bool isLoading;
  final String? errorMessage;
  final Function(Pedido) onOrderTap;

  const OrderListWidget({
    super.key,
    required this.pedidos,
    required this.isLoading,
    this.errorMessage,
    required this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.grey300),
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (pedidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 48, color: AppColors.grey300),
            const SizedBox(height: 12),
            Text(
              'No hay pedidos disponibles',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < pedidos.length; i++)
          Column(
            children: [
              OrderCardWidget(
                pedido: pedidos[i],
                onTap: () => onOrderTap(pedidos[i]),
              ),
              if (i < pedidos.length - 1) const SizedBox(height: 12),
            ],
          ),
      ],
    );
  }
}