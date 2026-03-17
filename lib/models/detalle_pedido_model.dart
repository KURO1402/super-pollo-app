class DetallePedidoModel {
  final int idPedido;
  final String estadoPedido;
  final List<DetalleItemModel> detalle;
  final List<MesaPedidoModel> mesas;

  DetallePedidoModel({
    required this.idPedido,
    required this.estadoPedido,
    required this.detalle,
    required this.mesas,
  });

  factory DetallePedidoModel.fromJson(Map<String, dynamic> json) {
    return DetallePedidoModel(
      idPedido: json['id_pedido'],
      estadoPedido: json['estado_pedido'] ?? '',
      detalle: (json['detalle'] as List)
          .map((d) => DetalleItemModel.fromJson(d))
          .toList(),
      mesas: (json['mesas'] as List)
          .map((m) => MesaPedidoModel.fromJson(m))
          .toList(),
    );
  }
}

class DetalleItemModel {
  final int idDetallePedido;
  final int idProducto;
  final String nombreProducto;
  final int cantidadPedido;

  DetalleItemModel({
    required this.idDetallePedido,
    required this.idProducto,
    required this.nombreProducto,
    required this.cantidadPedido,
  });

  factory DetalleItemModel.fromJson(Map<String, dynamic> json) {
    return DetalleItemModel(
      idDetallePedido: json['id_detalle_pedido'],
      idProducto: json['id_producto'],
      nombreProducto: json['nombre_producto'] ?? '',
      cantidadPedido: json['cantidad_pedido'],
    );
  }
}

class MesaPedidoModel {
  final int idMesa;
  final int numeroMesa;

  MesaPedidoModel({
    required this.idMesa,
    required this.numeroMesa,
  });

  factory MesaPedidoModel.fromJson(Map<String, dynamic> json) {
    return MesaPedidoModel(
      idMesa: json['id_mesa'],
      numeroMesa: json['numero_mesa'],
    );
  }
}