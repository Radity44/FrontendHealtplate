import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/meal_plan.dart';
import '../models/meal_plan_day.dart';
import '../models/meal_plan_meal.dart';
import '../services/meal_plan_service.dart';
import '../services/session_manager.dart';
import 'profile_repository.dart';

class MappingResult {
  final String productId;
  final double portion;
  MappingResult(this.productId, this.portion);
}

class MealPlanRepository {
  final MealPlanService _service;
  final SessionManager _sessionManager;

  // Static variable to mock the active plan state for widget tests
  static MealPlan? mockActivePlan;

  MealPlanRepository({
    MealPlanService? service,
    SessionManager? sessionManager,
  })  : _service = service ?? MealPlanService(),
        _sessionManager = sessionManager ?? SessionManager();

  // Helper to map package menu items to the 10 backend database products with precise portion sizes
  MappingResult _mapMeal(String focusId, String mealTime, int targetCalories) {
    // Default: Nasi Putih
    String pid = '0f088ee8-25dd-49f0-adb8-b734a925d163';
    double baseCal = 130.0;
    double baseSize = 100.0;

    if (mealTime == 'Breakfast') {
      if (focusId == 'protein') {
        // Telur Ayam
        pid = 'c0e3d042-cc23-4000-a919-e71db0784d90';
        baseCal = 77.0;
        baseSize = 50.0;
      } else {
        // Roti Tawar Sari Roti
        pid = '7d824792-18ec-4438-926f-ae5c353573c9';
        baseCal = 80.0;
        baseSize = 35.0;
      }
    } else if (mealTime == 'Lunch') {
      if (focusId == 'protein') {
        // Dada Ayam
        pid = '82b11c34-903e-4e48-9e86-558d72b95a4a';
        baseCal = 165.0;
        baseSize = 100.0;
      } else {
        // Nasi Putih
        pid = '0f088ee8-25dd-49f0-adb8-b734a925d163';
        baseCal = 130.0;
        baseSize = 100.0;
      }
    } else if (mealTime == 'Dinner') {
      // Dada Ayam (seimbang/sayur/protein dinner)
      pid = '82b11c34-903e-4e48-9e86-558d72b95a4a';
      baseCal = 165.0;
      baseSize = 100.0;
    } else if (mealTime == 'Snack') {
      // Pisang Ambon
      pid = 'e197da45-93b4-4444-b26a-f78d269c484b';
      baseCal = 89.0;
      baseSize = 100.0;
    }

    final double portion = (targetCalories * baseSize / baseCal);
    return MappingResult(pid, portion);
  }

  // GET active meal plan
  Future<MealPlan?> getActiveMealPlan() async {
    if (ProfileRepository.useMockDataForTests) {
      return mockActivePlan;
    }

    final token = await _sessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesi telah berakhir. Silakan masuk kembali.');
    }

    final plans = await _service.fetchUserMealPlans(token);
    final activeJson = plans.firstWhere(
      (plan) => plan['status'] == 'Active',
      orElse: () => null,
    );

    if (activeJson == null) {
      return null;
    }

    final planId = activeJson['plan_id'] as String;
    final detail = await _service.fetchMealPlanDetail(planId, token);
    
