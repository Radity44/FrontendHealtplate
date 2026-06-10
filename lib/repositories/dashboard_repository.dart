import '../services/session_manager.dart';
import '../services/dashboard_service.dart';
import '../models/dashboard_summary.dart';
import 'profile_repository.dart';

class DashboardRepository {
  static double mockWaterMl = 0.0;

  final DashboardService _dashboardService;
  final SessionManager _sessionManager;

  DashboardRepository({
    DashboardService? dashboardService,
    SessionManager? sessionManager,
  })  : _dashboardService = dashboardService ?? DashboardService(),
        _sessionManager = sessionManager ?? SessionManager();

  Future<DashboardSummary> fetchDashboardSummary() async {
    if (ProfileRepository.useMockDataForTests) {
      return DashboardSummary(
        date: '2026-06-10',
        consumedCalories: 0,
        consumedProtein: 0,
        consumedCarbohydrate: 0,
        consumedFat: 0,
        consumedSugar: 0,
        consumedWaterMl: mockWaterMl,
        targetCalories: 2000,
        targetProtein: 75,
        targetCarbohydrate: 250,
        targetFat: 60,
        targetSugar: 30,
        targetWaterMl: 2000,
        percentageCalories: 0,
        percentageProtein: 0,
        percentageCarbohydrate: 0,
        percentageFat: 0,
        percentageSugar: 0,
        entries: [],
      );
    }

    final token = await _sessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesi telah kedaluwarsa. Silakan login kembali.');
    }
    return _dashboardService.fetchDashboardSummary(token);
  }

  Future<List<Map<String, dynamic>>> fetchDashboardHistory({int days = 7}) async {
    if (ProfileRepository.useMockDataForTests) {
      final now = DateTime.now();
      if (days == 7) {
        final calList = [1801.0, 1902.0, 1813.0, 1894.0, 1825.0, 1886.0, 1829.0];
        return List.generate(7, (index) {
          final date = now.subtract(Duration(days: index));
          final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          return {
            'log_date': dateStr,
            'total_calories': calList[index],
            'total_protein': 55.0,
            'total_carbohydrate': 230.0,
            'total_fat': 58.0,
            'total_sugar': 28.0,
          };
        });
      } else {
        return List.generate(days, (index) {
          final date = now.subtract(Duration(days: index));
          final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          return {
            'log_date': dateStr,
            'total_calories': index < (days / 2) ? 1900.0 : 1920.0,
            'total_protein': 55.0,
            'total_carbohydrate': 230.0,
            'total_fat': 58.0,
            'total_sugar': 28.0,
          };
        });
      }
    }

    final token = await _sessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesi telah kedaluwarsa. Silakan login kembali.');
    }
    return _dashboardService.fetchDashboardHistory(token, days: days);
  }
}

