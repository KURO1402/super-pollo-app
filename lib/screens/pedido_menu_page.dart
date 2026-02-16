import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:super_pollo_app/models/categorias_model.dart';
import 'package:super_pollo_app/models/productos_model.dart';
import 'package:super_pollo_app/services/categorias_service.dart';
import 'package:super_pollo_app/services/productos_service.dart';
import 'package:super_pollo_app/widgets/button_categorias.dart';
import '../widgets/menu_item.dart'; 

class PedidoMenuPage extends StatefulWidget {
  const PedidoMenuPage({super.key});

  @override
  State<PedidoMenuPage> createState() => _PedidoMenuPage();
}

class _PedidoMenuPage extends State<PedidoMenuPage> {
  int? _categoriaSeleccionada;
  final ProductosService _productosService = ProductosService();
  late Future<List<ProductoModel>> _productosList;

  final CategoriasService _categoriasService = CategoriasService();
  late Future<List<CategoriaModel>> _categoriasList;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 24,
          ),
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
          // Barra de menú
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
                // Pestaña Mesas
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.transparent, width: 2),
                      ),
                    ),
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
                ),
                // Pestaña Menú (seleccionada)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    child: Center(
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
                // Pestaña Confirmar
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.transparent, width: 2),
                      ),
                    ),
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
                ),
              ],
            ),
          ),
          // Contenido principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Campo de búsqueda
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 16),
                        Icon(Icons.search, color: Colors.grey, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Buscar platillo...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Título "Todas"
                  const Text(
                    'Todas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Botones de categoría
                  FutureBuilder<List<CategoriaModel>>(
                    future: _categoriasList,
                    builder: (context, snapshot) {

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 45,
                          child: Center(child: CircularProgressIndicator()),
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

                            /// BOTÓN TODAS
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
                  // Línea separadora
                  Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  // Cargar lista de productos
                  FutureBuilder<List<ProductoModel>>(
                    future: _productosList,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error al cargar los productos'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No hay productos disponibles'));
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
                              price: 'S/ ${item.precio.toStringAsFixed(2)}',
                              quantity: 0,
                              images: item.imagenes,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Resumen del pedido
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Total
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total (3 items)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'S/ 24.00',
                              style: TextStyle(
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
                            onPressed: () {
                              context.go("/pedido_resumen");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
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
            ),
          ),
        ],
      ),
    );
  }
}
