class User {
  final int id;
  final String username;
  final String? email;
  final String? profileImage;
  final bool isOnline;
  final bool isTyping;

  User({
    required this.id,
    required this.username,
    this.email,
    this.profileImage,
    this.isOnline = false,
    this.isTyping = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profileImage: json['profile_image'],
      isOnline: json['is_online'] ?? false,
      isTyping: json['is_typing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profile_image': profileImage,
    };
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

enum ListingType {
  sell,
  auction,
  rental,
  service;

  static ListingType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'sell':
        return ListingType.sell;
      case 'auction':
        return ListingType.auction;
      case 'rental':
        return ListingType.rental;
      case 'service':
        return ListingType.service;
      default:
        return ListingType.sell;
    }
  }

  String toServerString() {
    switch (this) {
      case ListingType.sell:
        return 'sell';
      case ListingType.auction:
        return 'AUCTION';
      case ListingType.rental:
        return 'RENTAL';
      case ListingType.service:
        return 'SERVICE';
    }
  }
}

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final ListingType listingType;
  final String? image;
  final User seller;
  final Category? category;
  final DateTime createdAt;
  final DateTime? auctionEnd;
  final double? highestBid;
  final int? bidCount;

  final bool isFeatured;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.listingType,
    this.image,
    required this.seller,
    this.category,
    required this.createdAt,
    this.auctionEnd,
    this.highestBid,
    this.bidCount,
    this.isFeatured = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      listingType: ListingType.fromString(json['listing_type'] ?? 'sell'),
      image: json['image'],
      seller: User.fromJson(json['seller']),
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      createdAt: DateTime.parse(json['created_at']),
      auctionEnd: json['auction_end'] != null ? DateTime.parse(json['auction_end']) : null,
      highestBid: json['highest_bid'] != null ? double.tryParse(json['highest_bid'].toString()) : null,
      bidCount: json['bid_count'],
      isFeatured: json['is_featured'] ?? false,
    );
  }
}
