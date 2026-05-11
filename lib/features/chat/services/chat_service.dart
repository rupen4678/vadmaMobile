import 'package:dio/dio.dart';

class ChatService {
  final Dio _dio;

  ChatService(this._dio);

  Future<Response> getConversations() async {
    return await _dio.get('/conversations/');
  }

  Future<Response> getMessages(String conversationId) async {
    return await _dio.get('/conversations/$conversationId/messages/');
  }

  Future<Response> sendMessage(String conversationId, String text) async {
    return await _dio.post('/conversations/$conversationId/send/', data: {'text': text});
  }
}
