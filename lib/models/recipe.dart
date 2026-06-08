class RecipeStep {
  final int stepNumber;
  final String instruction;

  const RecipeStep({
    required this.stepNumber,
    required this.instruction,
  });
}

class RecipeIngredient {
  final String name;
  final String quantity;

  const RecipeIngredient({
    required this.name,
    required this.quantity,
  });
}

class Recipe {
  final String id;
  final String name;
  final String category;
  final String description;
  final String imagePath;
  final int caloriesKcal;
  final int proteinG;
  final int carbohydrateG;
  final int fatG;
  final int sugarG;
  final int prepTimeMinutes;
  final String difficulty;
  final String servings;
  final bool isMealPlanFriendly;
  final String nutritionTip;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;

  const Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.imagePath,
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbohydrateG,
    required this.fatG,
    required this.sugarG,
    required this.prepTimeMinutes,
    required this.difficulty,
    required this.servings,
    required this.isMealPlanFriendly,
    required this.nutritionTip,
    required this.ingredients,
    required this.steps,
  });
}
