import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/dio_client.dart';

class UserProfile {
  final String username;
  final String? email;
  final String? bio;
  final String? image;
  final String? location;
  final bool isVerified;
  final DateTime createdAt;

  UserProfile({
    required this.username,
    this.email,
    this.bio,
    this.image,
    this.location,
    this.isVerified = false,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Handling both nested 'user' object and flat object
    final userJson = json['user'] ?? {};
    return UserProfile(
      username: userJson['username'] ?? json['username'] ?? 'User',
      email: userJson['email'] ?? json['email'],
      bio: json['bio'] ?? '',
      image: json['image'],
      location: json['location'] ?? '',
      isVerified: json['verified_seller'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

final profileProvider = FutureProvider<UserProfile>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('profile/');
  
  final dynamic responseData = response.data;
  if (responseData is Map) {
    return UserProfile.fromJson(Map<String, dynamic>.from(responseData));
  } else {
    throw Exception('Invalid profile data');
  }
});
