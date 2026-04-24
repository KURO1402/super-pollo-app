import 'package:flutter/material.dart';
import 'package:super_pollo_app/models/mesas_model.dart';

class PedidoFlowState {
  List<MesaModel> mesas;
  List<Map<String, dynamic>> productos;

  PedidoFlowState({
    List<MesaModel>? mesas,
    List<Map<String, dynamic>>? productos,
  })  : mesas = mesas ?? [],
        productos = productos ?? [];

  PedidoFlowState copyWith({
    List<MesaModel>? mesas,
    List<Map<String, dynamic>>? productos,
  }) {
    return PedidoFlowState(
      mesas: mesas ?? this.mesas,
      productos: productos ?? this.productos,
    );
  }

  bool get canGoToMenu => mesas.isNotEmpty;

  bool get canGoToResumen => mesas.isNotEmpty && productos.isNotEmpty;

  Set<int> get completedSteps {
    final steps = <int>{};
    if (mesas.isNotEmpty) steps.add(0);
    if (productos.isNotEmpty) steps.add(1);
    return steps;
  }
}