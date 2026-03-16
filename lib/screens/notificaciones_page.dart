import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/models/notificacion_model.dart';
import 'package:super_pollo_app/utils/notificaciones_state.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPage();
}

class _NotificacionesPage extends State<NotificacionesPage> {
  int _selectedFilter = 0;
  final NotificacionesState _notifState = NotificacionesState();

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
            .where((n) => n.tipo == 'pedido')
            .toList();
      case 2:
        return _notifState.notificaciones
            .where((n) => n.tipo == 'pago')
            .toList();
      default:
        return _notifState.notificaciones;
    }
  }

  _TipoConfig _getConfig(String tipo) {
    switch (tipo) {
      case 'pago':
        return _TipoConfig(
          color: Colors.green,
          icon: Icons.payments_outlined,
          accion: 'Ver Recibo',
        );
      case 'retraso':
        return _TipoConfig(
          color: Colors.orange,
          icon: Icons.timer_off_outlined,
          accion: 'Ver Detalles',
        );
      default:
        return _TipoConfig(
          color: Colors.blue,
          icon: Icons.receipt_long_outlined,
          accion: 'Ver Detalles',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              GoRouter.of(context).go('/');
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _limpiarTodo,
            child: const Text(
              'Limpiar todo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
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
                  _buildFilterButton('Todas', 0),
                  const SizedBox(width: 12),
                  _buildFilterButton('Pedidos', 1),
                  const SizedBox(width: 12),
                  _buildFilterButton('Pagados', 2),
                ],
              ),

              const SizedBox(height: 24),
              Container(height: 1, color: Colors.grey.shade300),
              const SizedBox(height: 16),

              const Text(
                'Hoy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(height: 1, color: Colors.grey.shade300),
              const SizedBox(height: 16),

              // Lista de notificaciones
              _filtradas.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 48,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No hay notificaciones',
                              style: TextStyle(color: Colors.grey.shade500),
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
                            _buildNotificationCard(notif),
                            if (index < _filtradas.length - 1)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(
                                  height: 1,
                                  color: Color(0xFFE0E0E0),
                                ),
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

  Widget _buildFilterButton(String text, int index) {
    final isSelected = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = index),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificacionModel notif) {
    final config = _getConfig(notif.tipo);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(config.icon, size: 18, color: config.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notif.titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                notif.tiempoRelativo,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notif.contenido,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
          ),
          if (notif.nota.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Nota: ${notif.nota}',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade700,
              ),
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              // TODO: navegar según tipo e idPedido/idMesa
            },
            child: Container(
              width: double.infinity,
              height: 36,
              decoration: BoxDecoration(
                color: config.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: config.color, width: 1.5),
              ),
              child: Center(
                child: Text(
                  config.accion,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: config.color,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipoConfig {
  final Color color;
  final IconData icon;
  final String accion;

  _TipoConfig({
    required this.color,
    required this.icon,
    required this.accion,
  });
}