import '../services/session_manager.dart';
import '../services/log_service.dart';
import '../models/daily_log.dart';
import 'profile_repository.dart';
import 'dashboard_repository.dart';

class LogRepository {
  final LogService _logService;
  final SessionManager _sessionManager;

  LogRepository({
    LogService? logService,
    SessionManager? sessionManager,
  })  : _logService = logService ?? LogService(),
        _sessionManager = sessionManager ?? SessionManager();

  Future<DailyLog> fetchDailyLog(String date) async {
    if (ProfileRepository.useMockDataForTests) {
      return DailyLog(
        logDate: date,
        totalCalories: 0,
        totalProtein: 0,
        totalCarbohydrate: 0,
        totalFat: 0,
        totalSugar: 0,
        totalWaterMl: DashboardRepository.mockWaterMl,
        logEntries: [],
      );
    }

    final token = await _sessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesi telah kedaluwarsa. Silakan login kembali.');
    }
    try {
      return await _logService.fetchDailyLog(token, date);
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('tidak ditemukan') || errStr.contains('404')) {
        return DailyLog(
          logDate: date,
          totalCalories: 0,
          totalProtein: 0,
          totalCarbohydrate: 0,
          totalFat: 0,
          totalSugar: 0,
          totalWaterMl: 0,
          logEntries: [],
        );
      }
      rethrow;
    }
  }

  Future<void> addFoodEntry({
    required String date,
    required String productId,
    required String mealTime,
    required double portion,
  }) async {
    if (ProfileRepository.useMockDataForTests) {
      return;
    }

    final token = await _sessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesi telah kedaluwarsa. Silakan login kembali.');
    }
    await _logService.addFoodEntry(
      token: token,
      date: date,
      productId: productId,
      mealTime: mealTime,
      portion: portion,
    );
  }

  Future<void> deleteFoodEntry({
    required String date,
    required String entryId,
  }) async {
    if (ProfileRepository.useMockDataForTests) {
      return;
    }

    final token = await _sessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesi telah kedaluwarsa. Silakan login kembali.');
    }
    await _logService.deleteFoodEntry(
      token: token,
      date: date,
      entryId: entryId,
    );
  }

  Future<void> updateWaterIntake({
    required String date,
    required double totalWaterMl,
  }) async {
    if (ProfileRepository.useMockDataForTests) {
      DashboardRepository.mockWaterMl = totalWaterMl;
      return;
    }

    final token = await _sessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesi telah kedaluwarsa. Silakan login kembali.');
    }
    await _logService.updateWaterIntake(
      token: token,
      date: date,
      totalWaterMl: totalWaterMl,
    );
  }
}

