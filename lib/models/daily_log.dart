import 'log_entry.dart';

class DailyLog {
  final String logDate;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbohydrate;
  final double totalFat;
  final double totalSugar;
  final double totalWaterMl;
  final List<LogEntry> logEntries;

  DailyLog({
    required this.logDate,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbohydrate,
    required this.totalFat,
    required this.totalSugar,
    required this.totalWaterMl,
    required this.logEntries,
  });

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    final entriesList = json['log_entries'] as List<dynamic>? ?? [];
    return DailyLog(
      logDate: json['log_date'] as String? ?? '',
      totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 0.0,
      totalProtein: (json['total_protein'] as num?)?.toDouble() ?? 0.0,
      totalCarbohydrate: (json['total_carbohydrate'] as num?)?.toDouble() ?? 0.0,
      totalFat: (json['total_fat'] as num?)?.toDouble() ?? 0.0,
      totalSugar: (json['total_sugar'] as num?)?.toDouble() ?? 0.0,
      totalWaterMl: (json['total_water_ml'] as num?)?.toDouble() ?? 0.0,
      logEntries: entriesList
          .map((item) => LogEntry.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
