import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class ApiService {
  final String wsUrl = "ws://192.168.68.191:8000/ws"; 
  WebSocketChannel? _channel;

  // Stream, który będzie udostępniał dane w UI
  Stream<dynamic> get messages => _channel?.stream ?? const Stream.empty();

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
  }

  void sendMessage(String text) {
    if (_channel != null) {
      _channel!.sink.add(text); // Backend oczekuje czystego Stringa
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}