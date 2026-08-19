class PedidoMesaModel {
  final int idPedido;
  final DateTime fechaPedido;
  final String estadoPedido;
  final double precioPrecuenta;
  final List<DetallePedidoModel> detalles;

  PedidoMesaModel({
    required this.idPedido,
    required this.fechaPedido,
    required this.estadoPedido,
    required this.precioPrecuenta,
    required this.detalles,
  });

  factory PedidoMesaModel.fromJson(Map<String, dynamic> json) {
    return PedidoMesaModel(
      idPedido: json['id_pedido'],
      fechaPedido: DateTime.parse(json['fecha_pedido']),
      estadoPedido: json['estado_pedido'],
      precioPrecuenta: double.tryParse(json['precio_precuenta'].toString()) ?? 0.0,
      detalles: (json['detalles'] as List<dynamic>)
          .map((d) => DetallePedidoModel.fromJson(d))
          .toList(),
    );
  }
}

class DetallePedidoModel {
  final int idDetallePedido;
  final int idProducto;
  final String nombreProducto;
  final int cantidadPedido;

  DetallePedidoModel({
    required this.idDetallePedido,
    required this.idProducto,
    required this.nombreProducto,
    required this.cantidadPedido,
  });

  factory DetallePedidoModel.fromJson(Map<String, dynamic> json) {
    return DetallePedidoModel(
      idDetallePedido: json['id_detalle_pedido'],
      idProducto: json['id_producto'],
      nombreProducto: json['nombre_producto'],
      cantidadPedido: json['cantidad_pedido'],
    );
  }
}