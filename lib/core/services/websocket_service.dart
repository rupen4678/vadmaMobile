import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:async';

class WebSocketService {
  WebSocketChannel? _channel;
  final _storage = const FlutterSecureStorage();
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  Future<void> connect(String endpoint) async {
    final token = await _storage.read(key: 'access_token');
    final baseUrl = dotenv.env['WS_BASE_URL'] ?? 'ws://localhost:8000/ws';
    final url = '$baseUrl/$endpoint/?token=$token';

    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel!.stream.listen(
      (message) {
        _controller.add(jsonDecode(message));
      },
      onError: (error) {
        print('WebSocket Error: $error');
      },
      onDone: () {
        print('WebSocket Closed');
      },
    );
  }

  void sendMessage(Map<String, dynamic> data) {
    _channel?.sink.add(jsonEncode(data));
  }

  void sendTypingStatus(bool isTyping) {
    sendMessage({
      'type': isTyping ? 'typing_start' : 'typing_stop',
    });
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
