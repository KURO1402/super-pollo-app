import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/models/categorias_model.dart';
import 'package:super_pollo_app/models/mesas_model.dart';
import 'package:super_pollo_app/models/productos_model.dart';
import 'package:super_pollo_app/services/categorias_service.dart';
import 'package:super_pollo_app/services/productos_service.dart';
import 'package:super_pollo_app/widgets/button_categorias.dart';
import '../widgets/menu_item.dart';

class PedidoMenuPage extends StatefulWidget {
  final List<MesaModel> mesasSeleccionadas; // ← recibe las mesas de la página anterior

  const PedidoMenuPage({super.key, required this.mesasSeleccionadas});

  @override
  State<PedidoMenuPage> createState() => _PedidoMenuPage();
}

class _PedidoMenuPage extends State<PedidoMenuPage> {
  int? _categoriaSeleccionada;
  final ProductosService _productosService = ProductosService();
  late Future<List<ProductoModel>> _productosList;

  final CategoriasService _categoriasService = CategoriasService();
  late Future<List<CategoriaModel>> _categoriasList;

  // Estado de cantidades: idProducto → cantidad
  final Map<int, int> _cantidades = {};

  // Todos los productos cargados (para calcular total)
  List<ProductoModel> _todosLosProductos = [];

  @override
  void initState() {
    super.initState();
    _productosList = _cargaInicial();
    _categoriasList = _cargaCategorias();
  }

  Future<List<ProductoModel>> _cargaInicial() async {
    try {
      final lista = await _productosService.getProductos(
        categoriaId: _categoriaSeleccionada,
      );
      // Guarda todos los productos para calcular el total correctamente
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
      final lista = await _categoriasService.getCategorias();
      return lista;
    } catch (e) {
      throw Exception("Error al cargar las categorias");
    }
  }

  void _seleccionarCategoria(int? idCategoria) {
    setState(() {
      _categoriaSeleccionada = idCategoria;
      _productosList = _cargaInicial();
    });
  }

  void _incrementar(int idProducto) {
    setState(() {
      _cantidades[idProducto] = (_cantidades[idProducto] ?? 0) + 1;
    });
  }

  void _decrementar(int idProducto) {
    setState(() {
      final actual = _cantidades[idProducto] ?? 0;
      if (actual > 0) _cantidades[idProducto] = actual - 1;
    });
  }

  // Total de items seleccionados
  int get _totalItems =>
      _cantidades.values.fold(0, (sum, cantidad) => sum + cantidad);

  // Precio total calculado
  double get _precioTotal {
    return _todosLosProductos.fold(0.0, (sum, p) {
      final cantidad = _cantidades[p.id] ?? 0;
      return sum + (p.precio * cantidad);
    });
  }

  // Navegar a resumen pasando mesas + productos seleccionados
  void _continuar() {
    final productosSeleccionados = _todosLosProductos
        .where((p) => (_cantidades[p.id] ?? 0) > 0)
        .map((p) => {
              'idProducto': p.id,
              'cantidad': _cantidades[p.id]!,
              'nombre': p.nombre,
              'precio': p.precio,
            })
        .toList();

    context.push("/pedido_resumen", extra: {
      'mesas': widget.mesasSeleccionadas,
      'productos': productosSeleccionados,
    });
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
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Nuevo Pedido',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Barra de pestañas
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Mesas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Menú',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Confirmar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Buscador
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 16),
                        Icon(Icons.search, color: Colors.grey, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Buscar platillo...',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Todas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Categorías
                  FutureBuilder<List<CategoriaModel>>(
                    future: _categoriasList,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox(
                          height: 45,
                          child:
                              Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Text("Error al cargar categorías");
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text("No hay categorías");
                      }

                      final categorias = snapshot.data!;
                      return SizedBox(
                        height: 45,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            CategoriaButtonWidget(
                              nombre: "Todas",
                              seleccionado: _categoriaSeleccionada == null,
                              onTap: () => _seleccionarCategoria(null),
                            ),
                            ...categorias.map((cat) {
                              return CategoriaButtonWidget(
                                nombre: cat.nombre,
                                seleccionado:
                                    _categoriaSeleccionada == cat.idCategoria,
                                onTap: () =>
                                    _seleccionarCategoria(cat.idCategoria),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  Container(height: 1, color: Colors.grey.shade300),
                  const SizedBox(height: 16),

                  // Lista de productos
                  FutureBuilder<List<ProductoModel>>(
                    future: _productosList,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error al cargar los productos'),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No hay productos disponibles'),
                        );
                      }

                      final productos = snapshot.data!;

                      return Expanded(
                        child: ListView.builder(
                          itemCount: productos.length,
                          itemBuilder: (context, index) {
                            final item = productos[index];
                            return MenuItemWidget(
                              itemName: item.nombre,
                              description: item.descripcion,
                              price:
                                  'S/ ${item.precio.toStringAsFixed(2)}',
                              quantity: _cantidades[item.id] ?? 0,
                              images: item.imagenes,
                              onIncrementar: () =>
                                  _incrementar(item.id),
                              onDecrementar: () =>
                                  _decrementar(item.id),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Resumen y botón continuar (fuera del Expanded para que siempre sea visible)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total ($_totalItems items)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'S/ ${_precioTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _totalItems == 0 ? null : _continuar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: const Color(0xFFE0E0E0),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: const Color(0xFFBDBDBD),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
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