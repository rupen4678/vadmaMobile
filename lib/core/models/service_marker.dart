class ServiceMarker {
  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final double price;
  final double? avgRating;

  ServiceMarker({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.price,
    this.avgRating,
  });

  factory ServiceMarker.fromJson(Map<String, dynamic> json) {
    return ServiceMarker(
      id: json['id'],
      title: json['title'],
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      avgRating: json['avg'] != null ? (json['avg'] as num).toDouble() : null,
    );
  }
}
