import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_profile.dart';
import 'session_manager.dart';

class ProfileService {
  final http.Client _client;

  ProfileService({http.Client? client}) : _client = client ?? http.Client();

  // Helper to handle and map network/timeout exceptions to friendly messages
  void _handleNetworkException(Object e) {
    if (e is SocketException) {
      final message = e.toString().toLowerCase();
      // Connection refused check
      if (message.contains('connection refused') || 
          message.contains('os error 111') || 
          message.contains('os error 10061')) {
        throw const HttpException(
          'Koneksi ditolak oleh server.\nPastikan backend berjalan dan port yang digunakan benar.'
        );
      } 
      // Failed host lookup check (host lookup failed, os error 7 for Linux/Android, os error 11001 for Windows)
      else if (message.contains('failed host lookup') || 
               message.contains('host lookup failed') || 
               message.contains('os error 7') || 
               message.contains('os error 11001')) {
        throw const HttpException(
          'Tidak dapat menemukan server.\nPeriksa alamat API dan koneksi jaringan.'
        );
      } 
      // General SocketException
      else {
        throw const HttpException(
          'Tidak dapat terhubung ke server.\nPastikan backend aktif dan perangkat berada pada jaringan yang sama.'
        );
      }
    } else if (e is TimeoutException) {
      throw const HttpException(
        'Server tidak merespons.\nSilakan coba lagi beberapa saat.'
      );
    } else if (e is HttpException) {
      throw e;
    } else {
      throw const HttpException(
        'Terjadi kesalahan saat menghubungi server.\nSilakan coba kembali.'
      );
    }
  }

  // Helper to handle generic HTTP exceptions based on API status codes
  void _handleErrorResponse(http.Response response) {
    final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw HttpException('Gagal membaca data dari server (${response.statusCode}).');
    }

    final message = body['message'] as String? ?? 'Terjadi kesalahan sistem.';

    switch (response.statusCode) {
      case 400:
        throw HttpException(message.isNotEmpty ? message : 'Permintaan tidak valid (400).');
      case 401:
        SessionManager.handleSessionExpired();
        throw HttpException(message.isNotEmpty ? message : 'Sesi tidak valid atau kedaluwarsa (401).');
      case 403:
        throw HttpException(message.isNotEmpty ? message : 'Anda tidak memiliki akses (403).');
      case 422:
        throw HttpException(message.isNotEmpty ? message : 'Data yang dikirim tidak valid (422).');
      case 500:
        throw const HttpException('Terjadi kesalahan internal pada server (500).');
      default:
        throw HttpException('$message (${response.statusCode}).');
    }
  }

  // GET /auth/me
  Future<UserProfile> fetchProfile(String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/me');
    ApiConfig.logDiagnostic('/auth/me');
    ApiConfig.log('PROFILE URL: $url');

    try {
      final response = await _client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      ApiConfig.log('Status: ${response.statusCode}');

      if (response.statusCode == 500) {
        throw const HttpException('Terjadi kesalahan internal pada server (500).');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>?;
        if (data == null) {
          throw const HttpException('Data profil tidak ditemukan di respon server.');
        }
        return UserProfile.fromJson(data);
      }

      _handleErrorResponse(response);
      throw const HttpException('Terjadi kesalahan koneksi.');
    } catch (e) {
      ApiConfig.log('API ERROR: $e');
      _handleNetworkException(e);
      rethrow;
    }
  }

  // PUT /auth/me (Supports Partial Update)
  Future<UserProfile> updateProfile(String token, Map<String, dynamic> updatedFields) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/me');
    ApiConfig.logDiagnostic('/auth/me');
    ApiConfig.log('PROFILE URL: $url');

    try {
      final response = await _client.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updatedFields),
      ).timeout(const Duration(seconds: 10));

      ApiConfig.log('Status: ${response.statusCode}');

      if (response.statusCode == 500) {
        throw const HttpException('Terjadi kesalahan internal pada server (500).');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>?;
        if (data == null) {
          throw const HttpException('Data profil setelah update tidak ditemukan.');
        }
        return UserProfile.fromJson(data);
      }

      _handleErrorResponse(response);
      throw const HttpException('Terjadi kesalahan koneksi.');
    } catch (e) {
      ApiConfig.log('API ERROR: $e');
      _handleNetworkException(e);
      rethrow;
    }
  }

  // POST /upload/avatar
  Future<String> uploadAvatar(String token, List<int> imageBytes, String filename) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/upload/avatar');
    ApiConfig.logDiagnostic('/upload/avatar');
    ApiConfig.log('PROFILE URL: $url');

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: filename,
          ),
        );

      final streamedResponse = await _client.send(request).timeout(const Duration(seconds: 10));
      final response = await http.Response.fromStream(streamedResponse);

      ApiConfig.log('Status: ${response.statusCode}');

      if (response.statusCode == 500) {
        throw const HttpException('Terjadi kesalahan internal pada server (500).');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>?;
        final avatarUrl = data?['avatar_url'] as String?;
        if (avatarUrl == null || avatarUrl.isEmpty) {
          throw const HttpException('URL avatar tidak ditemukan di respon server.');
        }
        return avatarUrl;
      }

      _handleErrorResponse(response);
      throw const HttpException('Terjadi kesalahan koneksi.');
    } catch (e) {
      ApiConfig.log('API ERROR: $e');
      _handleNetworkException(e);
      rethrow;
    }
  }
}
