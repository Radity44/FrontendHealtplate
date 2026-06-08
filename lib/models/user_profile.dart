class UserProfile {
  final String name;
  final String email;
  final String gender; // 'Male' or 'Female'
  final String birthDate; // 'YYYY-MM-DD'
  final int heightCm;
  final int weightKg;
  final int caloriesKcal;
  final int proteinG;
  final int carbohydrateG;
  final int fatG;
  final int sugarG;

  UserProfile({
    required this.name,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.heightCm,
    required this.weightKg,
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbohydrateG,
    required this.fatG,
    required this.sugarG,
  });

  // Convert UserProfile to a JSON Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'gender': gender,
      'birthDate': birthDate,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'caloriesKcal': caloriesKcal,
      'proteinG': proteinG,
      'carbohydrateG': carbohydrateG,
      'fatG': fatG,
      'sugarG': sugarG,
    };
  }

  // Create UserProfile from JSON Map
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      birthDate: json['birthDate'] ?? '',
      heightCm: json['heightCm'] ?? 0,
      weightKg: json['weightKg'] ?? 0,
      caloriesKcal: json['caloriesKcal'] ?? 0,
      proteinG: json['proteinG'] ?? 0,
      carbohydrateG: json['carbohydrateG'] ?? 0,
      fatG: json['fatG'] ?? 0,
      sugarG: json['sugarG'] ?? 0,
    );
  }
}
