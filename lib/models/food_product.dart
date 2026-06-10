class FoodProduct {
  final String productId;
  final String productName;
  final String? brandName;
  final double caloriesKcal;
  final double proteinG;
  final double carbohydrateG;
  final double fatG;
  final double sugarG;
  final String? imageUrl;

  FoodProduct({
    required this.productId,
    required this.productName,
    this.brandName,
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbohydrateG,
    required this.fatG,
    required this.sugarG,
    this.imageUrl,
  });

  factory FoodProduct.fromJson(Map<String, dynamic> json) {
    return FoodProduct(
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      brandName: json['brand_name'] as String?,
      caloriesKcal: (json['calories_kcal'] as num?)?.toDouble() ?? 0.0,
      proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0.0,
      carbohydrateG: (json['carbohydrate_g'] as num?)?.toDouble() ?? 0.0,
      fatG: (json['fat_g'] as num?)?.toDouble() ?? 0.0,
      sugarG: (json['sugar_g'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'brand_name': brandName,
      'calories_kcal': caloriesKcal,
      'protein_g': proteinG,
      'carbohydrate_g': carbohydrateG,
      'fat_g': fatG,
      'sugar_g': sugarG,
      'image_url': imageUrl,
    };
  }
}
