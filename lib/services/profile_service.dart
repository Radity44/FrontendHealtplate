import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_profile.dart';

class ProfileService {
  final http.Client _client;

  ProfileService({http.Client? client}) : _client = client ?? http.Client();

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
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/me');
      final response = await _client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

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
    } on SocketException {
      throw const HttpException('Koneksi internet gagal. Periksa jaringan Anda.');
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException('Terjadi kesalahan tidak terduga: $e');
    }
  }

  // PUT /auth/me (Supports Partial Update)
  Future<UserProfile> updateProfile(String token, Map<String, dynamic> updatedFields) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/me');
      final response = await _client.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updatedFields),
      );

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
    } on SocketException {
      throw const HttpException('Koneksi internet gagal. Periksa jaringan Anda.');
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException('Terjadi kesalahan tidak terduga: $e');
    }
  }

  // POST /upload/avatar
  Future<String> uploadAvatar(String token, List<int> imageBytes, String filename) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/upload/avatar');
      
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: filename,
          ),
        );

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

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
    } on SocketException {
      throw const HttpException('Koneksi internet gagal. Periksa jaringan Anda.');
    } catch (e) {
      if (e is HttpException) rethrow;
      throw HttpException('Terjadi kesalahan tidak terduga: $e');
    }
  }
}
