import 'package:flutter/material.dart';
import 'package:super_pollo_app/models/estadisticas_model.dart';
import 'package:super_pollo_app/services/estadisticas_service.dart';

class EstadisticasState extends ChangeNotifier {
  static final EstadisticasState _instancia = EstadisticasState._interno();
  factory EstadisticasState() => _instancia;
  EstadisticasState._interno();

  final EstadisticasService _service = EstadisticasService();

  MesasActivasModel? mesasActivas;
  VentasHoyModel? ventasHoy;
  bool isLoading = false;
  String? error; // nuevo

  Future<void> cargar() async {
    isLoading = true;
    error = null; // nuevo
    notifyListeners();

    try {
      final resultados = await Future.wait([
        _service.obtenerMesasActivas(),
        _service.obtenerVentasHoy(),
      ]);
      mesasActivas = resultados[0] as MesasActivasModel;
      ventasHoy = resultados[1] as VentasHoyModel;
    } catch (e) {
      error = e.toString(); // nuevo
      debugPrint('Error al cargar estadísticas: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}