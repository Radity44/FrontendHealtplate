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
}
