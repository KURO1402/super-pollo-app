class NotificacionModel {
  final String tipo;
  final String titulo;
  final String contenido;
  final String nota;
  final int? idMesa;
  final int? idPedido;
  final DateTime timestamp;

  NotificacionModel({
    required this.tipo,
    required this.titulo,
    required this.contenido,
    this.nota = '',
    this.idMesa,
    this.idPedido,
    required this.timestamp,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      tipo: json['tipo'] ?? 'pedido',
      titulo: json['titulo'] ?? '',
      contenido: json['contenido'] ?? '',
      nota: json['nota'] ?? '',
      idMesa: json['idMesa'],
      idPedido: json['idPedido'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  String get tiempoRelativo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} min';
    }
    final hora = timestamp.hour.toString().padLeft(2, '0');
    final min = timestamp.minute.toString().padLeft(2, '0');
    return 'Hoy a las $hora:$min';
  }
}