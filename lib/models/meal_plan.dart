class MealFocus {
  final String id;
  final String title;
  final String description;
  final String icon;

  const MealFocus({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class MealPackage {
  final String id;
  final String name;
  final String focusId;
  final int caloriesKcal;
  final bool isPopular;
  final bool isRecommended;
  final String breakfastMenu;
  final int breakfastCal;
  final String lunchMenu;
  final int lunchCal;
  final String dinnerMenu;
  final int dinnerCal;
  final String snackMenu;
  final int snackCal;

  const MealPackage({
    required this.id,
    required this.name,
    required this.focusId,
    required this.caloriesKcal,
    required this.isPopular,
    required this.isRecommended,
    required this.breakfastMenu,
    required this.breakfastCal,
    required this.lunchMenu,
    required this.lunchCal,
    required this.dinnerMenu,
    required this.dinnerCal,
    required this.snackMenu,
    required this.snackCal,
  });
}

// Global static lists for simulation
const List<MealFocus> dummyMealFocuses = [
  MealFocus(
    id: 'protein',
    title: 'Kaya Protein',
    description: 'Cocok untuk meningkatkan asupan protein harian.',
    icon: '💪',
  ),
  MealFocus(
    id: 'sayur',
    title: 'Kaya Sayur',
    description: 'Lebih banyak menu berbasis sayuran.',
    icon: '🥦',
  ),
  MealFocus(
    id: 'balanced',
    title: 'Seimbang',
    description: 'Kombinasi protein, karbohidrat, dan sayur.',
    icon: '⚖️',
  ),
  MealFocus(
    id: 'low_sugar',
    title: 'Rendah Gula',
    description: 'Cocok untuk menjaga kadar gula darah.',
    icon: '🩸',
  ),
  MealFocus(
    id: 'low_calorie',
    title: 'Rendah Kalori',
    description: 'Untuk membantu menjaga berat badan.',
    icon: '🔥',
  ),
];

const List<MealPackage> dummyMealPackages = [
  // Kaya Protein (protein)
  MealPackage(
    id: 'protein_a',
    name: 'Kaya Protein Ayam A',
    focusId: 'protein',
    caloriesKcal: 1800,
    isPopular: true,
    isRecommended: false,
    breakfastMenu: 'Telur Rebus + Oatmeal',
    breakfastCal: 450,
    lunchMenu: 'Ayam Panggang + Nasi Merah',
    lunchCal: 650,
    dinnerMenu: 'Ayam Kukus + Bayam',
    dinnerCal: 550,
    snackMenu: 'Yogurt Rendah Gula',
    snackCal: 150,
  ),
  MealPackage(
    id: 'protein_b',
    name: 'Kaya Protein Ayam B',
    focusId: 'protein',
    caloriesKcal: 2000,
    isPopular: false,
    isRecommended: false,
    breakfastMenu: 'Omelet Spesial',
    breakfastCal: 500,
    lunchMenu: 'Ayam Teriyaki & Sayuran',
    lunchCal: 700,
    dinnerMenu: 'Ayam Bakar Madu',
    dinnerCal: 600,
    snackMenu: 'Kacang Almond Panggang',
    snackCal: 200,
  ),
  MealPackage(
    id: 'protein_c',
    name: 'Kaya Protein Ikan A',
    focusId: 'protein',
    caloriesKcal: 1900,
    isPopular: false,
    isRecommended: true,
    breakfastMenu: 'Susu Rendah Lemak & Granola',
    breakfastCal: 400,
    lunchMenu: 'Salad Ikan Tuna Segar',
    lunchCal: 600,
    dinnerMenu: 'Salmon Panggang Asparagus',
    dinnerCal: 700,
    snackMenu: 'Greek Yogurt',
    snackCal: 200,
  ),

  // Kaya Sayur (sayur)
  MealPackage(
    id: 'sayur_a',
    name: 'Kaya Sayur Sup A',
    focusId: 'sayur',
    caloriesKcal: 1500,
    isPopular: false,
    isRecommended: true,
    breakfastMenu: 'Smoothie Buah & Sayur',
    breakfastCal: 350,
    lunchMenu: 'Gado-gado Salad',
    lunchCal: 550,
    dinnerMenu: 'Sup Sayur & Tahu',
    dinnerCal: 450,
    snackMenu: 'Salad Buah Segar',
    snackCal: 150,
  ),
  MealPackage(
    id: 'sayur_b',
    name: 'Kaya Sayur Tumis B',
    focusId: 'sayur',
    caloriesKcal: 1700,
    isPopular: true,
    isRecommended: false,
    breakfastMenu: 'Roti Gandum & Alpukat',
    breakfastCal: 400,
    lunchMenu: 'Tumis Brokoli Wortel Jamur + Tempe',
    lunchCal: 650,
    dinnerMenu: 'Cah Kangkung & Tahu Kukus',
    dinnerCal: 500,
    snackMenu: 'Buah Apel Potong',
    snackCal: 150,
  ),

  // Seimbang (balanced)
  MealPackage(
    id: 'balanced_a',
    name: 'Menu Seimbang A',
    focusId: 'balanced',
    caloriesKcal: 1800,
    isPopular: false,
    isRecommended: true,
    breakfastMenu: 'Sandwich Gandum Telur',
    breakfastCal: 450,
    lunchMenu: 'Nasi Putih + Daging Sapi Lada Hitam + Capcay',
    lunchCal: 650,
    dinnerMenu: 'Pepes Tahu + Sup Ayam Jagung',
    dinnerCal: 550,
    snackMenu: 'Pisang Rebus',
    snackCal: 150,
  ),
  MealPackage(
    id: 'balanced_b',
    name: 'Menu Seimbang B',
    focusId: 'balanced',
    caloriesKcal: 2000,
    isPopular: true,
    isRecommended: false,
    breakfastMenu: 'Bubur Ayam Tanpa Santan',
    breakfastCal: 500,
    lunchMenu: 'Nasi Merah + Ikan Kembung Bakar + Sayur Asem',
    lunchCal: 700,
    dinnerMenu: 'Sate Ayam Dada Tanpa Kulit + Lalapan',
    dinnerCal: 600,
    snackMenu: 'Salad Pepaya Mangga',
    snackCal: 200,
  ),

  // Rendah Gula (low_sugar)
  MealPackage(
    id: 'low_sugar_a',
    name: 'Rendah Gula Fit A',
    focusId: 'low_sugar',
    caloriesKcal: 1600,
    isPopular: true,
    isRecommended: false,
    breakfastMenu: 'Chia Seed Pudding',
    breakfastCal: 350,
    lunchMenu: 'Dada Ayam Panggang + Quinoa Salad',
    lunchCal: 600,
    dinnerMenu: 'Pepes Ikan Nila + Tumis Buncis',
    dinnerCal: 500,
    snackMenu: 'Kacang Edamame Rebus',
    snackCal: 150,
  ),
  MealPackage(
    id: 'low_sugar_b',
    name: 'Rendah Gula Fit B',
    focusId: 'low_sugar',
    caloriesKcal: 1800,
    isPopular: false,
    isRecommended: true,
    breakfastMenu: 'Telur Orak-Arik Bayam',
    breakfastCal: 400,
    lunchMenu: 'Beef Stir-fry with Shirataki Noodles',
    lunchCal: 650,
    dinnerMenu: 'Grilled Salmon & Steamed Broccoli',
    dinnerCal: 600,
    snackMenu: 'Keju Blok Rendah Lemak',
    snackCal: 150,
  ),

  // Rendah Kalori (low_calorie)
  MealPackage(
    id: 'low_calorie_a',
    name: 'Rendah Kalori Light A',
    focusId: 'low_calorie',
    caloriesKcal: 1200,
    isPopular: false,
    isRecommended: true,
    breakfastMenu: 'Teh Hijau + Putih Telur Rebus',
    breakfastCal: 250,
    lunchMenu: 'Sup Jamur Bening & Dada Ayam Suwir',
    lunchCal: 450,
    dinnerMenu: 'Tumis Tahu Toge Sedikit Minyak',
    dinnerCal: 400,
    snackMenu: 'Buah Jeruk',
    snackCal: 100,
  ),
  MealPackage(
    id: 'low_calorie_b',
    name: 'Rendah Kalori Light B',
    focusId: 'low_calorie',
    caloriesKcal: 1400,
    isPopular: true,
    isRecommended: false,
    breakfastMenu: 'Oatmeal Plain & Stroberi',
    breakfastCal: 300,
    lunchMenu: 'Salad Ayam Saus Lemon',
    lunchCal: 550,
    dinnerMenu: 'Sup Labu Kuning & Tempe Panggang',
    dinnerCal: 450,
    snackMenu: 'Buah Semangka',
    snackCal: 100,
  ),
];
