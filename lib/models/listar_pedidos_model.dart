import 'dart:convert';
import 'package:flutter/material.dart';

class PedidosResponse {
  final bool ok;
  final List<Pedido> pedidos;

  PedidosResponse({required this.ok, required this.pedidos});

  factory PedidosResponse.fromJson(Map<String, dynamic> json) {
    try {
      var pedidosList = json['pedidos'] ?? [];

      List<Pedido> pedidos = [];
      if (pedidosList is List) {
        for (var p in pedidosList) {
          // Convertir cada elemento a Map<String, dynamic>
          Map<String, dynamic> pedidoMap;
          if (p is Map) {
            pedidoMap = Map<String, dynamic>.from(p);
          } else {
            pedidoMap = jsonDecode(jsonEncode(p)) as Map<String, dynamic>;
          }
          pedidos.add(Pedido.fromJson(pedidoMap));
        }
      }

      return PedidosResponse(ok: json['ok'] ?? false, pedidos: pedidos);
    } catch (e) {
      print('Error parsing PedidosResponse: $e');
      return PedidosResponse(ok: false, pedidos: []);
    }
  }
}

class Pedido {
  final int idPedido;
  final String estadoPedido;
  final String precioPrecuenta;
  final List<String> mesas;
  final String tiempoDesdeActualizacion;
  final List<DetallePedido> detalles;

  Pedido({
    required this.idPedido,
    required this.estadoPedido,
    required this.precioPrecuenta,
    required this.mesas,
    required this.tiempoDesdeActualizacion,
    required this.detalles,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    try {
      // Parsear mesas - puede ser String, List de strings, List de objetos, o Map/Object
      List<String> mesasList = [];
      var mesasData = json['mesas'];
      if (mesasData != null) {
        if (mesasData is String) {
          mesasList = mesasData.split(', ');
        } else if (mesasData is List) {
          for (var mesa in mesasData) {
            if (mesa is String) {
              mesasList.add(mesa);
            } else if (mesa is Map) {
              // Si es un objeto, extraer el numero_mesa
              mesasList.add(mesa['numero_mesa']?.toString() ?? '');
            }
          }
        } else if (mesasData is Map) {
          // Si es un objeto único
          mesasList = [mesasData['numero_mesa']?.toString() ?? ''];
        }
      }

      // Parsear detalles
      List<DetallePedido> detallesList = [];
      var detallesData = json['detalles'];
      if (detallesData is List) {
        for (var d in detallesData) {
          Map<String, dynamic> detalleMap;
          if (d is Map) {
            detalleMap = Map<String, dynamic>.from(d);
          } else {
            detalleMap = jsonDecode(jsonEncode(d)) as Map<String, dynamic>;
          }
          detallesList.add(DetallePedido.fromJson(detalleMap));
        }
      }

      return Pedido(
        idPedido: json['id_pedido'] ?? 0,
        estadoPedido: json['estado_pedido'] ?? 'pendiente',
        precioPrecuenta: json['precio_precuenta']?.toString() ?? '0.00',
        mesas: mesasList,
        tiempoDesdeActualizacion: json['tiempo_desde_actualizacion'] ?? '',
        detalles: detallesList,
      );
    } catch (e) {
      print('Error parsing Pedido: $e');
      return Pedido(
        idPedido: 0,
        estadoPedido: 'pendiente',
        precioPrecuenta: '0.00',
        mesas: [],
        tiempoDesdeActualizacion: '',
        detalles: [],
      );
    }
  }

  String get mesaPrincipal => mesas.isNotEmpty ? mesas.first : 'N/A';

  int get totalItems => detalles.fold(0, (sum, d) => sum + d.cantidadPedido);

  Color get colorEstado {
    switch (estadoPedido) {
      case 'completado':
        return Colors.green;
      case 'pendiente':
      default:
        return Colors.orange;
    }
  }

  String get estadoLabel {
    switch (estadoPedido) {
      case 'completado':
        return 'Completado';
      case 'pendiente':
      default:
        return 'Pendiente';
    }
  }
}

class DetallePedido {
  final int idDetallePedido;
  final int cantidadPedido;
  final int idProducto;
  final String nombreProducto;
  final String precioProducto;
  final String subtotal;

  DetallePedido({
    required this.idDetallePedido,
    required this.cantidadPedido,
    required this.idProducto,
    required this.nombreProducto,
    required this.precioProducto,
    required this.subtotal,
  });

  factory DetallePedido.fromJson(Map<String, dynamic> json) {
    try {
      return DetallePedido(
        idDetallePedido: json['id_detalle_pedido'] ?? 0,
        cantidadPedido: json['cantidad_pedido'] ?? 0,
        idProducto: json['id_producto'] ?? 0,
        nombreProducto: json['nombre_producto'] ?? '',
        precioProducto: json['precio_producto']?.toString() ?? '0.00',
        subtotal: json['subtotal']?.toString() ?? '0.00',
      );
    } catch (e) {
      print('Error parsing DetallePedido: $e');
      return DetallePedido(
        idDetallePedido: 0,
        cantidadPedido: 0,
        idProducto: 0,
        nombreProducto: '',
        precioProducto: '0.00',
        subtotal: '0.00',
      );
    }
  }
}
