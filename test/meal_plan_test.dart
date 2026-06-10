import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontendhealtplate/models/meal_plan.dart';
import 'package:frontendhealtplate/models/meal_plan_meal.dart';
import 'package:frontendhealtplate/services/meal_plan_service.dart';
import 'package:frontendhealtplate/services/session_manager.dart';
import 'package:frontendhealtplate/repositories/meal_plan_repository.dart';

// Reuse lightweight MockClient from existing pattern
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

  group('MealPlanMeal Model Tests', () {
    test('Should parse MealPlanMeal from item JSON with portion scaling', () {
      final json = {
        'portion': 150.0,
        'food_products': {
          'product_id': 'prod-123',
          'product_name': 'Dada Ayam',
          'serving_size_g': 100.0,
          'calories_kcal': 165.0,
          'protein_g': 31.0,
          'carbohydrate_g': 0.0,
          'fat_g': 3.6,
        }
      };

      final meal = MealPlanMeal.fromJson(json);

      expect(meal.id, equals('prod-123'));
      expect(meal.name, equals('Dada Ayam'));
      expect(meal.portion, equals(150.0));
      // Calorie scale check: 165.0 * (150 / 100) = 247.5 -> round to 248
      expect(meal.calories, equals(248));
      // Protein scale check: 31.0 * 1.5 = 46.5 -> round to 47
      expect(meal.protein, equals(47));
      expect(meal.fat, equals(5)); // 3.6 * 1.5 = 5.4 -> round to 5
    });
  });

  group('MealPlan Model Tests', () {
    test('Should parse MealPlan from list JSON and match explicit catalog metadata', () {
      final activeJson = {
        'plan_id': 'plan-abc',
        'plan_name': 'Kaya Protein Ayam A',
        'status': 'Active',
        'created_at': '2026-06-10T12:00:00Z',
      };

      // Mock items for Monday breakfast and dinner
      final items = [
        {
          'meal_day': 'Monday',
          'meal_time': 'Breakfast',
          'portion': 100.0,
          'food_products': {
            'product_id': 'bf-prod',
            'product_name': 'Telur Rebus',
            'serving_size_g': 100.0,
            'calories_kcal': 150.0,
          }
        },
        {
          'meal_day': 'Monday',
          'meal_time': 'Dinner',
          'portion': 200.0,
          'food_products': {
            'product_id': 'dn-prod',
            'product_name': 'Ayam Kukus',
            'serving_size_g': 100.0,
            'calories_kcal': 165.0,
          }
        }
      ];

      final plan = MealPlan.fromJson(activeJson, items: items);

      expect(plan.id, equals('plan-abc'));
      expect(plan.name, equals('Kaya Protein Ayam A'));
      expect(plan.isActive, isTrue);
      expect(plan.nutritionFocus, equals('Kaya Protein'));
      expect(plan.days.length, equals(7));

      // Monday is day 1 (index 0)
      final monday = plan.days[0];
      expect(monday.dayNumber, equals(1));
      expect(monday.breakfast.length, equals(1));
      expect(monday.breakfast[0].name, equals('Telur Rebus'));
      expect(monday.dinner.length, equals(1));
      expect(monday.dinner[0].name, equals('Ayam Kukus'));
      expect(monday.lunch.length, equals(0));
      expect(monday.snack.length, equals(0));

      // Check total calories for Monday: 150 * 1.0 + 165 * 2.0 = 150 + 330 = 480
      expect(monday.totalCalories, equals(480));
    });
  });

  group('MealPlanService API Tests', () {
    test('fetchUserMealPlans returns list of plans', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/mealplan'));
        expect(request.method, equals('GET'));
        expect(request.headers['Authorization'], equals('Bearer test-token'));

        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {'plan_id': 'p-1', 'plan_name': 'Plan 1', 'status': 'Active'}
            ]
          }),
          200,
        );
      });

      final service = MealPlanService(client: mockClient);
      final plans = await service.fetchUserMealPlans('test-token');

      expect(plans.length, equals(1));
      expect(plans[0]['plan_name'], equals('Plan 1'));
    });

    test('createMealPlan sends correct parameters', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/mealplan'));
        expect(request.method, equals('POST'));

        final body = jsonDecode((request as http.Request).body);
        expect(body['plan_name'], equals('My New Plan'));
        expect(body['status'], equals('Inactive'));

        return http.Response(
          jsonEncode({
            'success': true,
            'data': {'plan_id': 'p-2', 'plan_name': 'My New Plan', 'status': 'Inactive'}
          }),
          201,
        );
      });

      final service = MealPlanService(client: mockClient);
      final res = await service.createMealPlan('My New Plan', 'Inactive', 'test-token');

      expect(res['plan_id'], equals('p-2'));
    });
  });

  group('MealPlanRepository Integration Tests', () {
    late SessionManager sessionManager;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      sessionManager = SessionManager();
    });

    test('getActiveMealPlan returns parsed MealPlan when there is an active plan', () async {
      await sessionManager.saveToken('test-repo-token');

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/mealplan')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {'plan_id': 'p-active', 'plan_name': 'Kaya Protein Ayam A', 'status': 'Active'}
              ]
            }),
            200,
          );
        } else if (request.url.path.endsWith('/mealplan/p-active')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'plan_id': 'p-active',
                'meal_plan_items': [
                  {
                    'meal_day': 'Monday',
                    'meal_time': 'Breakfast',
                    'portion': 100.0,
                    'food_products': {
                      'product_id': 'c0e3d042-cc23-4000-a919-e71db0784d90',
                      'product_name': 'Telur Ayam',
                      'serving_size_g': 50.0,
                      'calories_kcal': 77.0,
                    }
                  }
                ]
              }
            }),
            200,
          );
        }
        return http.Response('', 404);
      });

      final service = MealPlanService(client: mockClient);
      final repo = MealPlanRepository(service: service, sessionManager: sessionManager);

      final plan = await repo.getActiveMealPlan();

      expect(plan, isNotNull);
      expect(plan!.id, equals('p-active'));
      expect(plan.name, equals('Kaya Protein Ayam A'));
      expect(plan.days[0].breakfast.length, equals(1));
      expect(plan.days[0].breakfast[0].name, equals('Telur Ayam'));
    });

    test('getActiveMealPlan returns null when there is no active plan', () async {
      await sessionManager.saveToken('test-repo-token');

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {'plan_id': 'p-old', 'plan_name': 'Kaya Protein Ayam A', 'status': 'Inactive'}
            ]
          }),
          200,
        );
      });

      final service = MealPlanService(client: mockClient);
      final repo = MealPlanRepository(service: service, sessionManager: sessionManager);

      final plan = await repo.getActiveMealPlan();

      expect(plan, isNull);
    });

    test('activateMealPlan triggers sequential seeding and activates new plan', () async {
      await sessionManager.saveToken('test-repo-token');

      final List<String> requestedPaths = [];
      final mockClient = MockClient((request) async {
        requestedPaths.add(request.url.path);

        if (request.url.path.endsWith('/mealplan') && request.method == 'POST') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {'plan_id': 'p-new', 'plan_name': 'Kaya Protein Ayam A', 'status': 'Inactive'}
            }),
            201,
          );
        } else if (request.url.path.endsWith('/mealplan') && request.method == 'GET') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': [
                {'plan_id': 'p-old', 'plan_name': 'Menu Seimbang A', 'status': 'Active'}
              ]
            }),
            200,
          );
        } else if (request.url.path.endsWith('/mealplan/p-old') && request.method == 'PUT') {
          // Deactivating old plan
          final body = jsonDecode((request as http.Request).body);
          expect(body['status'], equals('Inactive'));
          return http.Response(jsonEncode({'success': true}), 200);
        } else if (request.url.path.endsWith('/mealplan/p-new/items') && request.method == 'POST') {
          // Seeding item
          return http.Response(jsonEncode({'success': true}), 201);
        } else if (request.url.path.endsWith('/mealplan/p-new') && request.method == 'PUT') {
          // Activating new plan
          final body = jsonDecode((request as http.Request).body);
          expect(body['status'], equals('Active'));
          return http.Response(jsonEncode({'success': true}), 200);
        }
        return http.Response('', 404);
      });

      final service = MealPlanService(client: mockClient);
      final repo = MealPlanRepository(service: service, sessionManager: sessionManager);

      // Package to activate
      const package = MealPackage(
        id: 'protein_a',
        name: 'Kaya Protein Ayam A',
        focusId: 'protein',
        caloriesKcal: 1800,
        isPopular: true,
        isRecommended: false,
        breakfastMenu: 'Telur Rebus',
        breakfastCal: 450,
        lunchMenu: 'Ayam Panggang',
        lunchCal: 650,
        dinnerMenu: 'Ayam Kukus',
        dinnerCal: 550,
        snackMenu: 'Yogurt',
        snackCal: 150,
      );

      await repo.activateMealPlan(package);

      // Check transaction sequence:
      // 1. Create container (POST /mealplan)
      expect(requestedPaths.first, endsWith('/mealplan'));
      
      // 2. We should have 28 items seeded (28 POST /mealplan/p-new/items)
      final seedCount = requestedPaths.where((path) => path.endsWith('/mealplan/p-new/items')).length;
      expect(seedCount, equals(28));

      // 3. Switch: GET old plans, update status of old plan to Inactive, update status of new plan to Active
      expect(requestedPaths.any((path) => path.endsWith('/mealplan/p-old')), isTrue);
      expect(requestedPaths.last, endsWith('/mealplan/p-new'));
    });

    test('activateMealPlan triggers rollback on seeding failure', () async {
      await sessionManager.saveToken('test-repo-token');

      final List<String> deletedPlans = [];
      int seedAttempt = 0;

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/mealplan') && request.method == 'POST') {
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {'plan_id': 'p-failed-draft', 'plan_name': 'Kaya Protein Ayam A', 'status': 'Inactive'}
            }),
            201,
          );
        } else if (request.url.path.endsWith('/mealplan/p-failed-draft/items') && request.method == 'POST') {
          seedAttempt++;
          if (seedAttempt == 5) {
            // Fail on 5th item
            return http.Response(jsonEncode({'success': false, 'message': 'Rate limit or failure'}), 500);
          }
          return http.Response(jsonEncode({'success': true}), 201);
        } else if (request.url.path.endsWith('/mealplan/p-failed-draft') && request.method == 'DELETE') {
          deletedPlans.add('p-failed-draft');
          return http.Response(jsonEncode({'success': true}), 200);
        }
        return http.Response('', 404);
      });

      final service = MealPlanService(client: mockClient);
      final repo = MealPlanRepository(service: service, sessionManager: sessionManager);

      const package = MealPackage(
        id: 'protein_a',
        name: 'Kaya Protein Ayam A',
        focusId: 'protein',
        caloriesKcal: 1800,
        isPopular: true,
        isRecommended: false,
        breakfastMenu: 'Telur Rebus',
        breakfastCal: 450,
        lunchMenu: 'Ayam Panggang',
        lunchCal: 650,
        dinnerMenu: 'Ayam Kukus',
        dinnerCal: 550,
        snackMenu: 'Yogurt',
        snackCal: 150,
      );

      await expectLater(
        repo.activateMealPlan(package),
        throwsA(isA<Exception>()),
      );

      // Verify rollback: deleted the container plan
      expect(deletedPlans, contains('p-failed-draft'));
    });
  });
}
