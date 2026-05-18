import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/models/mesas_model.dart';
import 'package:super_pollo_app/models/mesas_response_model.dart';
import 'package:super_pollo_app/services/mesas_service.dart';
import 'package:super_pollo_app/theme/app_colors.dart';

class GestionMesasPage extends StatefulWidget {
  const GestionMesasPage({super.key});

  @override
  State<GestionMesasPage> createState() => _GestionMesasPageState();
}

class _GestionMesasPageState extends State<GestionMesasPage> {
  final MesasService _mesasService = MesasService();

  int _selectedFilter = 0;
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
    } catch (_) {
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

  // Los colores semánticos de estado NO cambian con el tema (son señales visuales)
  _EstadoConfig _getEstadoConfig(MesaModel mesa) {
    if (mesa.estadoLocal == 'ocupado') {
      return _EstadoConfig(
        label: 'Ocupada',
        color: AppColors.error,
        bgColor: const Color(0xFFFFEBEE),
        bgColorDark: const Color(0xFF3E0A0A),
        icon: Icons.block_rounded,
      );
    }
    if (mesa.estadoMesa == 'reservada') {
      return _EstadoConfig(
        label: 'Reservada',
        color: AppColors.warning,
        bgColor: const Color(0xFFFFF3E0),
        bgColorDark: const Color(0xFF3E2800),
        icon: Icons.event_busy_rounded,
      );
    }
    return _EstadoConfig(
      label: 'Disponible',
      color: AppColors.success,
      bgColor: const Color(0xFFE8F5E9),
      bgColorDark: const Color(0xFF0A2E0D),
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => GoRouter.of(context).canPop()
              ? GoRouter.of(context).pop()
              : GoRouter.of(context).go('/'),
        ),
        centerTitle: true,
        title: const Text('Gestión de Mesas'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header con acento de marca
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
                  'Estado de mesas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        letterSpacing: -0.3,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _cargarMesas,
                  icon: Icon(Icons.refresh_rounded, color: colorScheme.primary),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Filtros
            Row(
              children: [
                _buildFilterButton('Todas', 0, colorScheme, isDark),
                const SizedBox(width: 10),
                _buildFilterButton('Libres', 1, colorScheme, isDark),
                const SizedBox(width: 10),
                _buildFilterButton('Ocupadas', 2, colorScheme, isDark),
              ],
            ),

            const SizedBox(height: 20),

            // Contenido principal
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
                              const Icon(Icons.wifi_off_rounded,
                                  size: 48, color: AppColors.grey300),
                              const SizedBox(height: 12),
                              Text(_error!,
                                  style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: _cargarMesas,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        )
                      : _filteredMesas.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.table_restaurant_rounded,
                                    size: 48,
                                    color: AppColors.grey300,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No se encontraron mesas',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
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
                                return _buildMesaCard(
                                    mesa, config, unavailable, isDark);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mesa card ────────────────────────────────────────────────────────────────
  Widget _buildMesaCard(
    MesaModel mesa,
    _EstadoConfig config,
    bool unavailable,
    bool isDark,
  ) {
    final cardColor = unavailable
        ? (isDark ? AppColors.navyLight : AppColors.grey100)
        : (isDark ? AppColors.navyCard : Colors.white);
    final borderColor = unavailable
        ? config.color.withOpacity(0.4)
        : (isDark ? AppColors.navyLight : AppColors.grey100);
    final iconColor =
        unavailable ? config.color : (isDark ? AppColors.grey300 : AppColors.grey700);
    final stateBg = isDark ? config.bgColorDark : config.bgColor;

    return GestureDetector(
      onTap: () => _showTableDetails(mesa),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: borderColor, width: unavailable ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.table_restaurant_rounded, size: 28, color: iconColor),
              const SizedBox(height: 6),
              Text(
                mesa.nombre,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline_rounded,
                      size: 12, color: AppColors.grey500),
                  const SizedBox(width: 3),
                  Text(
                    '${mesa.capacidadMesa} personas',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stateBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(config.icon, size: 11, color: config.color),
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
              text,
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
    );
  }

  // ── Modal de detalles ────────────────────────────────────────────────────────
  Widget _buildTableDetailsModal(MesaModel mesa) {
    final config = _getEstadoConfig(mesa);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final colorScheme = Theme.of(context).colorScheme;
        final sheetBg = isDark ? AppColors.navyDeep : Colors.white;
        final cardBg = isDark ? AppColors.navyCard : Colors.white;
        final sectionBorderColor =
            isDark ? AppColors.navyLight : AppColors.grey100;
        final itemBg =
            isDark ? AppColors.navyLight : AppColors.grey100.withOpacity(0.6);
        final handleColor = isDark ? AppColors.navyLight : AppColors.grey100;
        final stateBg = isDark ? config.bgColorDark : config.bgColor;

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
                        color: handleColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Info de la mesa
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: stateBg,
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
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontSize: 22),
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
                                size: 16, color: AppColors.grey500),
                            const SizedBox(width: 6),
                            Text(
                              '${mesa.capacidadMesa} personas',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Pedidos
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sectionBorderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pedidos (3)',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        _buildOrderItem(context, '1x 1/4 de Pollo a la Brasa',
                            'S/ 14.00', itemBg),
                        const SizedBox(height: 8),
                        _buildOrderItem(context,
                            '2x Gaseosa Inka Kola Personal', 'S/ 4.00', itemBg),
                        const SizedBox(height: 8),
                        _buildOrderItem(
                            context, '1x Ensalada Mixta', 'S/ 8.00', itemBg),
                        const SizedBox(height: 16),
                        Divider(height: 1, color: sectionBorderColor),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontSize: 16),
                            ),
                            Text(
                              'S/ 26.00',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
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
                              color: AppColors.error
                                  .withOpacity(isDark ? 0.15 : 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.error, width: 1.5),
                            ),
                            child: const Center(
                              child: Text(
                                'Cerrar Mesa',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
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
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add,
                                      color: Colors.white, size: 20),
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

  Widget _buildOrderItem(
      BuildContext context, String itemName, String price, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              itemName,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            price,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Modelo de configuración de estado ────────────────────────────────────────
class _EstadoConfig {
  final String label;
  final Color color;
  final Color bgColor;     // fondo en light mode
  final Color bgColorDark; // fondo en dark mode
  final IconData icon;

  _EstadoConfig({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.bgColorDark,
    required this.icon,
  });
}