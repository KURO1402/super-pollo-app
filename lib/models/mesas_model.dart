class MesasModel {
  final int idMesa;
  final int capacidadMesa;
  final int numeroMesa;
  final String estadoMesa;

  MesasModel({
    required this.idMesa,
    required this.capacidadMesa,
    required this.numeroMesa,
    required this.estadoMesa,
  });

  factory MesasModel.fromJson(Map<String, dynamic> json) {
    return MesasModel(
      idMesa: json['id_mesa'],
      capacidadMesa: json['capacidad'],
      numeroMesa: json['numero_mesa'],
      estadoMesa: json['estado_mesa']
    );
  }
}