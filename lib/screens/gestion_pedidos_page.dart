import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/services/listar_pedidos_service.dart';
import 'package:super_pollo_app/models/listar_pedidos_model.dart';
import 'package:super_pollo_app/widgets/pedidos_widget.dart';
import 'package:super_pollo_app/theme/app_colors.dart';

class GestionPedidosPage extends StatefulWidget {
  const GestionPedidosPage({super.key});

  @override
  State<GestionPedidosPage> createState() => _GestionPedidosPageState();
}

class _GestionPedidosPageState extends State<GestionPedidosPage> {
  int _selectedTab = 0;
  bool _isLoading = false;
  String? _errorMessage;
  List<Pedido> _allPedidos = [];

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  void _cargarPedidos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final ahora = DateTime.now();
      final fecha =
          '${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}';
      final hora =
          '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';
      final response = await PedidosService.listarPedidos(fecha: fecha, hora: hora);
      if (mounted) {
        setState(() {
          if (response.ok) {
            _allPedidos = response.pedidos;
          } else {
            _errorMessage = 'Error al obtener pedidos';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  List<Pedido> _getPedidosFiltrados() => _selectedTab == 0
      ? _allPedidos
      : _allPedidos.where((p) => p.estadoPedido == 'pendiente').toList();

  void _showOrderDetails(Pedido pedido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsModal(pedido: pedido),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendientesCount =
        _allPedidos.where((p) => p.estadoPedido == 'pendiente').length;

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
            onPressed: _cargarPedidos,
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
                  _buildOrderTab(
                    'Todos (${_allPedidos.length})',
                    0,
                    colorScheme,
                    isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildOrderTab(
                    'Pendientes ($pendientesCount)',
                    1,
                    colorScheme,
                    isDark,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              OrderListWidget(
                pedidos: _getPedidosFiltrados(),
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                onOrderTap: _showOrderDetails,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTab(
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