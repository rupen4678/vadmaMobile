import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/notification.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  void listen(BuildContext context) {
    final channel = WebSocketChannel.connect(
      Uri.parse('ws://10.0.2.2:8000/ws/notifications/'),
    );

    channel.stream.listen((data) {
      final decoded = json.decode(data);
      final notification = AppNotification.fromJson(decoded);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${notification.title}: ${notification.body}'),
          action: SnackBarAction(label: 'View', onPressed: () {
            // Navigate to link
          }),
        ),
      );
    });
  }
}
