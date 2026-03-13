import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/services/listar_pedidos_service.dart';
import 'package:super_pollo_app/models/listar_pedidos_model.dart';
import 'package:super_pollo_app/widgets/pedidos_widget.dart';

class GestionPedidosPage extends StatefulWidget {
  const GestionPedidosPage({super.key});

  @override
  State<GestionPedidosPage> createState() => _GestionPedidosPageState();
}

class _GestionPedidosPageState extends State<GestionPedidosPage> {
  int _selectedTab = 0; // 0: Todos, 1: Pendientes
  bool _isLoading = false;
  String? _errorMessage;
  List<Pedido> _allPedidos = [];

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  /// Obtiene la fecha y hora actual en los formatos requeridos
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

      final response = await PedidosService.listarPedidos(
        fecha: fecha,
        hora: hora,
      );

      if (mounted) {
        setState(() {
          if (response.ok) {
            _allPedidos = response.pedidos;
            _isLoading = false;
          } else {
            _errorMessage = 'Error al obtener pedidos';
            _isLoading = false;
          }
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

  /// Filtra pedidos según la pestaña seleccionada
  List<Pedido> _getPedidosFiltrados() {
    if (_selectedTab == 0) {
      return _allPedidos; // Todos
    } else {
      return _allPedidos
          .where((p) => p.estadoPedido == 'pendiente')
          .toList(); // Pendientes
    }
  }

  /// Muestra el modal con detalles del pedido
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
    final pedidosFiltrados = _getPedidosFiltrados();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () {
            context.go('/menu_principal');
          },
        ),
        centerTitle: true,
        title: const Text(
          'Gestión de Pedidos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          // Botón para refrescar
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
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

              // Pestañas Todos | Pendientes
              Row(
                children: [
                  _buildOrderTab('Todos (${_allPedidos.length})', 0),
                  const SizedBox(width: 16),
                  _buildOrderTab(
                    'Pendientes (${_allPedidos.where((p) => p.estadoPedido == 'pendiente').length})',
                    1,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Lista de pedidos
              OrderListWidget(
                pedidos: pedidosFiltrados,
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

  /// Widget para pestañas
  Widget _buildOrderTab(String text, int index) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
