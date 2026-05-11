import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';
import '../../../core/api/dio_client.dart';
import '../../../core/models/chat.dart';
import '../../../core/services/websocket_provider.dart';

final chatServiceProvider = Provider((ref) {
  final dio = ref.read(dioProvider);
  return ChatService(dio);
});

final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final service = ref.watch(chatServiceProvider);
  final response = await service.getConversations();
  
  final dynamic responseData = response.data;
  List<dynamic> data;

  if (responseData is Map) {
    data = responseData['results'] ?? responseData['data'] ?? [];
  } else if (responseData is List) {
    data = responseData;
  } else {
    data = [];
  }
  
  return data.map((json) => Conversation.fromJson(json)).toList();
});

final typingProvider = StateProvider.family<bool, String>((ref, conversationId) => false);
final onlineProvider = StateProvider.family<bool, String>((ref, conversationId) => false);

class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  final ChatService _service;
  final String _conversationId;
  final Ref _ref;

  ChatMessagesNotifier(this._service, this._conversationId, this._ref) : super(const AsyncValue.loading()) {
    _loadMessages();
    _listenToWebsocket();
  }

  Future<void> _loadMessages() async {
    try {
      final response = await _service.getMessages(_conversationId);
      final dynamic responseData = response.data;
      List<dynamic> data;

      if (responseData is Map) {
        data = responseData['results'] ?? responseData['data'] ?? [];
      } else if (responseData is List) {
        data = responseData;
      } else {
        data = [];
      }

      final messages = data.map((json) => Message.fromJson(json)).toList();
      state = AsyncValue.data(messages);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void _listenToWebsocket() {
    _ref.listen(messageStreamProvider(_conversationId), (previous, next) {
      if (next.hasValue && next.value != null) {
        final payload = next.value!;
        final type = payload['type'];

        if (type == 'new_message') {
          final newMessage = Message.fromJson(payload);
          final currentMessages = state.value ?? [];
          
          if (!currentMessages.any((m) => m.id == newMessage.id && m.id != null)) {
            state = AsyncValue.data([...currentMessages, newMessage]);
          }
          // Reset typing when message received
          _ref.read(typingProvider(_conversationId).notifier).state = false;
        } else if (type == 'user_typing') {
          _ref.read(typingProvider(_conversationId).notifier).state = true;
        } else if (type == 'user_stop_typing') {
          _ref.read(typingProvider(_conversationId).notifier).state = false;
        } else if (type == 'user_online') {
          _ref.read(onlineProvider(_conversationId).notifier).state = true;
        } else if (type == 'user_offline') {
          _ref.read(onlineProvider(_conversationId).notifier).state = false;
        }
      }
    });
  }

  void sendTyping(bool isTyping) {
    _ref.read(webSocketServiceProvider).sendTypingStatus(isTyping);
  }

  Future<void> sendMessage(String text) async {
    try {
      final response = await _service.sendMessage(_conversationId, text);
      final newMessage = Message.fromJson(response.data);
      
      final currentMessages = state.value ?? [];
      state = AsyncValue.data([...currentMessages, newMessage]);
    } catch (e) {
      // Error handled in UI
      rethrow;
    }
  }
}

final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, AsyncValue<List<Message>>, String>((ref, conversationId) {
  final service = ref.watch(chatServiceProvider);
  return ChatMessagesNotifier(service, conversationId, ref);
});
