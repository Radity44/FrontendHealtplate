import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Override manual untuk testing menggunakan perangkat fisik (physical device).
  /// Masukkan IP LAN laptop/server Anda (contoh: 'http://192.168.1.10:3000/api/v1').
  /// Jika bernilai `null` atau kosong, aplikasi akan mendeteksi platform secara otomatis.
  static const String? customBaseUrl =
      'https://healthplate-backend-production.up.railway.app/api/v1';

  /// Mengembalikan API Base URL yang sesuai berdasarkan platform atau override manual.
  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }

    if (kIsWeb) {
      return 'http://localhost:3000/api/v1';
    } else if (Platform.isAndroid) {
      // 10.0.2.2 adalah IP gateway khusus Android Emulator untuk mengakses localhost PC
      return 'http://10.0.2.2:3000/api/v1';
    } else {
      // Default untuk Windows Desktop atau platform lainnya
      return 'http://localhost:3000/api/v1';
    }
  }

  /// Helper untuk mencetak log hanya saat aplikasi berjalan dalam debug mode.
  static void log(String message) {
    if (kDebugMode) {
      print('[HealthPlate API] $message');
    }
  }

  /// Helper khusus untuk mencetak diagnostik request endpoint pada debug mode.
  static void logDiagnostic(String endpoint) {
    if (kDebugMode) {
      final platform = kIsWeb ? 'Web' : Platform.operatingSystem;
      print('========================================');
      print('Platform   : $platform');
      print('Base URL   : $baseUrl');
      print('Endpoint   : $endpoint');
      print('========================================');
    }
  }
}
