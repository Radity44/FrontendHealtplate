class MealPlanMeal {
  final String id;
  final String name;
  final int calories;
  final int protein;
  final int carbohydrate;
  final int fat;
  final String? imageUrl;
  final double portion;

  MealPlanMeal({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbohydrate,
    required this.fat,
    this.imageUrl,
    this.portion = 100.0,
  });

  factory MealPlanMeal.fromJson(Map<String, dynamic> json) {
    // If food_products exists inside a meal_plan_item, parse it. Otherwise parse from self.
    final food = json['food_products'] ?? json;
    
    // Portion scaling logic: backend returns a 'portion' field at the meal_plan_item level.
    // If a portion exists and serving_size_g exists, we can scale the nutrients,
    // but the backend detail API already scales consumed_calories, etc. for logs,
    // but for meal plan items, let's look at the response:
    // the item has portion and food_products contains the base calories/nutrients of the food product.
    // Let's scale it in our frontend if needed, or check if the backend scales it.
    // To be perfectly accurate, we scale the base values of food_products by portion / serving_size_g:
    final double portion = (json['portion'] as num?)?.toDouble() ?? 100.0;
    final double servingSize = (food['serving_size_g'] as num?)?.toDouble() ?? 100.0;
    final double scale = portion / (servingSize > 0 ? servingSize : 100.0);

    final baseCal = (food['calories_kcal'] as num?)?.toDouble() ?? 0.0;
    final baseProt = (food['protein_g'] as num?)?.toDouble() ?? 0.0;
    final baseCarb = (food['carbohydrate_g'] as num?)?.toDouble() ?? 0.0;
    final baseFat = (food['fat_g'] as num?)?.toDouble() ?? 0.0;

    return MealPlanMeal(
      id: json['product_id'] as String? ?? food['product_id'] as String? ?? '',
      name: food['product_name'] as String? ?? '',
      calories: (baseCal * scale).round(),
      protein: (baseProt * scale).round(),
      carbohydrate: (baseCarb * scale).round(),
      fat: (baseFat * scale).round(),
      imageUrl: food['image_url'] as String?,
      portion: portion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbohydrate': carbohydrate,
      'fat': fat,
      'imageUrl': imageUrl,
      'portion': portion,
    };
  }
}
