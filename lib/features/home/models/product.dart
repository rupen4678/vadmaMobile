class Product {
  final String id;
  final String title;
  final double price;
  final String? imageUrl;
  final String seller;

  Product({
    required this.id,
    required this.title,
    required this.price,
    this.imageUrl,
    required this.seller,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: json['image'] != null ? 'http://10.0.2.2:8000${json['image']}' : null,
      seller: json['seller']?['username'] ?? 'Unknown',
    );
  }
}
