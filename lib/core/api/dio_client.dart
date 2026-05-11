import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  // Use 127.0.0.1 instead of localhost to avoid IPv6 vs IPv4 resolution issues
  // which often cause connection timeouts on Linux/macOS/Windows.
  final baseUrl = kIsWeb ? 'http://127.0.0.1:8000/api/' : 'http://10.0.2.2:8000/api/';
  
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15), // Increased from 10 to 15
    receiveTimeout: const Duration(seconds: 15),
    contentType: 'application/json',
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
  ));

  // Add logging interceptor for development
  dio.interceptors.add(LogInterceptor(
    requestHeader: true,
    requestBody: true,
    responseHeader: true,
    responseBody: true,
    error: true,
  ));

  return dio;
});
