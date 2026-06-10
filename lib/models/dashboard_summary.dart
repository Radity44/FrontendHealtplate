import 'log_entry.dart';

class DashboardSummary {
  final String date;
  final double consumedCalories;
  final double consumedProtein;
  final double consumedCarbohydrate;
  final double consumedFat;
  final double consumedSugar;
  final double consumedWaterMl;

  final double targetCalories;
  final double targetProtein;
  final double targetCarbohydrate;
  final double targetFat;
  final double targetSugar;
  final double targetWaterMl;

  final double percentageCalories;
  final double percentageProtein;
  final double percentageCarbohydrate;
  final double percentageFat;
  final double percentageSugar;

  final List<LogEntry> entries;

  DashboardSummary({
    required this.date,
    required this.consumedCalories,
    required this.consumedProtein,
    required this.consumedCarbohydrate,
    required this.consumedFat,
    required this.consumedSugar,
    required this.consumedWaterMl,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbohydrate,
    required this.targetFat,
    required this.targetSugar,
    required this.targetWaterMl,
    required this.percentageCalories,
    required this.percentageProtein,
    required this.percentageCarbohydrate,
    required this.percentageFat,
    required this.percentageSugar,
    required this.entries,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final consumedMap = json['consumed'] as Map<String, dynamic>? ?? {};
    final targetMap = json['target'] as Map<String, dynamic>? ?? {};
    final percentageMap = json['percentage'] as Map<String, dynamic>? ?? {};
    final entriesList = json['entries'] as List<dynamic>? ?? [];

    return DashboardSummary(
      date: json['date'] as String? ?? '',
      consumedCalories: (consumedMap['calories'] as num?)?.toDouble() ?? 0.0,
      consumedProtein: (consumedMap['protein'] as num?)?.toDouble() ?? 0.0,
      consumedCarbohydrate: (consumedMap['carbohydrate'] as num?)?.toDouble() ?? 0.0,
      consumedFat: (consumedMap['fat'] as num?)?.toDouble() ?? 0.0,
      consumedSugar: (consumedMap['sugar'] as num?)?.toDouble() ?? 0.0,
      consumedWaterMl: (consumedMap['water_ml'] as num?)?.toDouble() ?? 0.0,
      targetCalories: (targetMap['calories'] as num?)?.toDouble() ?? 0.0,
      targetProtein: (targetMap['protein'] as num?)?.toDouble() ?? 0.0,
      targetCarbohydrate: (targetMap['carbohydrate'] as num?)?.toDouble() ?? 0.0,
      targetFat: (targetMap['fat'] as num?)?.toDouble() ?? 0.0,
      targetSugar: (targetMap['sugar'] as num?)?.toDouble() ?? 0.0,
      targetWaterMl: (targetMap['water_ml'] as num?)?.toDouble() ?? 0.0,
      percentageCalories: (percentageMap['calories'] as num?)?.toDouble() ?? 0.0,
      percentageProtein: (percentageMap['protein'] as num?)?.toDouble() ?? 0.0,
      percentageCarbohydrate: (percentageMap['carbohydrate'] as num?)?.toDouble() ?? 0.0,
      percentageFat: (percentageMap['fat'] as num?)?.toDouble() ?? 0.0,
      percentageSugar: (percentageMap['sugar'] as num?)?.toDouble() ?? 0.0,
      entries: entriesList
          .map((item) => LogEntry.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
