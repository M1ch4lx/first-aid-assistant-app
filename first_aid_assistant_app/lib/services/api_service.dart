import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String wsUrl = dotenv.get('WS_URL', fallback: 'ws://localhost:8000/ws');

  WebSocketChannel? _channel;

  Stream<dynamic> get messages => _channel?.stream ?? const Stream.empty();

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
  }

  void sendMessage(String text) {
    if (_channel != null) {
      _channel!.sink.add(text);
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}