    return MealPlan.fromJson(activeJson, items: detail['meal_plan_items'] as List<dynamic>?);
  }

  // Deactivate all active plans
  Future<void> deactivateActiveMealPlans() async {
    if (ProfileRepository.useMockDataForTests) {
      mockActivePlan = null;
      return;
    }

    final token = await _sessionManager.getToken();
    if (token == null || token.isEmpty) return;

    final plans = await _service.fetchUserMealPlans(token);
    for (var plan in plans) {
      if (plan['status'] == 'Active') {
        final planId = plan['plan_id'] as String;
        final name = plan['plan_name'] as String? ?? 'Meal Plan';
        await _service.updateMealPlanStatus(planId, name, 'Inactive', token);
      }
    }
  }

  // Activate a specific meal plan package
  Future<void> activateMealPlan(MealPackage package) async {
    if (ProfileRepository.useMockDataForTests) {
      // Map mock day details
      final mockDays = List.generate(7, (i) {
        return MealPlanDay(
          dayNumber: i + 1,
          breakfast: [
            MealPlanMeal(
              id: 'mock-bf-id',
              name: package.breakfastMenu.isNotEmpty ? package.breakfastMenu : 'Breakfast',
              calories: package.breakfastCal,
              protein: 20,
              carbohydrate: 45,
              fat: 10,
            )
          ],
          lunch: [
            MealPlanMeal(
              id: 'mock-ln-id',
              name: package.lunchMenu.isNotEmpty ? package.lunchMenu : 'Lunch',
              calories: package.lunchCal,
              protein: 40,
              carbohydrate: 55,
              fat: 12,
            )
          ],
          dinner: [
            MealPlanMeal(
              id: 'mock-dn-id',
              name: package.dinnerMenu.isNotEmpty ? package.dinnerMenu : 'Dinner',
              calories: package.dinnerCal,
              protein: 35,
              carbohydrate: 50,
              fat: 10,
            )
          ],
          snack: [
            MealPlanMeal(
              id: 'mock-sn-id',
              name: package.snackMenu.isNotEmpty ? package.snackMenu : 'Snack',
              calories: package.snackCal,
              protein: 5,
              carbohydrate: 30,
              fat: 2,
            )
          ],
          totalCalories: package.caloriesKcal,
        );
      });

      mockActivePlan = MealPlan(
        id: 'mock-plan-${package.id}',
        name: package.name,
        description: 'Mock active package description',
        nutritionFocus: 'Kaya Protein',
        durationDays: 7,
        isActive: true,
        createdAt: ProfileRepository.useMockDataForTests ? DateTime(2026, 6, 10) : DateTime.now(),
        days: mockDays,
      );
      return;
    }

    final token = await _sessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesi telah berakhir. Silakan masuk kembali.');
    }

    // 1. Create a new Inactive meal plan first
    final newPlan = await _service.createMealPlan(package.name, 'Inactive', token);
    final String? newPlanId = newPlan['plan_id'] as String?;
    if (newPlanId == null || newPlanId.isEmpty) {
      throw Exception('Gagal membuat rancangan meal plan di server.');
    }

    // 2. Add 28 items sequentially with rollback logic
    try {
      final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      for (var day in daysOfWeek) {
        // Breakfast
        final bf = _mapMeal(package.focusId, 'Breakfast', package.breakfastCal);
        await _service.addMealPlanItem(
          planId: newPlanId,
          productId: bf.productId,
          day: day,
          time: 'Breakfast',
          portion: bf.portion,
          token: token,
        );

        // Lunch
        final ln = _mapMeal(package.focusId, 'Lunch', package.lunchCal);
        await _service.addMealPlanItem(
          planId: newPlanId,
          productId: ln.productId,
          day: day,
          time: 'Lunch',
          portion: ln.portion,
          token: token,
        );

        // Dinner
        final dn = _mapMeal(package.focusId, 'Dinner', package.dinnerCal);
        await _service.addMealPlanItem(
          planId: newPlanId,
          productId: dn.productId,
          day: day,
          time: 'Dinner',
          portion: dn.portion,
          token: token,
        );

        // Snack
        final sn = _mapMeal(package.focusId, 'Snack', package.snackCal);
        await _service.addMealPlanItem(
          planId: newPlanId,
          productId: sn.productId,
          day: day,
          time: 'Snack',
          portion: sn.portion,
          token: token,
        );
      }

      // 3. All items successfully seeded! Switch active status transactionally.
      await deactivateActiveMealPlans();
      await _service.updateMealPlanStatus(newPlanId, package.name, 'Active', token);
    } catch (e) {
      // 4. Seeding failed, perform rollback (delete the draft plan)
      try {
        await _service.deleteMealPlan(newPlanId, token);
      } catch (rollbackError) {
        // Log rollback error but proceed to throw original error
        debugPrint('Rollback failed for meal plan: $rollbackError');
      }
      rethrow;
    }
  }
}
