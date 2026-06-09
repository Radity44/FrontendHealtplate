import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/auth_response.dart';

class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/register');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      return _handleResponse(response);
    } on SocketException {
      throw const HttpException('Koneksi internet gagal. Periksa jaringan Anda.');
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException('Terjadi kesalahan tidak terduga: $e');
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return _handleResponse(response);
    } on SocketException {
      throw const HttpException('Koneksi internet gagal. Periksa jaringan Anda.');
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException('Terjadi kesalahan tidak terduga: $e');
    }
  }

  Future<void> logout({required String token}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/logout');
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw HttpException('Logout gagal di server (${response.statusCode}).');
      }
    } on SocketException {
      throw const HttpException('Koneksi internet gagal. Periksa jaringan Anda.');
    } catch (e) {
      rethrow;
    }
  }

  AuthResponse _handleResponse(http.Response response) {
    if (response.statusCode == 500) {
      throw const HttpException('Terjadi kesalahan internal pada server (500).');
    }

    final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw HttpException('Gagal membaca data dari server (${response.statusCode}).');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AuthResponse.fromJson(body);
    }

    // Try to get message from API response
    final message = body['message'] as String? ?? 'Terjadi kesalahan sistem.';

    switch (response.statusCode) {
      case 400:
        throw HttpException(message.isNotEmpty ? message : 'Permintaan tidak valid (400).');
      case 401:
        throw HttpException(message.isNotEmpty ? message : 'Email atau password salah (401).');
      case 422:
        throw HttpException(message.isNotEmpty ? message : 'Data yang dimasukkan tidak valid (422).');
      default:
        throw HttpException('$message (${response.statusCode}).');
    }
  }
}
