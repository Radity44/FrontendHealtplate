import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/dashboard_summary.dart';
import 'session_manager.dart';

class DashboardService {
  final http.Client _client;

  DashboardService({http.Client? client}) : _client = client ?? http.Client();

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

  Future<DashboardSummary> fetchDashboardSummary(String token) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/dashboard/summary');
    ApiConfig.logDiagnostic('/dashboard/summary');
    try {
      final response = await _client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>?;
        if (data == null) {
          throw const HttpException('Data summary dashboard tidak ditemukan.');
        }
        return DashboardSummary.fromJson(data);
      }

      _handleErrorResponse(response);
      throw const HttpException('Terjadi kesalahan koneksi.');
    } catch (e) {
      _handleNetworkException(e);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchDashboardHistory(String token, {int days = 7}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/dashboard/history?days=$days');
    ApiConfig.logDiagnostic('/dashboard/history?days=$days');
    try {
      final response = await _client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as List<dynamic>? ?? [];
        return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }

      _handleErrorResponse(response);
      throw const HttpException('Terjadi kesalahan koneksi.');
    } catch (e) {
      _handleNetworkException(e);
      rethrow;
    }
  }
}
