class UserProfile {
  final String id;
  final String name;
  final String email;
  final String birthDate; // 'YYYY-MM-DD'
  final String gender;    // 'Male' or 'Female'
  final int heightCm;
  final int weightKg;
  final String? avatarUrl; // Nullable as it could be null/empty initially
  final int caloriesKcal;
  final int proteinG;
  final int carbohydrateG;
  final int fatG;
  final int sugarG;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.birthDate,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    this.avatarUrl,
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbohydrateG,
    required this.fatG,
    required this.sugarG,
  });

  double get bmi {
    if (heightCm <= 0) return 0.0;
    final heightMeters = heightCm / 100.0;
    return weightKg / (heightMeters * heightMeters);
  }

  String get bmiStatus {
    final value = bmi;
    if (value <= 0) return '-';
    if (value < 18.5) return 'Kurus';
    if (value < 25.0) return 'Normal';
    if (value < 30.0) return 'Overweight';
    return 'Obesitas';
  }

  bool get hasNutritionTarget =>
      caloriesKcal > 0 &&
      proteinG > 0 &&
      carbohydrateG > 0 &&
      fatG > 0;

  // Convert UserProfile to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'birth_date': birthDate,
      'gender': gender,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'avatar_url': avatarUrl,
      'calories_kcal': caloriesKcal,
      'protein_g': proteinG,
      'carbohydrate_g': carbohydrateG,
      'fat_g': fatG,
      'sugar_g': sugarG,
    };
  }

  // Create UserProfile from JSON Map
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? json['user_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      birthDate: json['birth_date'] ?? json['birthDate'] ?? '',
      gender: json['gender'] ?? '',
      heightCm: (json['height_cm'] ?? json['heightCm'] ?? 0) as int,
      weightKg: (json['weight_kg'] ?? json['weightKg'] ?? 0) as int,
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      caloriesKcal: (json['calories_kcal'] ?? json['caloriesKcal'] ?? 0) as int,
      proteinG: (json['protein_g'] ?? json['proteinG'] ?? 0) as int,
      carbohydrateG: (json['carbohydrate_g'] ?? json['carbohydrateG'] ?? 0) as int,
      fatG: (json['fat_g'] ?? json['fatG'] ?? 0) as int,
      sugarG: (json['sugar_g'] ?? json['sugarG'] ?? 0) as int,
    );
  }

  // Helper method for copying/updating fields locally
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? birthDate,
    String? gender,
    int? heightCm,
    int? weightKg,
    String? avatarUrl,
    int? caloriesKcal,
    int? proteinG,
    int? carbohydrateG,
    int? fatG,
    int? sugarG,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      proteinG: proteinG ?? this.proteinG,
      carbohydrateG: carbohydrateG ?? this.carbohydrateG,
      fatG: fatG ?? this.fatG,
      sugarG: sugarG ?? this.sugarG,
    );
  }
}
