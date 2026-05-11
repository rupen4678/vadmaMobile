import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api/dio_client.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<String?>>((ref) {
  return AuthNotifier(ref.read(dioProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<String?>> {
  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  AuthNotifier(this._dio) : super(const AsyncValue.loading()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await _storage.read(key: 'jwt_token');
    state = AsyncValue.data(token);
  }

  Future<void> register({
    required String username,
    required String password,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _dio.post('auth/register/', data: {
        'username': username,
        'password': password,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
      });
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.post('auth/login/', data: {
        'username': username,
        'password': password,
      });
      final token = response.data['access'];
      await _storage.write(key: 'jwt_token', value: token);
      state = AsyncValue.data(token);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }
}
