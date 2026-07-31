import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/models/listar_pedidos_model.dart';
import 'package:super_pollo_app/widgets/pedidos_widget.dart';
import 'package:super_pollo_app/utils/pedidos_state.dart';
import 'package:super_pollo_app/theme/app_colors.dart';

class GestionPedidosPage extends StatefulWidget {
  const GestionPedidosPage({super.key});

  @override
  State<GestionPedidosPage> createState() => _GestionPedidosPageState();
}

class _GestionPedidosPageState extends State<GestionPedidosPage> {
  int _selectedTab = 0;
  final PedidosState _pedidosState = PedidosState();

  @override
  void initState() {
    super.initState();
    _pedidosState.addListener(_actualizar);
    _pedidosState.cargar();
  }

  @override
  void dispose() {
    _pedidosState.removeListener(_actualizar);
    super.dispose();
  }

  void _actualizar() => setState(() {});

  List<Pedido> get _pedidosFiltrados => _selectedTab == 0
      ? _pedidosState.pedidos
      : _pedidosState.pedidos
          .where((p) => p.estadoPedido == 'pendiente')
          .toList();

  void _showOrderDetails(Pedido pedido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsModal(
        pedido: pedido,
        onEditarPedido: () => _pedidosState.cargar(),
        onPedidoCancelado: () => _pedidosState.cargar(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todos = _pedidosState.pedidos;
    final pendientesCount =
        todos.where((p) => p.estadoPedido == 'pendiente').length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => context.go('/menu_principal'),
        ),
        centerTitle: true,
        title: const Text('Gestión de Pedidos'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            onPressed: () => _pedidosState.cargar(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Pestañas
              Row(
                children: [
                  _buildTab('Todos (${todos.length})', 0, colorScheme, isDark),
                  const SizedBox(width: 16),
                  _buildTab(
                      'Pendientes ($pendientesCount)', 1, colorScheme, isDark),
                ],
              ),

              const SizedBox(height: 24),

              OrderListWidget(
                pedidos: _pedidosFiltrados,
                isLoading: _pedidosState.isLoading,
                errorMessage: _pedidosState.error,
                onOrderTap: _showOrderDetails,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
      String text, int index, ColorScheme colorScheme, bool isDark) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary
                : (isDark ? AppColors.navyLight : AppColors.grey100),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
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
}