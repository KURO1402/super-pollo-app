import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/models/categorias_model.dart';
import 'package:super_pollo_app/models/productos_model.dart';
import 'package:super_pollo_app/services/categorias_service.dart';
import 'package:super_pollo_app/services/productos_service.dart';
import 'package:super_pollo_app/state/pedido_flow_state.dart';
import 'package:super_pollo_app/widgets/button_categorias.dart';
import 'package:super_pollo_app/widgets/pedido_stepper.dart';
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
      if (id != null && cantidad != null) {
        _cantidades[id] = cantidad;
      }
    }
  }

  Future<List<ProductoModel>> _cargaInicial() async {
    try {
      final lista = await _productosService.getProductos(
        categoriaId: _categoriaSeleccionada,
      );
      for (final p in lista) {
        if (!_todosLosProductos.any((e) => e.id == p.id)) {
          _todosLosProductos.add(p);
        }
      }
      return lista;
    } catch (e) {
      throw Exception("Error al cargar productos.");
    }
  }

  Future<List<CategoriaModel>> _cargaCategorias() async {
    try {
      return await _categoriasService.getCategorias();
    } catch (e) {
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

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value.trim().toLowerCase());
  }

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

  void _incrementar(int idProducto) =>
      setState(() => _cantidades[idProducto] = (_cantidades[idProducto] ?? 0) + 1);

  void _decrementar(int idProducto) {
    setState(() {
      final actual = _cantidades[idProducto] ?? 0;
      if (actual > 0) _cantidades[idProducto] = actual - 1;
    });
  }

  int get _totalItems => _cantidades.values.fold(0, (sum, c) => sum + c);

  double get _precioTotal => _todosLosProductos.fold(0.0, (sum, p) {
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

    return Scaffold(
      backgroundColor: Colors.white,
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
          onPressed: () => context.pop(),
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
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmall ? 14.0 : 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  Container(
                    height: isSmall ? 42 : 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _searchQuery.isNotEmpty
                            ? const Color(0xFF1565C0).withOpacity(0.5)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        Icon(
                          Icons.search_rounded,
                          color: _searchQuery.isNotEmpty
                              ? const Color(0xFF1565C0)
                              : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            style: TextStyle(
                              fontSize: isSmall ? 14 : 15,
                              color: const Color(0xFF1A1A1A),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Buscar platillo...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: isSmall ? 14 : 15,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        // Botón limpiar búsqueda
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: _clearSearch,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (_searchQuery.isEmpty) ...[
                    Text(
                      'Categorías',
                      style: TextStyle(
                        fontSize: isSmall ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<CategoriaModel>>(
                      future: _categoriasList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 40,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError) {
                          return const Text("Error al cargar categorías");
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        final categorias = snapshot.data!;
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
                              ...categorias.map(
                                (cat) => CategoriaButtonWidget(
                                  nombre: cat.nombre,
                                  seleccionado: _categoriaSeleccionada ==
                                      cat.idCategoria,
                                  onTap: () =>
                                      _seleccionarCategoria(cat.idCategoria),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.filter_list_rounded,
                            size: 14,
                            color: Color(0xFF1565C0),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Resultados para "$_searchQuery"',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF1565C0),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  Divider(color: Colors.grey.shade200, height: 1),
                  const SizedBox(height: 10),

                  FutureBuilder<List<ProductoModel>>(
                    future: _productosList,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Expanded(
                          child: Center(
                              child: Text('Error al cargar los productos')),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Expanded(
                          child:
                              Center(child: Text('No hay productos disponibles')),
                        );
                      }

                      final filtrados = _filtrar(snapshot.data!);

                      if (filtrados.isEmpty) {
                        return Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Sin resultados para\n"$_searchQuery"',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _clearSearch,
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF1565C0),
                                  ),
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
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.fromLTRB(
              isSmall ? 14 : 20,
              14,
              isSmall ? 14 : 20,
              20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
                      style: TextStyle(
                        fontSize: isSmall ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'S/ ${_precioTotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isSmall ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _totalItems == 0 ? null : _continuar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      disabledBackgroundColor: const Color(0xFFE0E0E0),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: const Color(0xFFBDBDBD),
                      padding: EdgeInsets.symmetric(
                          vertical: isSmall ? 13 : 16),
                      elevation: _totalItems > 0 ? 4 : 0,
                      shadowColor: const Color(0xFF1565C0).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
}