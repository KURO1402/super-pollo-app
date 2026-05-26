import 'package:flutter/material.dart';
import 'package:super_pollo_app/models/listar_pedidos_model.dart';
import 'package:super_pollo_app/models/mesas_model.dart';
import 'package:super_pollo_app/models/productos_model.dart';
import 'package:super_pollo_app/services/editar_pedido_service.dart';
import 'package:super_pollo_app/services/mesas_service.dart';
import 'package:super_pollo_app/services/productos_service.dart';
import 'package:super_pollo_app/theme/app_colors.dart';

class _ProductoEditItem {
  final int idProducto;
  final String nombreProducto;
  final double precio;
  int cantidad;

  _ProductoEditItem({
    required this.idProducto,
    required this.nombreProducto,
    required this.precio,
    required this.cantidad,
  });
}

class EditarPedidoPage extends StatefulWidget {
  final Pedido pedido;
  final VoidCallback onPedidoEditado;

  const EditarPedidoPage({
    super.key,
    required this.pedido,
    required this.onPedidoEditado,
  });

  @override
  State<EditarPedidoPage> createState() => _EditarPedidoPageState();
}

class _EditarPedidoPageState extends State<EditarPedidoPage> {
  // ── Servicios ────────────────────────────────────────────────────────────
  final _editarService = EditarPedidoService();
  final _mesasService = MesasService();
  final _productosService = ProductosService();

  // ── Estado de carga ──────────────────────────────────────────────────────
  bool _isLoadingMesas = true;
  bool _isLoadingProductos = true;
  bool _isSaving = false;
  String? _errorMessage;

  // ── Datos remotos ────────────────────────────────────────────────────────
  List<MesaModel> _mesasDisponibles = [];
  List<ProductoModel> _productosDisponibles = [];

  // ── Estado del formulario ────────────────────────────────────────────────
  /// IDs de mesas seleccionadas
  late Set<int> _mesasSeleccionadas;

  /// Productos en el pedido (preexistentes + agregados)
  late List<_ProductoEditItem> _productosEnPedido;

  /// Búsqueda en el catálogo de productos
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // ── Inicialización ───────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Precargar mesas seleccionadas desde el pedido actual.
    // El modelo Pedido tiene mesas como List<String> (numero_mesa).
    // Necesitamos los idMesa reales; los obtenemos al cargar mesas disponibles.
    _mesasSeleccionadas = {};

    // Precargar productos del pedido
    _productosEnPedido = widget.pedido.detalles
        .map((d) => _ProductoEditItem(
              idProducto: d.idProducto,
              nombreProducto: d.nombreProducto,
              precio: double.tryParse(d.precioProducto) ?? 0,
              cantidad: d.cantidadPedido,
            ))
        .toList();

    _cargarDatos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Carga de datos ───────────────────────────────────────────────────────
  Future<void> _cargarDatos() async {
    await Future.wait([_cargarMesas(), _cargarProductos()]);
  }

  Future<void> _cargarMesas() async {
    try {
      final ahora = DateTime.now();
      final fecha =
          '${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}';
      final hora =
          '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';

      final response = await _mesasService.getMesasPedido(fecha, hora);

      if (mounted) {
        setState(() {
          // Solo mesas con estado_local y estado_mesa = 'disponible',
          // más las que ya pertenecen al pedido actual (para poder verlas).
          final numerosMesaActuales = widget.pedido.mesas.toSet();
          _mesasDisponibles = response.mesas.where((m) {
            final esDelPedidoActual =
                numerosMesaActuales.contains(m.numeroMesa.toString());
            final estaDisponible =
                m.estadoLocal == 'disponible' && m.estadoMesa == 'disponible';
            return estaDisponible || esDelPedidoActual;
          }).toList();

          // Preseleccionar las mesas que ya tiene el pedido.
          _mesasSeleccionadas = _mesasDisponibles
              .where((m) =>
                  numerosMesaActuales.contains(m.numeroMesa.toString()))
              .map((m) => m.idMesa)
              .toSet();

          _isLoadingMesas = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMesas = false;
          _errorMessage = 'Error al cargar mesas';
        });
      }
    }
  }

  Future<void> _cargarProductos() async {
    try {
      final productos = await _productosService.getProductos();
      if (mounted) {
        setState(() {
          _productosDisponibles = productos;
          _isLoadingProductos = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProductos = false;
          _errorMessage = 'Error al cargar productos';
        });
      }
    }
  }

  // ── Lógica de productos ──────────────────────────────────────────────────
  List<ProductoModel> get _productosFiltrados {
    if (_searchQuery.isEmpty) return _productosDisponibles;
    final q = _searchQuery.toLowerCase();
    return _productosDisponibles
        .where((p) => p.nombre.toLowerCase().contains(q))
        .toList();
  }

