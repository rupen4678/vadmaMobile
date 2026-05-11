import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_client.dart';

class Notification {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? product;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.product,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'].toString(),
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      product: json['product']?.toString(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class NotificationNotifier extends StateNotifier<AsyncValue<List<Notification>>> {
  final Dio _dio;

  NotificationNotifier(this._dio) : super(const AsyncValue.loading());

  Future<void> loadNotifications() async {
    try {
      final response = await _dio.get('notifications/');
      final dynamic responseData = response.data;
      List<dynamic> data;

      if (responseData is Map) {
        data = responseData['results'] ?? responseData['data'] ?? [];
      } else if (responseData is List) {
        data = responseData;
      } else {
        data = [];
      }

      final notifications = data.map((json) => Notification.fromJson(json)).toList();
      state = AsyncValue.data(notifications);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, AsyncValue<List<Notification>>>((ref) {
  final dio = ref.read(dioProvider);
  return NotificationNotifier(dio);
});
