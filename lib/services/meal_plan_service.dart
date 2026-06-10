import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'session_manager.dart';

class MealPlanService {
  final http.Client _client;

  MealPlanService({http.Client? client}) : _client = client ?? http.Client();

  void _handleNetworkException(Object e) {
    if (e is SocketException) {
      final message = e.toString().toLowerCase();
      if (message.contains('connection refused') || 
          message.contains('os error 111') || 
          message.contains('os error 10061')) {
        throw const HttpException(
          'Koneksi ditolak oleh server.\nPastikan backend berjalan dan port yang digunakan benar.'
        );
      } else if (message.contains('failed host lookup') || 
               message.contains('host lookup failed') || 
               message.contains('os error 7') || 
               message.contains('os error 11001')) {
        throw const HttpException(
          'Tidak dapat menemukan server.\nPeriksa alamat API dan koneksi jaringan.'
        );
      } else {
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

  // GET /mealplan
  Future<List<dynamic>> fetchUserMealPlans(String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/mealplan');
    ApiConfig.logDiagnostic('/mealplan');
    ApiConfig.log('GET MEALPLANS: $url');

    try {
      final response = await _client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      ApiConfig.log('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['data'] as List<dynamic>? ?? [];
      } else {
        _handleErrorResponse(response);
        return [];
      }
    } catch (e) {
      ApiConfig.log('API ERROR: $e');
      _handleNetworkException(e);
      return [];
    }
  }

  // GET /mealplan/:id
  Future<Map<String, dynamic>> fetchMealPlanDetail(String planId, String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/mealplan/$planId');
    ApiConfig.logDiagnostic('/mealplan/$planId');
    ApiConfig.log('GET MEALPLAN DETAIL: $url');

    try {
      final response = await _client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      ApiConfig.log('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['data'] as Map<String, dynamic>? ?? {};
      } else {
        _handleErrorResponse(response);
        return {};
      }
    } catch (e) {
      ApiConfig.log('API ERROR: $e');
      _handleNetworkException(e);
      return {};
    }
  }

  // POST /mealplan
  Future<Map<String, dynamic>> createMealPlan(String name, String status, String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/mealplan');
    ApiConfig.logDiagnostic('/mealplan');
    ApiConfig.log('POST CREATE MEALPLAN: $url');

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'plan_name': name,
          'status': status,
        }),
      ).timeout(const Duration(seconds: 10));

      ApiConfig.log('Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['data'] as Map<String, dynamic>? ?? {};
      } else {
        _handleErrorResponse(response);
        return {};
      }
    } catch (e) {
      ApiConfig.log('API ERROR: $e');
      _handleNetworkException(e);
      return {};
    }
  }

  // PUT /mealplan/:id
  Future<void> updateMealPlanStatus(String planId, String name, String status, String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/mealplan/$planId');
    ApiConfig.logDiagnostic('/mealplan/$planId');
    ApiConfig.log('PUT UPDATE MEALPLAN STATUS: $url');

    try {
      final response = await _client.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'plan_name': name,
          'status': status,
        }),
      ).timeout(const Duration(seconds: 10));

      ApiConfig.log('Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        _handleErrorResponse(response);
      }
    } catch (e) {
      ApiConfig.log('API ERROR: $e');
      _handleNetworkException(e);
    }
  }

  // DELETE /mealplan/:id
  Future<void> deleteMealPlan(String planId, String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/mealplan/$planId');
    ApiConfig.logDiagnostic('/mealplan/$planId');
    ApiConfig.log('DELETE MEALPLAN: $url');

    try {
      final response = await _client.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      ApiConfig.log('Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        _handleErrorResponse(response);
      }
    } catch (e) {
      ApiConfig.log('API ERROR: $e');
      _handleNetworkException(e);
    }
  }

  // POST /mealplan/:id/items
  Future<void> addMealPlanItem({
    required String planId,
    required String productId,
    required String day,
    required String time,
    required double portion,
    required String token,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/mealplan/$planId/items');
    ApiConfig.logDiagnostic('/mealplan/$planId/items');
    ApiConfig.log('POST MEALPLAN ITEM: $url');

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_id': productId,
          'meal_day': day,
          'meal_time': time,
          'portion': portion,
        }),
      ).timeout(const Duration(seconds: 10));

      ApiConfig.log('Status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        _handleErrorResponse(response);
      }
    } catch (e) {
      ApiConfig.log('API ERROR: $e');
      _handleNetworkException(e);
    }
  }
}
