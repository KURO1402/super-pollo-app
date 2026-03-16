import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'dart:developer';

class PusherConfig {
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  Future<void> initPusher({
    required String channelName,
    required String eventName,
    required Function(PusherEvent) onEventTriggered,
  }) async {
    try {
      await pusher.init(
        apiKey: "aabb9cc7a7361938a7d5",
        cluster: "mt1",
        onConnectionStateChange: (currentState, previousState) {
          log("Conexión: $previousState -> $currentState");
        },
        onError: (message, code, e) {
          log("Error Pusher: $message (Código: $code)");
        },
        onEvent: (PusherEvent event) {
          log("Evento recibido en canal general: ${event.eventName}");
        },
        onSubscriptionSucceeded: (channel, data) {
          log("Suscrito con éxito a: $channel");
        },
      );

      await pusher.subscribe(
        channelName: channelName,
        onEvent: (dynamic event) {
          if (event is PusherEvent) {
            log("Evento en canal $channelName: ${event.eventName}");
            if (event.eventName == eventName) {
              onEventTriggered(event);
            }
          }
        },
      );

      await pusher.connect();
    } catch (e) {
      log("Error al inicializar Pusher: $e");
    }
  }

  void disconnect() {
    pusher.disconnect();
  }
}