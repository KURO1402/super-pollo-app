import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/models/detalle_pedido_model.dart';
import 'package:super_pollo_app/models/notificacion_model.dart';
import 'package:super_pollo_app/services/detalle_pedido_service.dart';
import 'package:super_pollo_app/utils/notificaciones_state.dart';
import 'package:super_pollo_app/theme/app_colors.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPage();
}

class _NotificacionesPage extends State<NotificacionesPage> {
  int _selectedFilter = 0;
  final NotificacionesState _notifState = NotificacionesState();
  final DetallePedidoService _detalleService = DetallePedidoService();

  @override
  void initState() {
    super.initState();
    _notifState.addListener(_actualizar);
    _notifState.limpiarConteo();
  }

  @override
  void dispose() {
    _notifState.removeListener(_actualizar);
    super.dispose();
  }

  void _actualizar() => setState(() {});
  void _limpiarTodo() => _notifState.limpiarTodo();

  List<NotificacionModel> get _filtradas {
    switch (_selectedFilter) {
      case 1:
        return _notifState.notificaciones
            .where((n) => n.tipo == 'agregar')
            .toList();
      case 2:
        return _notifState.notificaciones
            .where((n) => n.tipo == 'editar')
            .toList();
      case 3:
        return _notifState.notificaciones
            .where((n) => n.tipo == 'cancelar')
            .toList();
      default:
        return _notifState.notificaciones;
    }
  }