  bool _estaEnPedido(int idProducto) =>
      _productosEnPedido.any((p) => p.idProducto == idProducto);

  int _cantidadEnPedido(int idProducto) =>
      _productosEnPedido
          .firstWhere((p) => p.idProducto == idProducto,
              orElse: () => _ProductoEditItem(
                  idProducto: 0, nombreProducto: '', precio: 0, cantidad: 0))
          .cantidad;

  void _agregarProducto(ProductoModel producto) {
    setState(() {
      _productosEnPedido.add(_ProductoEditItem(
        idProducto: producto.id,
        nombreProducto: producto.nombre,
        precio: producto.precio,
        cantidad: 1,
      ));
    });
  }

  void _incrementar(int idProducto) {
    setState(() {
      final i =
          _productosEnPedido.indexWhere((p) => p.idProducto == idProducto);
      if (i != -1) _productosEnPedido[i].cantidad++;
    });
  }

  void _decrementar(int idProducto) {
    setState(() {
      final i =
          _productosEnPedido.indexWhere((p) => p.idProducto == idProducto);
      if (i != -1) {
        if (_productosEnPedido[i].cantidad > 1) {
          _productosEnPedido[i].cantidad--;
        } else {
          _productosEnPedido.removeAt(i);
        }
      }
    });
  }

  // ── Guardar ──────────────────────────────────────────────────────────────
  bool get _isFormValid =>
      _mesasSeleccionadas.isNotEmpty && _productosEnPedido.isNotEmpty;

  Future<void> _guardarCambios() async {
    if (!_isFormValid) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final request = EditarPedidoRequest(
        mesas: _mesasSeleccionadas.map((id) => {'idMesa': id}).toList(),
        productos: _productosEnPedido
            .map((p) => {'idProducto': p.idProducto, 'cantidad': p.cantidad})
            .toList(),
      );

      final response = await _editarService.editarPedido(
        idPedido: widget.pedido.idPedido,
        request: request,
      );

      if (!mounted) return;

      if (response.ok) {
        widget.onPedidoEditado();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.mensaje.isNotEmpty
                ? response.mensaje
                : 'Pedido actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = response.mensaje.isNotEmpty
              ? response.mensaje
              : 'No se pudo actualizar el pedido';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() =>
            _errorMessage = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── UI ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Pedido #${widget.pedido.idPedido}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sección Mesas ────────────────────────────────────────────
            _SectionTitle(
              icon: Icons.table_restaurant_rounded,
              title: 'Mesas',
              subtitle: '${_mesasSeleccionadas.length} seleccionada(s)',
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 12),
            _isLoadingMesas
                ? _LoadingBox()
                : _mesasDisponibles.isEmpty
                    ? _EmptyHint(
                        text: 'No hay mesas disponibles', isDark: isDark)
                    : _MesasGrid(
                        mesas: _mesasDisponibles,
                        seleccionadas: _mesasSeleccionadas,
                        isDark: isDark,
                        colorScheme: colorScheme,
                        onToggle: (idMesa) {
                          setState(() {
                            if (_mesasSeleccionadas.contains(idMesa)) {
                              _mesasSeleccionadas.remove(idMesa);
                            } else {
                              _mesasSeleccionadas.add(idMesa);
                            }
                          });
                        },
                      ),

            const SizedBox(height: 28),

            // ── Sección Productos en el pedido ───────────────────────────
            _SectionTitle(
              icon: Icons.receipt_long_outlined,
              title: 'Productos en el pedido',
              subtitle: '${_productosEnPedido.length} producto(s)',
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 12),
            _productosEnPedido.isEmpty
                ? _EmptyHint(
                    text: 'Agrega productos desde el catálogo', isDark: isDark)
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _productosEnPedido.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final item = _productosEnPedido[i];
                      return _ProductoPedidoCard(
                        item: item,
                        isDark: isDark,
                        colorScheme: colorScheme,
                        onIncrement: () => _incrementar(item.idProducto),
                        onDecrement: () => _decrementar(item.idProducto),
                      );
                    },
                  ),

            const SizedBox(height: 28),

            // ── Catálogo de productos ────────────────────────────────────
            _SectionTitle(
              icon: Icons.storefront_outlined,
              title: 'Catálogo',
              subtitle: 'Toca un producto para agregarlo',
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 12),

