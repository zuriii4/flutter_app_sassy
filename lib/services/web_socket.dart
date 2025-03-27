import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/material.dart';

class WebSocketService {
  late WebSocketChannel _channel;
  final String userId;
  final void Function(Map<String, dynamic> message)? onMessageReceived;

  WebSocketService({
    required this.userId,
    this.onMessageReceived,
  }) {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:3000?userId=$userId'),
    );

    _channel.stream.listen((event) {
      try {
        final message = jsonDecode(event);
        if (onMessageReceived != null) {
          onMessageReceived!(message);
        }
      } catch (e) {
        debugPrint("❌ Chyba pri dekódovaní správy: $e");
      }
    }, onError: (error) {
      debugPrint("❌ WebSocket chyba: $error");
    }, onDone: () {
      debugPrint("🛑 WebSocket odpojený");
    });
  }

  void sendMessage(Map<String, dynamic> message) {
    _channel.sink.add(jsonEncode(message));
  }

  void dispose() {
    _channel.sink.close();
  }
}

// PRÍKLAD POUŽITIA v main.dart alebo hocikde:
//
// final webSocket = WebSocketService(
//   userId: '1234567890',
//   onMessageReceived: (message) {
//     print("📩 Správa prijatá: \$message");
//   },
// );