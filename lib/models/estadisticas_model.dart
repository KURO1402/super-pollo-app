class MesasActivasModel {
  final int totalMesas;
  final int mesasActivas;
  final int porcentajeOcupacion;

  MesasActivasModel({
    required this.totalMesas,
    required this.mesasActivas,
    required this.porcentajeOcupacion,
  });

  factory MesasActivasModel.fromJson(Map<String, dynamic> json) {
    return MesasActivasModel(
      totalMesas: _toInt(json['total_mesas']),
      mesasActivas: _toInt(json['mesas_activas']),
      porcentajeOcupacion: _toInt(json['porcentaje_ocupacion']),
    );
  }

  static int _toInt(dynamic valor) {
    if (valor == null) return 0;
    if (valor is int) return valor;
    if (valor is num) return valor.toInt();
    return int.tryParse(valor.toString()) ?? 0;
  }
}

class VentasHoyModel {
  final double montoVentasHoy;
  final double montoVentasAyer;
  final double porcentajeVariacion;

  VentasHoyModel({
    required this.montoVentasHoy,
    required this.montoVentasAyer,
    required this.porcentajeVariacion,
  });

  factory VentasHoyModel.fromJson(Map<String, dynamic> json) {
    return VentasHoyModel(
      montoVentasHoy: _toDouble(json['monto_ventas_hoy']),
      montoVentasAyer: _toDouble(json['monto_ventas_ayer']),
      porcentajeVariacion: _toDouble(json['porcentaje_variacion']),
    );
  }

  static double _toDouble(dynamic valor) {
    if (valor == null) return 0.0;
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor.toString()) ?? 0.0;
  }

  bool get esPositivo => porcentajeVariacion >= 0;
}