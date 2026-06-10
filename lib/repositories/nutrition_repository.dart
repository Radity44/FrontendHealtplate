import '../services/nutrition_service.dart';
import '../models/food_product.dart';
import 'profile_repository.dart';

class NutritionRepository {
  final NutritionService _nutritionService;

  NutritionRepository({
    NutritionService? nutritionService,
  }) : _nutritionService = nutritionService ?? NutritionService();

  Future<List<FoodProduct>> searchFoods(String query) async {
    if (ProfileRepository.useMockDataForTests) {
      return [
        FoodProduct(
          productId: 'mock-p-1',
          productName: 'Nasi Goreng Spesial',
          brandName: 'Generic',
          caloriesKcal: 350,
          proteinG: 10,
          carbohydrateG: 50,
          fatG: 12,
          sugarG: 2,
        ),
        FoodProduct(
          productId: 'mock-p-2',
          productName: 'Teh Manis',
          brandName: 'Generic',
          caloriesKcal: 80,
          proteinG: 0,
          carbohydrateG: 20,
          fatG: 0,
          sugarG: 18,
        ),
      ];
    }

    return _nutritionService.searchFoods(query);
  }

  Future<FoodProduct> fetchFoodDetail(String id) async {
    if (ProfileRepository.useMockDataForTests) {
      return FoodProduct(
        productId: id,
        productName: 'Nasi Goreng Spesial',
        brandName: 'Generic',
        caloriesKcal: 350,
        proteinG: 10,
        carbohydrateG: 50,
        fatG: 12,
        sugarG: 2,
      );
    }

    return _nutritionService.fetchFoodDetail(id);
  }
}

