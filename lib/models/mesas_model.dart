class MesaModel {
  final int idMesa;
  final int numeroMesa;
  final String nombre;
  final int capacidadMesa;
  final String estadoLocal;
  final String estadoMesa;

  MesaModel({
    required this.idMesa,
    required this.numeroMesa,
    required this.nombre,
    required this.capacidadMesa,
    required this.estadoLocal,
    required this.estadoMesa,
  });

  factory MesaModel.fromJson(Map<String, dynamic> json) {
    return MesaModel(
      idMesa: json['id_mesa'],
      numeroMesa: json['numero_mesa'],
      nombre: json['nombre'],
      capacidadMesa: json['capacidad_mesa'],
      estadoLocal: json['estado_local'],
      estadoMesa: json['estado_mesa'],
    );
  }
}

