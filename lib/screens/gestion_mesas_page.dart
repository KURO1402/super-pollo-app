import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/models/mesas_model.dart';
import 'package:super_pollo_app/models/mesas_response_model.dart';
import 'package:super_pollo_app/services/mesas_service.dart';

class GestionMesasPage extends StatefulWidget {
  const GestionMesasPage({super.key});

  @override
  State<GestionMesasPage> createState() => _GestionMesasPageState();
}

class _GestionMesasPageState extends State<GestionMesasPage> {
  final MesasService _mesasService = MesasService();

  int _selectedFilter = 0; // 0: Todas, 1: Libres, 2: Ocupadas
  List<MesaModel> _mesas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarMesas();
  }

  Future<void> _cargarMesas() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final now = DateTime.now();
      final fecha =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final hora =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final MesasResponseModel response =
          await _mesasService.getMesasPedido(fecha, hora);

      setState(() {
        _mesas = response.mesas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar las mesas';
        _isLoading = false;
      });
    }
  }

  List<MesaModel> get _filteredMesas {
    switch (_selectedFilter) {
      case 1:
        return _mesas
            .where((m) =>
                m.estadoLocal == 'disponible' && m.estadoMesa != 'reservada')
            .toList();
      case 2:
        return _mesas
            .where((m) =>
                m.estadoLocal == 'ocupado' || m.estadoMesa == 'reservada')
            .toList();
      default:
        return _mesas;
    }
  }

  bool _isUnavailable(MesaModel mesa) =>
      mesa.estadoLocal == 'ocupado' || mesa.estadoMesa == 'reservada';

  _EstadoConfig _getEstadoConfig(MesaModel mesa) {
    if (mesa.estadoLocal == 'ocupado') {
      return _EstadoConfig(
        label: 'Ocupada',
        color: const Color(0xFFE53935),
        bgColor: const Color(0xFFFFEBEE),
        icon: Icons.block_rounded,
      );
    }
    if (mesa.estadoMesa == 'reservada') {
      return _EstadoConfig(
        label: 'Reservada',
        color: const Color(0xFFE67E22),
        bgColor: const Color(0xFFFFF3E0),
        icon: Icons.event_busy_rounded,
      );
    }
    return _EstadoConfig(
      label: 'Disponible',
      color: const Color(0xFF2E7D32),
      bgColor: const Color(0xFFE8F5E9),
      icon: Icons.check_circle_outline_rounded,
    );
  }

  void _showTableDetails(MesaModel mesa) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTableDetailsModal(mesa),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1A1A1A),
            size: 20,
          ),
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
          'Gestión de Mesas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Estado de mesas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                // Botón refrescar
                IconButton(
                  onPressed: _cargarMesas,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Filtros
            Row(
              children: [
                _buildFilterButton('Todas', 0),
                const SizedBox(width: 10),
                _buildFilterButton('Libres', 1),
                const SizedBox(width: 10),
                _buildFilterButton('Ocupadas', 2),
              ],
            ),

            const SizedBox(height: 20),

            // Grid
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1565C0),
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wifi_off_rounded,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                style:
                                    const TextStyle(color: Color(0xFF757575)),
                              ),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: _cargarMesas,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Reintentar'),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF1565C0),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _filteredMesas.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.table_restaurant_rounded,
                                    size: 48,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No se encontraron mesas',
                                    style: TextStyle(color: Color(0xFF9E9E9E)),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 1.3,
                              ),
                              itemCount: _filteredMesas.length,
                              itemBuilder: (context, index) {
                                final mesa = _filteredMesas[index];
                                final config = _getEstadoConfig(mesa);
                                final unavailable = _isUnavailable(mesa);

                                return GestureDetector(
                                  onTap: () => _showTableDetails(mesa),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: unavailable
                                          ? const Color(0xFFF5F5F5)
                                          : Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      border: Border.all(
                                        color: unavailable
                                            ? config.color.withOpacity(0.4)
                                            : const Color(0xFFE8E8E8),
                                        width: unavailable ? 1.5 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.black.withOpacity(0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.table_restaurant_rounded,
                                            size: 28,
                                            color: unavailable
                                                ? config.color
                                                : const Color(0xFF424242),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            mesa.nombre,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.3,
                                              color: unavailable
                                                  ? const Color(0xFF1A1A1A)
                                                  : const Color(0xFF1A1A1A),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.person_outline_rounded,
                                                size: 12,
                                                color: const Color(0xFF757575),
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                '${mesa.capacidadMesa} personas',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF757575),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: config.bgColor,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(config.icon,
                                                    size: 11,
                                                    color: config.color),
                                                const SizedBox(width: 4),
                                                Text(
                                                  config.label,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: config.color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, int index) {
    final isSelected = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1565C0)
                : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF757575),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableDetailsModal(MesaModel mesa) {
    final config = _getEstadoConfig(mesa);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info mesa
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: config.bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: config.color.withOpacity(0.4), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              mesa.nombre,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: config.color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(config.icon,
                                      size: 13, color: config.color),
                                  const SizedBox(width: 4),
                                  Text(
                                    config.label.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: config.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              '${mesa.capacidadMesa} personas',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Pedidos (datos de prueba)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pedidos (3)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildOrderItem('1x 1/4 de Pollo a la Brasa',
                            'S/ 14.00'),
                        const SizedBox(height: 8),
                        _buildOrderItem(
                            '2x Gaseosa Inka Kola Personal', 'S/ 4.00'),
                        const SizedBox(height: 8),
                        _buildOrderItem('1x Ensalada Mixta', 'S/ 8.00'),
                        const SizedBox(height: 16),
                        Container(height: 1, color: Colors.grey.shade200),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const Text(
                              'S/ 26.00',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: Colors.red, width: 1.5),
                            ),
                            child: const Center(
                              child: Text(
                                'Cerrar Mesa',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Agregar',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
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
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderItem(String itemName, String price) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              itemName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoConfig {
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;

  _EstadoConfig({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
  });
}