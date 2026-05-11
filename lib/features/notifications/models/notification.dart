class AppNotification {
  final String id;
  final String title;
  final String body;
  final String link;

  AppNotification({required this.id, required this.title, required this.body, required this.link});

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      link: json['link'],
    );
  }
}