            // Buscador
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.navyLight : AppColors.grey100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            _isLoadingProductos
                ? _LoadingBox()
                : _productosFiltrados.isEmpty
                    ? _EmptyHint(
                        text: 'No se encontraron productos', isDark: isDark)
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _productosFiltrados.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final producto = _productosFiltrados[i];
                          final enPedido = _estaEnPedido(producto.id);
                          final cantidad = _cantidadEnPedido(producto.id);
                          return _ProductoCatalogoCard(
                            producto: producto,
                            enPedido: enPedido,
                            cantidad: cantidad,
                            isDark: isDark,
                            colorScheme: colorScheme,
                            onAgregar: () => _agregarProducto(producto),
                            onIncrement: () => _incrementar(producto.id),
                            onDecrement: () => _decrementar(producto.id),
                          );
                        },
                      ),

            const SizedBox(height: 28),

            // ── Error ────────────────────────────────────────────────────
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Botón guardar ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    (_isFormValid && !_isSaving) ? _guardarCambios : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  disabledBackgroundColor:
                      colorScheme.primary.withOpacity(0.4),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Guardar Cambios',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets internos ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;

  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Text(subtitle,
            style: TextStyle(
                fontSize: 12,
                color: colorScheme.primary,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _LoadingBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 60,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  final bool isDark;

  const _EmptyHint({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyLight : AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: isDark ? AppColors.grey300 : AppColors.grey700,
              fontSize: 13)),
    );
  }
}

// ── Grid de mesas ─────────────────────────────────────────────────────────────
class _MesasGrid extends StatelessWidget {
  final List<MesaModel> mesas;
  final Set<int> seleccionadas;
  final bool isDark;
  final ColorScheme colorScheme;
  final void Function(int idMesa) onToggle;

  const _MesasGrid({
    required this.mesas,
    required this.seleccionadas,
    required this.isDark,
    required this.colorScheme,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: mesas.length,
      itemBuilder: (_, i) {
        final mesa = mesas[i];
        final selected = seleccionadas.contains(mesa.idMesa);

        return GestureDetector(
          onTap: () => onToggle(mesa.idMesa),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: selected
                  ? colorScheme.primary
                  : (isDark ? AppColors.navyLight : AppColors.grey100),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.table_restaurant_rounded,
                  size: 18,
                  color: selected ? Colors.white : colorScheme.primary,
                ),
                const SizedBox(height: 4),
                Text(
                  '${mesa.numeroMesa}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : (isDark ? AppColors.grey300 : AppColors.grey700),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Tarjeta de producto en el pedido ─────────────────────────────────────────
class _ProductoPedidoCard extends StatelessWidget {
  final _ProductoEditItem item;
  final bool isDark;
  final ColorScheme colorScheme;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ProductoPedidoCard({
    required this.item,
    required this.isDark,
    required this.colorScheme,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyCard : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.nombreProducto,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  'S/ ${item.precio.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // Subtotal
          Text(
            'S/ ${(item.precio * item.cantidad).toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.success),
          ),
          const SizedBox(width: 12),
          // Controles cantidad
          _QuantityControls(
            cantidad: item.cantidad,
            colorScheme: colorScheme,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
            // Si llega a 0 se elimina del pedido
            decrementIcon:
                item.cantidad == 1 ? Icons.delete_outline : Icons.remove,
            decrementColor: item.cantidad == 1 ? Colors.red : null,
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de producto en catálogo ──────────────────────────────────────────
class _ProductoCatalogoCard extends StatelessWidget {
  final ProductoModel producto;
  final bool enPedido;
  final int cantidad;
  final bool isDark;
  final ColorScheme colorScheme;
  final VoidCallback onAgregar;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ProductoCatalogoCard({
    required this.producto,
    required this.enPedido,
    required this.cantidad,
    required this.isDark,
    required this.colorScheme,
    required this.onAgregar,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyLight : AppColors.grey100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(producto.nombre,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  'S/ ${producto.precio.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // Si ya está en el pedido: controles +/-; si no: botón agregar
          enPedido
              ? _QuantityControls(
                  cantidad: cantidad,
                  colorScheme: colorScheme,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                  decrementIcon:
                      cantidad == 1 ? Icons.delete_outline : Icons.remove,
                  decrementColor: cantidad == 1 ? Colors.red : null,
                )
              : GestureDetector(
                  onTap: onAgregar,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Agregar',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ── Controles de cantidad ─────────────────────────────────────────────────────
class _QuantityControls extends StatelessWidget {
  final int cantidad;
  final ColorScheme colorScheme;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final IconData decrementIcon;
  final Color? decrementColor;

  const _QuantityControls({
    required this.cantidad,
    required this.colorScheme,
    required this.onIncrement,
    required this.onDecrement,
    this.decrementIcon = Icons.remove,
    this.decrementColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = decrementColor ?? colorScheme.primary;
    return Row(
      children: [
        GestureDetector(
          onTap: onDecrement,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(decrementIcon, size: 15, color: activeColor),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text('$cantidad',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700)),
        ),
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.add, size: 15, color: colorScheme.primary),
          ),
        ),
      ],
    );
  }
}