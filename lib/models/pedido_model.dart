class PedidoModel {
  final int idPedido;
  final String mensaje;
 
  PedidoModel({
    required this.idPedido,
    required this.mensaje,
  });
 
  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    return PedidoModel(
      idPedido: json['id_pedido'],
      mensaje: json['mensaje'],
    );
  }
}
 