import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<Response> login(String username, String password) async {
    return await _dio.post('auth/login/', data: {
      'username': username,
      'password': password,
    });
  }

  Future<Response> register({
    required String username,
    required String password,
    required String email,
    String? firstName,
    String? lastName,
  }) async {
    return await _dio.post('auth/register/', data: {
      'username': username,
      'password': password,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
    });
  }
}
