class Message {
  final String id;
  final String sender;
  final String text;
  final DateTime createdAt;

  Message({required this.id, required this.sender, required this.text, required this.createdAt});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      sender: json['sender'],
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
