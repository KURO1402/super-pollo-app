import 'package:flutter/material.dart';
import 'package:super_pollo_app/models/listar_pedidos_model.dart';
import 'package:super_pollo_app/services/listar_pedidos_service.dart';

/// Estado global de pedidos — singleton igual que NotificacionesState.
/// Cualquier pantalla puede escucharlo con addListener y obtener
/// la lista más reciente sin volver a llamar a la API.
class PedidosState extends ChangeNotifier {
  static final PedidosState _instance = PedidosState._internal();
  factory PedidosState() => _instance;
  PedidosState._internal();

  List<Pedido> _pedidos = [];
  bool _isLoading = false;
  String? _error;

  // ── Getters públicos ────────────────────────────────────────────────────────
  List<Pedido> get pedidos => List.unmodifiable(_pedidos);
  List<Pedido> get recientes => _pedidos.take(3).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Carga desde la API ──────────────────────────────────────────────────────
  Future<void> cargar() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ahora = DateTime.now();
      final fecha =
          '${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}';
      final hora =
          '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';

      final response =
          await PedidosService.listarPedidos(fecha: fecha, hora: hora);

      if (response.ok) {
        _pedidos = response.pedidos;
      } else {
        _error = 'Error al obtener pedidos';
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Añade un pedido optimista al principio de la lista
  /// para que aparezca de inmediato sin esperar la API.
  /// Llama a [cargar] justo después para sincronizar con el servidor.
  void agregarOptimista(Pedido pedido) {
    _pedidos.insert(0, pedido);
    notifyListeners();
  }

  /// Elimina un pedido de la lista local (ej. al cancelarlo)
  /// sin necesidad de recargar toda la lista desde la API.
  void eliminarLocal(int idPedido) {
    _pedidos.removeWhere((p) => p.idPedido == idPedido);
    notifyListeners();
  }

  /// Reemplaza un pedido existente en la lista local (ej. al editarlo).
  void actualizarLocal(Pedido pedidoActualizado) {
    final idx =
        _pedidos.indexWhere((p) => p.idPedido == pedidoActualizado.idPedido);
    if (idx != -1) {
      _pedidos[idx] = pedidoActualizado;
      notifyListeners();
    }
  }
}