import 'product.dart';

class Conversation {
  final String id;
  final List<User> participants;
  final Product? product;
  final DateTime updatedAt;
  final Message? lastMessage;

  Conversation({
    required this.id,
    required this.participants,
    this.product,
    required this.updatedAt,
    this.lastMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      participants: (json['participants'] as List).map((u) => User.fromJson(u)).toList(),
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      updatedAt: DateTime.parse(json['updated_at']),
      lastMessage: json['last_message'] != null ? Message.fromJson(json['last_message']) : null,
    );
  }
}

class Message {
  final int? id;
  final User sender;
  final String text;
  final DateTime createdAt;
  final bool isRead;

  Message({
    this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      sender: User.fromJson(json['sender']),
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
    );
  }
}
