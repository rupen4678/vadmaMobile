import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/websocket_service.dart';
import '../../features/chat/providers/chat_provider.dart';

final notificationWebSocketServiceProvider = Provider((ref) => WebSocketService());

final notificationStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final wsService = ref.watch(notificationWebSocketServiceProvider);
  // Endpoint is notifications
  wsService.connect('notifications');

  ref.onDispose(() {
    wsService.disconnect();
  });

  return wsService.stream;
});

// Listener to invalidate providers based on global notifications
final globalNotificationListenerProvider = Provider<void>((ref) {
  ref.listen(notificationStreamProvider, (previous, next) {
    if (next.hasValue && next.value != null) {
      final payload = next.value!;
      final type = payload['type'];

      if (type == 'new_message') {
        // Invalidate conversations list to move the updated one to top
        ref.invalidate(conversationsProvider);
      }
    }
  });
});
