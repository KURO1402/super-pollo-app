import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/models/mesas_model.dart';
import 'package:super_pollo_app/models/mesas_response_model.dart';
import 'package:super_pollo_app/services/mesas_service.dart';
import 'package:super_pollo_app/state/pedido_flow_state.dart';
import 'package:super_pollo_app/widgets/mesa_card.dart';
import 'package:super_pollo_app/widgets/pedido_stepper.dart';
import 'package:super_pollo_app/theme/app_colors.dart';

class PedidoMesasPage extends StatefulWidget {
  final PedidoFlowState? flowState;
  const PedidoMesasPage({super.key, this.flowState});

  @override
  State<PedidoMesasPage> createState() => _PedidoMesasPageState();
}

class _PedidoMesasPageState extends State<PedidoMesasPage> {
  final MesasService _mesasService = MesasService();
  final TextEditingController _searchController = TextEditingController();

  int _selectedFilter = 0;
  late List<MesaModel> _mesasSeleccionadas;
  String _searchQuery = '';
  List<MesaModel> _mesas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mesasSeleccionadas = List.from(widget.flowState?.mesas ?? []);
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
      final MesasResponseModel response =
          await _mesasService.getMesasPedido(fecha, hora);
      setState(() {
        _mesas = response.mesas;
        _isLoading = false;
      });
    } catch (_) {
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
      resultado =
          resultado.where((m) => m.estadoMesa == 'disponible').toList();
    } else if (_selectedFilter == 2) {
      resultado =
          resultado.where((m) => m.estadoMesa != 'disponible').toList();
    }
    return resultado;
  }

  void _toggleMesa(MesaModel mesa) {
    setState(() {
      final yaSeleccionada =
          _mesasSeleccionadas.any((m) => m.idMesa == mesa.idMesa);
      if (yaSeleccionada) {
        _mesasSeleccionadas.removeWhere((m) => m.idMesa == mesa.idMesa);
      } else {
        _mesasSeleccionadas.add(mesa);
      }
    });
  }

  void _continuar() {
    final newState = PedidoFlowState(
      mesas: _mesasSeleccionadas,
      productos: widget.flowState?.productos ?? [],
    );
    context.push('/pedido_menu', extra: newState);
  }

  void _navigateToStep(int stepIndex) {
    final currentState = PedidoFlowState(
      mesas: _mesasSeleccionadas,
      productos: widget.flowState?.productos ?? [],
    );
    switch (stepIndex) {
      case 0:
        break;
      case 1:
        if (currentState.canGoToMenu) {
          context.push('/pedido_menu', extra: currentState);
        }
        break;
      case 2:
        if (currentState.canGoToResumen) {
          context.push('/pedido_resumen', extra: currentState);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final flowState = PedidoFlowState(
      mesas: _mesasSeleccionadas,
      productos: widget.flowState?.productos ?? [],
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => GoRouter.of(context).canPop()
              ? GoRouter.of(context).pop()
              : GoRouter.of(context).go('/menu_principal'),
        ),
        centerTitle: true,
        title: const Text('Nuevo Pedido'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: PedidoStepper(
            currentStep: 0,
            completedSteps: flowState.completedSteps,
            onStepTapped: _navigateToStep,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Título con acento de marca
            Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Seleccione una o más mesas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        letterSpacing: -0.3,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _SearchBar(
              controller: _searchController,
              searchQuery: _searchQuery,
              onChanged: (v) => setState(() => _searchQuery = v),
              onClear: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),

            const SizedBox(height: 16),

            _FilterRow(
              selectedFilter: _selectedFilter,
              onFilterSelected: (i) => setState(() => _selectedFilter = i),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: _MesasGrid(
                isLoading: _isLoading,
                error: _error,
                mesas: _filteredMesas,
                mesasSeleccionadas: _mesasSeleccionadas,
                onRetry: _cargarMesas,
                onToggleMesa: _toggleMesa,
              ),
            ),

            const SizedBox(height: 16),

            if (_mesasSeleccionadas.isNotEmpty)
              _MesasSeleccionadasChip(
                mesasSeleccionadas: _mesasSeleccionadas,
              ),

            _ContinuarButton(
              enabled: _mesasSeleccionadas.isNotEmpty,
              onPressed: _continuar,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Barra de búsqueda ─────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = isDark ? AppColors.navyCard : Colors.white;
    final borderColor = isDark ? AppColors.navyLight : const Color(0xFFE8E8E8);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Buscar por número de mesa...',
          hintStyle:
              const TextStyle(color: AppColors.grey300, fontSize: 15),
          prefixIcon:
              Icon(Icons.search_rounded, color: colorScheme.primary, size: 22),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.grey300, size: 20),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        ),
      ),
    );
  }
}

// ── Filtros ───────────────────────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final int selectedFilter;
  final ValueChanged<int> onFilterSelected;

  const _FilterRow({
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const filters = ['Todas', 'Libres', 'Ocupadas'];

    return Row(
      children: List.generate(filters.length, (i) {
        final isSelected = selectedFilter == i;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < filters.length - 1 ? 10 : 0),
            child: GestureDetector(
              onTap: () => onFilterSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : (isDark ? AppColors.navyLight : AppColors.grey100),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    filters[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.grey300 : AppColors.grey500),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Grid de mesas ─────────────────────────────────────────────────────────────
class _MesasGrid extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final List<MesaModel> mesas;
  final List<MesaModel> mesasSeleccionadas;
  final VoidCallback onRetry;
  final ValueChanged<MesaModel> onToggleMesa;

  const _MesasGrid({
    required this.isLoading,
    required this.error,
    required this.mesas,
    required this.mesasSeleccionadas,
    required this.onRetry,
    required this.onToggleMesa,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.grey300),
            const SizedBox(height: 12),
            Text(error!, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (mesas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.table_restaurant_rounded,
                size: 48, color: AppColors.grey300),
            const SizedBox(height: 12),
            Text('No se encontraron mesas',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.3,
      ),
      itemCount: mesas.length,
      itemBuilder: (context, index) {
        final mesa = mesas[index];
        return MesaCard(
          mesa: mesa,
          isSelected:
              mesasSeleccionadas.any((m) => m.idMesa == mesa.idMesa),
          onTap: () => onToggleMesa(mesa),
        );
      },
    );
  }
}

// ── Chip de mesas seleccionadas ───────────────────────────────────────────────
class _MesasSeleccionadasChip extends StatelessWidget {
  final List<MesaModel> mesasSeleccionadas;
  const _MesasSeleccionadasChip({required this.mesasSeleccionadas});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.table_restaurant_rounded,
              color: colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mesasSeleccionadas.map((m) => m.nombre).join(', '),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${mesasSeleccionadas.length}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botón continuar ───────────────────────────────────────────────────────────
class _ContinuarButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;
  const _ContinuarButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Usa el ElevatedButton del tema directamente — hereda colores y shape
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Continuar'),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}