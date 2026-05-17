import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/models/categorias_model.dart';
import 'package:super_pollo_app/models/productos_model.dart';
import 'package:super_pollo_app/services/categorias_service.dart';
import 'package:super_pollo_app/services/productos_service.dart';
import 'package:super_pollo_app/state/pedido_flow_state.dart';
import 'package:super_pollo_app/widgets/button_categorias.dart';
import 'package:super_pollo_app/widgets/pedido_stepper.dart';
import 'package:super_pollo_app/theme/app_colors.dart';
import '../widgets/menu_item.dart';

class PedidoMenuPage extends StatefulWidget {
  final PedidoFlowState flowState;
  const PedidoMenuPage({super.key, required this.flowState});

  @override
  State<PedidoMenuPage> createState() => _PedidoMenuPageState();
}

class _PedidoMenuPageState extends State<PedidoMenuPage> {
  int? _categoriaSeleccionada;
  final ProductosService _productosService = ProductosService();
  late Future<List<ProductoModel>> _productosList;

  final CategoriasService _categoriasService = CategoriasService();
  late Future<List<CategoriaModel>> _categoriasList;

  final Map<int, int> _cantidades = {};
  List<ProductoModel> _todosLosProductos = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _restaurarProductosPrevios();
    _productosList = _cargaInicial();
    _categoriasList = _cargaCategorias();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _restaurarProductosPrevios() {
    for (final p in widget.flowState.productos) {
      final id = p['idProducto'] as int?;
      final cantidad = p['cantidad'] as int?;
      if (id != null && cantidad != null) _cantidades[id] = cantidad;
    }
  }

  Future<List<ProductoModel>> _cargaInicial() async {
    try {
      final lista =
          await _productosService.getProductos(categoriaId: _categoriaSeleccionada);
      for (final p in lista) {
        if (!_todosLosProductos.any((e) => e.id == p.id)) {
          _todosLosProductos.add(p);
        }
      }
      return lista;
    } catch (_) {
      throw Exception("Error al cargar productos.");
    }
  }

  Future<List<CategoriaModel>> _cargaCategorias() async {
    try {
      return await _categoriasService.getCategorias();
    } catch (_) {
      throw Exception("Error al cargar las categorias");
    }
  }

  void _seleccionarCategoria(int? idCategoria) {
    setState(() {
      _categoriaSeleccionada = idCategoria;
      _searchQuery = '';
      _searchController.clear();
      _productosList = _cargaInicial();
    });
  }

