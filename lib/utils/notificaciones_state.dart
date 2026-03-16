import 'package:flutter/material.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'dart:convert';
import 'package:super_pollo_app/models/notificacion_model.dart';
import 'package:super_pollo_app/services/pusher_config.dart';

class NotificacionesState extends ChangeNotifier {
  static final NotificacionesState _instance = NotificacionesState._internal();
  factory NotificacionesState() => _instance;
  NotificacionesState._internal();

  final PusherConfig _pusherConfig = PusherConfig();
  final List<NotificacionModel> notificaciones = [];
  int conteo = 0;

  Future<void> init() async {
    await _pusherConfig.initPusher(
      channelName: 'mi-canal',
      eventName: 'mi-evento',
      onEventTriggered: _onEvento,
    );
  }

  void _onEvento(PusherEvent event) {
    print('evento recibido en singleton: ${event.data}');
    if (event.data == null) return;
    try {
      Map<String, dynamic> raw;
      if (event.data is String) {
        raw = Map<String, dynamic>.from(jsonDecode(event.data.toString()));
      } else {
        raw = Map<String, dynamic>.from(event.data as Map);
      }
      final notif = NotificacionModel.fromJson(raw);
      notificaciones.insert(0, notif);
      conteo++;
      notifyListeners();
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void limpiarConteo() {
    conteo = 0;
    notifyListeners();
  }

  void limpiarTodo() {
    notificaciones.clear();
    conteo = 0;
    notifyListeners();
  }
} 