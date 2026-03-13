import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/models/mesas_model.dart';
import 'package:super_pollo_app/models/mesas_response_model.dart';
import 'package:super_pollo_app/services/mesas_service.dart';
import 'package:super_pollo_app/widgets/mesa_card.dart';

class PedidoMesasPage extends StatefulWidget {
  const PedidoMesasPage({super.key});

  @override
  State<PedidoMesasPage> createState() => _PedidoMesasPageState();
}

class _PedidoMesasPageState extends State<PedidoMesasPage> {
  final MesasService _mesasService = MesasService();
  final TextEditingController _searchController = TextEditingController();

  int _selectedFilter = 0;
  List<MesaModel> _mesasSeleccionadas = [];
  String _searchQuery = '';
  List<MesaModel> _mesas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarMesas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

      final MesasResponseModel response = await _mesasService.getMesasPedido(
        fecha,
        hora,
      );

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
    List<MesaModel> resultado = _mesas;

    if (_searchQuery.isNotEmpty) {
      resultado = resultado
          .where((m) => m.numeroMesa.toString().contains(_searchQuery))
          .toList();
    }

    if (_selectedFilter == 1) {
      resultado = resultado.where((m) => m.estadoMesa == 'disponible').toList();
    } else if (_selectedFilter == 2) {
      resultado = resultado.where((m) => m.estadoMesa != 'disponible').toList();
    }

    return resultado;
  }

  void _toggleMesa(MesaModel mesa) {
    setState(() {
      final yaSeleccionada = _mesasSeleccionadas.any(
        (m) => m.idMesa == mesa.idMesa,
      );
      if (yaSeleccionada) {
        _mesasSeleccionadas.removeWhere((m) => m.idMesa == mesa.idMesa);
      } else {
        _mesasSeleccionadas.add(mesa);
      }
    });
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
          'Nuevo Pedido',
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
                  'Seleccione una o más mesas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Buscador
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E8E8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
                decoration: InputDecoration(
                  hintText: 'Buscar por número de mesa...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF1565C0),
                    size: 22,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFFAAAAAA),
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 4,
                  ),
                ),
              ),
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
                            style: const TextStyle(color: Color(0xFF757575)),
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
                        return MesaCard(
                          mesa: mesa,
                          isSelected: _mesasSeleccionadas.any(
                            (m) => m.idMesa == mesa.idMesa,
                          ),
                          onTap: () => _toggleMesa(mesa),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // Chip mesas seleccionadas
            if (_mesasSeleccionadas.isNotEmpty)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF1565C0).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.table_restaurant_rounded,
                      color: Color(0xFF1565C0),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _mesasSeleccionadas.map((m) => m.nombre).join(', '),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1565C0),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_mesasSeleccionadas.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Botón continuar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push("/pedido_menu", extra: _mesasSeleccionadas);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: const Color(0xFFBDBDBD),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: _mesasSeleccionadas.isNotEmpty ? 4 : 0,
                  shadowColor: const Color(0xFF1565C0).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
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
}