  void _onSearchChanged(String value) =>
      setState(() => _searchQuery = value.trim().toLowerCase());

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  List<ProductoModel> _filtrar(List<ProductoModel> productos) {
    if (_searchQuery.isEmpty) return productos;
    return productos.where((p) {
      return p.nombre.toLowerCase().contains(_searchQuery) ||
          p.descripcion.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  void _incrementar(int id) =>
      setState(() => _cantidades[id] = (_cantidades[id] ?? 0) + 1);

  void _decrementar(int id) {
    setState(() {
      final actual = _cantidades[id] ?? 0;
      if (actual > 0) _cantidades[id] = actual - 1;
    });
  }

  int get _totalItems =>
      _cantidades.values.fold(0, (sum, c) => sum + c);

  double get _precioTotal =>
      _todosLosProductos.fold(0.0, (sum, p) {
        final cantidad = _cantidades[p.id] ?? 0;
        return sum + (p.precio * cantidad);
      });

  List<Map<String, dynamic>> get _productosSeleccionados =>
      _todosLosProductos
          .where((p) => (_cantidades[p.id] ?? 0) > 0)
          .map((p) => {
                'idProducto': p.id,
                'cantidad': _cantidades[p.id]!,
                'nombre': p.nombre,
                'precio': p.precio,
              })
          .toList();

  PedidoFlowState get _currentFlowState =>
      widget.flowState.copyWith(productos: _productosSeleccionados);

  void _continuar() =>
      context.push('/pedido_resumen', extra: _currentFlowState);

  void _navigateToStep(int stepIndex) {
    switch (stepIndex) {
      case 0:
        context.push('/pedido_mesas', extra: _currentFlowState);
        break;
      case 1:
        break;
      case 2:
        if (_currentFlowState.canGoToResumen) {
          context.push('/pedido_resumen', extra: _currentFlowState);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomBarBg = isDark ? AppColors.navyCard : Colors.white;
    final bottomBorderColor = isDark ? AppColors.navyLight : AppColors.grey100;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: const Text('Nuevo Pedido'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: PedidoStepper(
            currentStep: 1,
            completedSteps: _currentFlowState.completedSteps,
            onStepTapped: _navigateToStep,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Contenido scrollable ─────────────────────────────────────────
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: isSmall ? 14.0 : 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Barra de búsqueda
                  _buildSearchBar(isDark, colorScheme, isSmall),

                  const SizedBox(height: 14),

                  // Categorías o etiqueta de búsqueda
                  if (_searchQuery.isEmpty) ...[
                    Text(
                      'Categorías',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: isSmall ? 14 : 16,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _buildCategorias(isSmall, colorScheme),
                    const SizedBox(height: 14),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Icon(Icons.filter_list_rounded,
                              size: 14, color: colorScheme.primary),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Resultados para "$_searchQuery"',
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  Divider(
                      color: isDark ? AppColors.navyLight : AppColors.grey100,
                      height: 1),
                  const SizedBox(height: 10),

                  // Lista de productos
                  _buildProductosList(isSmall, colorScheme),
                ],
              ),
            ),
          ),

          // ── Barra inferior con total y botón ──────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              isSmall ? 14 : 20,
              14,
              isSmall ? 14 : 20,
              20,
            ),
            decoration: BoxDecoration(
              color: bottomBarBg,
              border: Border(
                  top: BorderSide(color: bottomBorderColor, width: 1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total ($_totalItems items)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: isSmall ? 14 : 16,
                          ),
                    ),
                    Text(
                      'S/ ${_precioTotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: isSmall ? 16 : 18,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  // ElevatedButton hereda el estilo de AppTheme directamente
                  child: ElevatedButton(
                    onPressed: _totalItems == 0 ? null : _continuar,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: isSmall ? 14 : 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Barra de búsqueda ────────────────────────────────────────────────────────
  Widget _buildSearchBar(bool isDark, ColorScheme colorScheme, bool isSmall) {
    final bgColor = isDark ? AppColors.navyCard : AppColors.grey100.withOpacity(0.5);
    final activeBorderColor = colorScheme.primary.withOpacity(0.5);
    final inactiveBorderColor =
        isDark ? AppColors.navyLight : AppColors.grey300;

    return Container(
      height: isSmall ? 42 : 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _searchQuery.isNotEmpty
              ? activeBorderColor
              : inactiveBorderColor,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search_rounded,
            color: _searchQuery.isNotEmpty
                ? colorScheme.primary
                : AppColors.grey500,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: isSmall ? 14 : 15),
              decoration: InputDecoration(
                hintText: 'Buscar platillo...',
                hintStyle: const TextStyle(
                    color: AppColors.grey300, fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: _clearSearch,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.close_rounded,
                    size: 18, color: AppColors.grey500),
              ),
            ),
        ],
      ),
    );
  }

  // ── Categorías ───────────────────────────────────────────────────────────────
  Widget _buildCategorias(bool isSmall, ColorScheme colorScheme) {
    return FutureBuilder<List<CategoriaModel>>(
      future: _categoriasList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 40,
            child: Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
          );
        }
        if (snapshot.hasError) {
          return Text('Error al cargar categorías',
              style: Theme.of(context).textTheme.bodySmall);
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          height: isSmall ? 38 : 45,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              CategoriaButtonWidget(
                nombre: "Todas",
                seleccionado: _categoriaSeleccionada == null,
                onTap: () => _seleccionarCategoria(null),
              ),
              ...snapshot.data!.map(
                (cat) => CategoriaButtonWidget(
                  nombre: cat.nombre,
                  seleccionado: _categoriaSeleccionada == cat.idCategoria,
                  onTap: () => _seleccionarCategoria(cat.idCategoria),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Lista de productos ───────────────────────────────────────────────────────
  Widget _buildProductosList(bool isSmall, ColorScheme colorScheme) {
    return FutureBuilder<List<ProductoModel>>(
      future: _productosList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Expanded(
            child: Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
          );
        }
        if (snapshot.hasError) {
          return Expanded(
            child: Center(
              child: Text('Error al cargar los productos',
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Expanded(
            child: Center(
              child: Text('No hay productos disponibles',
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          );
        }

        final filtrados = _filtrar(snapshot.data!);

        if (filtrados.isEmpty) {
          return Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off_rounded,
                      size: 48, color: AppColors.grey300),
                  const SizedBox(height: 12),
                  Text(
                    'Sin resultados para\n"$_searchQuery"',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _clearSearch,
                    child: const Text('Limpiar búsqueda'),
                  ),
                ],
              ),
            ),
          );
        }

        return Expanded(
          child: ListView.builder(
            itemCount: filtrados.length,
            itemBuilder: (context, index) {
              final item = filtrados[index];
              return MenuItemWidget(
                itemName: item.nombre,
                description: item.descripcion,
                price: 'S/ ${item.precio.toStringAsFixed(2)}',
                quantity: _cantidades[item.id] ?? 0,
                images: item.imagenes,
                onIncrementar: () => _incrementar(item.id),
                onDecrementar: () => _decrementar(item.id),
              );
            },
          ),
        );
      },
    );
  }
}