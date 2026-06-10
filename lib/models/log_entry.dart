import 'food_product.dart';

class LogEntry {
  final String entryId;
  final String mealTime;
  final double portion;
  final FoodProduct foodProduct;

  LogEntry({
    required this.entryId,
    required this.mealTime,
    required this.portion,
    required this.foodProduct,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      entryId: json['entry_id'] as String? ?? '',
      mealTime: json['meal_time'] as String? ?? '',
      portion: (json['portion'] as num?)?.toDouble() ?? 0.0,
      foodProduct: FoodProduct.fromJson(
        json['food_products'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entry_id': entryId,
      'meal_time': mealTime,
      'portion': portion,
      'food_products': foodProduct.toJson(),
    };
  }
}
