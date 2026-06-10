import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontendhealtplate/services/log_service.dart';
import 'package:frontendhealtplate/services/nutrition_service.dart';
import 'package:frontendhealtplate/services/dashboard_service.dart';
import 'package:frontendhealtplate/services/session_manager.dart';
import 'package:frontendhealtplate/repositories/log_repository.dart';
import 'package:frontendhealtplate/repositories/nutrition_repository.dart';
import 'package:frontendhealtplate/repositories/dashboard_repository.dart';

class MockClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest request) mockHandler;

  MockClient(this.mockHandler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await mockHandler(request);
    final responseBytes = response.bodyBytes;
    return http.StreamedResponse(
      Stream.value(responseBytes),
      response.statusCode,
      contentLength: responseBytes.length,
      headers: response.headers,
      request: request,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LogRepository Tests', () {
    late SessionManager sessionManager;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      sessionManager = SessionManager();
    });

    test('fetchDailyLog calls LogService and parses DailyLog', () async {
      await sessionManager.saveToken('log-token');

      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/log/2026-06-10'));
        expect(request.method, equals('GET'));
        expect(request.headers['Authorization'], equals('Bearer log-token'));

        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'log_date': '2026-06-10',
              'total_calories': 450,
              'total_protein': 25,
              'total_carbohydrate': 50,
              'total_fat': 10,
              'total_sugar': 5,
              'total_water_ml': 1000,
              'log_entries': [
                {
                  'entry_id': 'entry-123',
                  'meal_time': 'Breakfast',
                  'portion': 150,
                  'food_products': {
                    'product_id': 'prod-456',
                    'product_name': 'Nasi Uduk',
                    'calories_kcal': 300,
                    'protein_g': 6,
                    'carbohydrate_g': 40,
                    'fat_g': 8,
                    'sugar_g': 1
                  }
                }
              ]
            }
          }),
          200,
        );
      });

      final service = LogService(client: mockClient);
      final repo = LogRepository(logService: service, sessionManager: sessionManager);

      final log = await repo.fetchDailyLog('2026-06-10');

      expect(log.logDate, equals('2026-06-10'));
      expect(log.totalCalories, equals(450.0));
      expect(log.totalWaterMl, equals(1000.0));
      expect(log.logEntries, hasLength(1));
      expect(log.logEntries.first.entryId, equals('entry-123'));
      expect(log.logEntries.first.foodProduct.productName, equals('Nasi Uduk'));
    });

    test('addFoodEntry calls LogService with payload', () async {
      await sessionManager.saveToken('log-token');

      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/log/2026-06-10/entries'));
        expect(request.method, equals('POST'));

        final body = jsonDecode((request as http.Request).body);
        expect(body['product_id'], equals('prod-123'));
        expect(body['meal_time'], equals('Lunch'));
        expect(body['portion'], equals(120.0));

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Success'
          }),
          201,
        );
      });

      final service = LogService(client: mockClient);
      final repo = LogRepository(logService: service, sessionManager: sessionManager);

      await repo.addFoodEntry(
        date: '2026-06-10',
        productId: 'prod-123',
        mealTime: 'Lunch',
        portion: 120.0,
      );
    });

    test('deleteFoodEntry calls LogService delete endpoint', () async {
      await sessionManager.saveToken('log-token');

      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/log/2026-06-10/entries/entry-abc'));
        expect(request.method, equals('DELETE'));

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Deleted'
          }),
          200,
        );
      });

      final service = LogService(client: mockClient);
      final repo = LogRepository(logService: service, sessionManager: sessionManager);

      await repo.deleteFoodEntry(date: '2026-06-10', entryId: 'entry-abc');
    });

    test('updateWaterIntake calls LogService water endpoint', () async {
      await sessionManager.saveToken('log-token');

      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/log/2026-06-10/water'));
        expect(request.method, equals('PUT'));

        final body = jsonDecode((request as http.Request).body);
        expect(body['total_water_ml'], equals(1500.0));

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Success'
          }),
          200,
        );
      });

      final service = LogService(client: mockClient);
      final repo = LogRepository(logService: service, sessionManager: sessionManager);

      await repo.updateWaterIntake(date: '2026-06-10', totalWaterMl: 1500.0);
    });
  });

  group('NutritionRepository Tests', () {
    test('searchFoods returns list of FoodProducts', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/nutrition/foods/search'));
        expect(request.url.queryParameters['q'], equals('soto'));

        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {
                'product_id': 'soto-1',
                'product_name': 'Soto Ayam',
                'brand_name': 'Generic',
                'calories_kcal': 120,
                'protein_g': 8.5,
                'carbohydrate_g': 10,
                'fat_g': 5,
                'sugar_g': 2
              }
            ]
          }),
          200,
        );
      });

      final service = NutritionService(client: mockClient);
      final repo = NutritionRepository(nutritionService: service);

      final results = await repo.searchFoods('soto');

      expect(results, hasLength(1));
      expect(results.first.productId, equals('soto-1'));
      expect(results.first.productName, equals('Soto Ayam'));
    });
  });

  group('DashboardRepository Tests', () {
    late SessionManager sessionManager;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      sessionManager = SessionManager();
    });

    test('fetchDashboardSummary calls DashboardService and returns DashboardSummary', () async {
      await sessionManager.saveToken('dash-token');

      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/dashboard/summary'));
        expect(request.method, equals('GET'));

        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'date': '2026-06-10',
              'consumed': {
                'calories': 500,
                'protein': 30,
                'carbohydrate': 60,
                'fat': 15,
                'sugar': 8,
                'water_ml': 1250
              },
              'target': {
                'calories': 2000,
                'protein': 80,
                'carbohydrate': 250,
                'fat': 65,
                'sugar': 40,
                'water_ml': 2000
              },
              'percentage': {
                'calories': 25.0,
                'protein': 37.5,
                'carbohydrate': 24.0,
                'fat': 23.0,
                'sugar': 20.0
              },
              'entries': []
            }
          }),
          200,
        );
      });

      final service = DashboardService(client: mockClient);
      final repo = DashboardRepository(dashboardService: service, sessionManager: sessionManager);

      final summary = await repo.fetchDashboardSummary();

      expect(summary.date, equals('2026-06-10'));
      expect(summary.consumedCalories, equals(500.0));
      expect(summary.targetCalories, equals(2000.0));
      expect(summary.percentageProtein, equals(37.5));
      expect(summary.consumedWaterMl, equals(1250.0));
    });
  });
}
