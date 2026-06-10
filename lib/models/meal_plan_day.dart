import 'meal_plan_meal.dart';

class MealPlanDay {
  final int dayNumber;
  final List<MealPlanMeal> breakfast;
  final List<MealPlanMeal> lunch;
  final List<MealPlanMeal> dinner;
  final List<MealPlanMeal> snack;
  final int totalCalories;

  MealPlanDay({
    required this.dayNumber,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snack,
    required this.totalCalories,
  });

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'breakfast': breakfast.map((e) => e.toJson()).toList(),
      'lunch': lunch.map((e) => e.toJson()).toList(),
      'dinner': dinner.map((e) => e.toJson()).toList(),
      'snack': snack.map((e) => e.toJson()).toList(),
      'totalCalories': totalCalories,
    };
  }
}
