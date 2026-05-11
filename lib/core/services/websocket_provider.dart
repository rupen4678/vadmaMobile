import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/websocket_service.dart';

final webSocketServiceProvider = Provider((ref) => WebSocketService());

final messageStreamProvider = StreamProvider.family<Map<String, dynamic>, String>((ref, conversationId) {
  final wsService = ref.watch(webSocketServiceProvider);
  wsService.connect('chat/$conversationId');

  ref.onDispose(() {
    wsService.disconnect();
  });

  return wsService.stream;
});