  void _verDetalle(int idPedido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetallePedidoModal(
        idPedido: idPedido,
        detalleService: _detalleService,
      ),
    );
  }

  // Colores semánticos — no cambian con el tema, son señales visuales
  _TipoConfig _getConfig(String tipo) {
    switch (tipo) {
      case 'editar':
        return _TipoConfig(
          color: AppColors.warning,
          icon: Icons.edit_outlined,
          label: 'Modificado',
          accion: 'Ver Detalles',
        );
      case 'cancelar':
        return _TipoConfig(
          color: AppColors.error,
          icon: Icons.cancel_outlined,
          label: 'Cancelado',
          accion: 'Ver Detalles',
        );
      default:
        return _TipoConfig(
          color: AppColors.info,
          icon: Icons.receipt_long_outlined,
          label: 'Nuevo Pedido',
          accion: 'Ver Detalles',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? AppColors.navyLight : AppColors.grey100;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => GoRouter.of(context).canPop()
              ? GoRouter.of(context).pop()
              : GoRouter.of(context).go('/'),
        ),
        centerTitle: true,
        title: const Text('Notificaciones'),
        actions: [
          TextButton(
            onPressed: _limpiarTodo,
            child: Text(
              'Limpiar todo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Filtros
              Row(
                children: [
                  _buildFilterButton('Todas', 0, colorScheme, isDark),
                  const SizedBox(width: 8),
                  _buildFilterButton('Nuevos', 1, colorScheme, isDark),
                  const SizedBox(width: 8),
                  _buildFilterButton('Editados', 2, colorScheme, isDark),
                  const SizedBox(width: 8),
                  _buildFilterButton('Cancelados', 3, colorScheme, isDark),
                ],
              ),

              const SizedBox(height: 24),
              Divider(height: 1, color: dividerColor),
              const SizedBox(height: 16),

              Text(
                'Hoy',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Divider(height: 1, color: dividerColor),
              const SizedBox(height: 16),

              _filtradas.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            const Icon(Icons.notifications_off_outlined,
                                size: 48, color: AppColors.grey300),
                            const SizedBox(height: 12),
                            Text(
                              'No hay notificaciones',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: _filtradas.asMap().entries.map((entry) {
                        final index = entry.key;
                        final notif = entry.value;
                        return Column(
                          children: [
                            _buildNotificationCard(notif, isDark),
                            if (index < _filtradas.length - 1)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Divider(height: 1, color: dividerColor),
                              ),
                          ],
                        );
                      }).toList(),
                    ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Filtros ──────────────────────────────────────────────────────────────────
  Widget _buildFilterButton(
      String text, int index, ColorScheme colorScheme, bool isDark) {
    final isSelected = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : (isDark ? AppColors.navyLight : AppColors.grey300),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.grey300 : AppColors.grey700),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Card de notificación ──────────────────────────────────────────────────────
  Widget _buildNotificationCard(NotificacionModel notif, bool isDark) {
    final config = _getConfig(notif.tipo);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + tiempo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: config.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(config.icon, size: 16, color: config.color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        notif.titulo,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                notif.tiempoRelativo,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),

          if (notif.contenido.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              notif.contenido,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 14),
            ),
          ],

          if (notif.nota.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Nota: ${notif.nota}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],

          const SizedBox(height: 12),

          // Badge + botón acción
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: config.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  config.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: config.color,
                  ),
                ),
              ),
              const Spacer(),
              if (notif.idPedido != null)
                GestureDetector(
                  onTap: () => _verDetalle(notif.idPedido!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: config.color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: config.color, width: 1.5),
                    ),
                    child: Text(
                      config.accion,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: config.color,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Modal de detalle ─────────────────────────────────────────────────────────

class _DetallePedidoModal extends StatefulWidget {
  final int idPedido;
  final DetallePedidoService detalleService;

  const _DetallePedidoModal({
    required this.idPedido,
    required this.detalleService,
  });

  @override
  State<_DetallePedidoModal> createState() => _DetallePedidoModalState();
}

class _DetallePedidoModalState extends State<_DetallePedidoModal> {
  bool _isLoading = true;
  String? _error;
  DetallePedidoModel? _detalle;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    try {
      final detalle =
          await widget.detalleService.getDetallePedido(widget.idPedido);
      setState(() {
        _detalle = detalle;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Error al cargar el detalle del pedido';
        _isLoading = false;
      });
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'completado':
        return AppColors.success;
      case 'cancelado':
        return AppColors.error;
      case 'en_proceso':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final sheetBg = isDark ? AppColors.navyCard : Colors.white;
    final handleColor = isDark ? AppColors.navyLight : AppColors.grey100;
    final dividerColor = isDark ? AppColors.navyLight : AppColors.grey100;
    final itemBg = isDark
        ? AppColors.navyLight
        : AppColors.grey100.withOpacity(0.5);
    final itemBorderColor = isDark ? AppColors.navyLight : AppColors.grey100;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
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
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Text(
                      'Detalle del Pedido',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontSize: 18),
                    ),
                    const Spacer(),
                    Text(
                      '#${widget.idPedido}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: dividerColor),

              // Contenido
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: colorScheme.primary),
                      )
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 48, color: AppColors.grey300),
                                const SizedBox(height: 12),
                                Text(_error!,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                const SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: _cargarDetalle,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Estado
                                Row(
                                  children: [
                                    Text(
                                      'Estado: ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 14),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _colorEstado(
                                                _detalle!.estadoPedido)
                                            .withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _detalle!.estadoPedido.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _colorEstado(
                                              _detalle!.estadoPedido),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Mesas
                                Row(
                                  children: [
                                    Icon(Icons.table_restaurant_rounded,
                                        size: 18, color: colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Mesas: ${_detalle!.mesas.map((m) => 'Mesa ${m.numeroMesa}').join(', ')}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Productos
                                Text(
                                  'Productos',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontSize: 16),
                                ),
                                const SizedBox(height: 12),

                                ..._detalle!.detalle.map((item) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: itemBg,
                                      borderRadius: BorderRadius.circular(10),
                                      border:
                                          Border.all(color: itemBorderColor),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary
                                                .withOpacity(0.10),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${item.cantidadPedido}x',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            item.nombreProducto,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class _TipoConfig {
  final Color color;
  final IconData icon;
  final String label;
  final String accion;

  _TipoConfig({
    required this.color,
    required this.icon,
    required this.label,
    required this.accion,
  });
}