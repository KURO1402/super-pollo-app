class NotificacionModel {
  final String tipo; // "agregar", "editar", "cancelar"
  final String titulo;
  final String contenido;
  final String nota;
  final int? idPedido;
  final List<int> mesas;
  final DateTime timestamp;

  NotificacionModel({
    required this.tipo,
    required this.titulo,
    this.contenido = '',
    this.nota = '',
    this.idPedido,
    this.mesas = const [],
    required this.timestamp,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      tipo: json['tipo'] ?? 'agregar',
      titulo: json['titulo'] ?? '',
      contenido: _buildContenido(json),
      nota: '',
      idPedido: json['id_pedido'],
      mesas: (json['mesas'] as List?)?.map((e) => e as int).toList() ?? [],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  static String _buildContenido(Map<String, dynamic> json) {
    final mesas = json['mesas'] as List?;
    if (mesas == null || mesas.isEmpty) return '';
    return 'Mesas: ${mesas.join(', ')}';
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