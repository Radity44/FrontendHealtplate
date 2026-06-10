import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/auth_response.dart';
import '../utils/auth_exception.dart';
import 'session_manager.dart';

class AuthService {
  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  // ---------------------------------------------------------------------------
  // Network-level exception mapper
  // These are GLOBAL errors (no internet, timeout) — the UI can show a snackbar.
  // ---------------------------------------------------------------------------
  void _handleNetworkException(Object e) {
    if (e is SocketException) {
      final message = e.toString().toLowerCase();
      if (message.contains('connection refused') ||
          message.contains('os error 111') ||
          message.contains('os error 10061')) {
        throw const HttpException(
          'Koneksi ditolak oleh server.\nPastikan backend berjalan dan port yang digunakan benar.',
        );
      } else if (message.contains('failed host lookup') ||
          message.contains('host lookup failed') ||
          message.contains('os error 7') ||
          message.contains('os error 11001')) {
        throw const HttpException(
          'Tidak dapat menemukan server.\nPeriksa alamat API dan koneksi jaringan.',
        );
      } else {
        throw const HttpException(
          'Tidak dapat terhubung ke server.\nPastikan backend aktif dan perangkat berada pada jaringan yang sama.',
        );
      }
    } else if (e is TimeoutException) {
      throw const HttpException(
        'Server tidak merespons.\nSilakan coba lagi beberapa saat.',
      );
    } else if (e is AuthException) {
      // API-level error — re-throw as-is so the UI can show it inline.
      throw e;
    } else if (e is HttpException) {
      // Network-level HttpException — re-throw for snackbar treatment.
      throw e;
    } else {
      throw const HttpException(
        'Terjadi kesalahan saat menghubungi server.\nSilakan coba kembali.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Auth endpoints
  // ---------------------------------------------------------------------------

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/register');
    ApiConfig.logDiagnostic('/auth/register');
    ApiConfig.log('REGISTER URL: $url');

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      ApiConfig.log('Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      ApiConfig.log('API ERROR: $e');
      _handleNetworkException(e);
      rethrow; // satisfy compilation
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');
    ApiConfig.logDiagnostic('/auth/login');
    ApiConfig.log('LOGIN URL: $url');

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      ApiConfig.log('Status: ${response.statusCode}');
      return _handleResponse(response);
    } catch (e) {
      ApiConfig.log('API ERROR: $e');
      _handleNetworkException(e);
      rethrow; // satisfy compilation
    }
  }

  Future<void> logout({required String token}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/logout');
    ApiConfig.logDiagnostic('/auth/logout');
    ApiConfig.log('LOGOUT URL: $url');

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      ApiConfig.log('Status: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw HttpException('Logout gagal di server (${response.statusCode}).');
      }
    } catch (e) {
      ApiConfig.log('API ERROR: $e');
      _handleNetworkException(e);
      rethrow; // satisfy compilation
    }
  }

  // ---------------------------------------------------------------------------
  // Response handler
  //
  // API-level errors → AuthException  (UI shows inline message, no prefix)
  // Network/parse errors → HttpException (UI shows snackbar)
  // ---------------------------------------------------------------------------
  AuthResponse _handleResponse(http.Response response) {
    // Attempt JSON parse — on non-2xx a parse failure is non-fatal;
    // we fall through to the status-code mapping below.
    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body == null) {
        throw HttpException(
          'Gagal membaca data dari server (${response.statusCode}).',
        );
      }
      return AuthResponse.fromJson(body);
    }

    // Handle session expired redirect for authenticated requests returning 401.
    if (response.statusCode == 401) {
      if (response.request != null &&
          !response.request!.url.path.contains('/auth/login') &&
          !response.request!.url.path.contains('/auth/register')) {
        SessionManager.handleSessionExpired();
      }
    }

    // Priority 1: use backend-provided message if available.
    final apiMessage = body?['message'] as String? ?? '';
    if (apiMessage.isNotEmpty) {
      // AuthException → toString() = bare message, no prefix.
      throw AuthException(apiMessage);
    }

    // Priority 2: manual status-code mapping.
    switch (response.statusCode) {
      case 401:
        throw const AuthException('Email atau kata sandi yang Anda masukkan salah.');
      case 404:
        throw const AuthException('Akun tidak ditemukan.');
      case 422:
        throw const AuthException('Data yang Anda masukkan tidak valid.');
      case 500:
        throw const AuthException('Terjadi kesalahan internal pada server (500).');
      default:
        throw AuthException('Terjadi kesalahan sistem (${response.statusCode}).');
    }
  }
}
