import '../models/recipe.dart';

const List<Recipe> dummyRecipes = [
  Recipe(
    id: 'ayam_panggang_herbal',
    name: 'Ayam Panggang Herbal',
    category: 'Kaya Protein',
    description: 'Dada ayam empuk panggang dengan racikan rempah rosemary dan garlic yang menyehatkan.',
    imagePath: 'assets/images/food_lunch.png',
    caloriesKcal: 420,
    proteinG: 35,
    carbohydrateG: 10,
    fatG: 12,
    sugarG: 2,
    prepTimeMinutes: 25,
    difficulty: 'Mudah',
    servings: '2 Porsi',
    isMealPlanFriendly: true,
    nutritionTip: 'Konsumsi dada ayam tanpa kulit untuk mengurangi asupan lemak jenuh tanpa mengurangi kandungan protein.',
    ingredients: [
      RecipeIngredient(name: 'Dada ayam fillet', quantity: '200 gr'),
      RecipeIngredient(name: 'Bawang putih cincang', quantity: '1 sdt'),
      RecipeIngredient(name: 'Olive oil', quantity: '1 sdm'),
      RecipeIngredient(name: 'Rosemary kering', quantity: '1/2 sdt'),
      RecipeIngredient(name: 'Garam & lada hitam', quantity: 'secukupnya'),
    ],
    steps: [
      RecipeStep(stepNumber: 1, instruction: 'Lumuri dada ayam dengan bawang putih, rosemary, olive oil, garam, dan lada.'),
      RecipeStep(stepNumber: 2, instruction: 'Diamkan selama 10 menit agar bumbu meresap sempurna.'),
      RecipeStep(stepNumber: 3, instruction: 'Panggang di oven suhu 200°C selama 20 menit hingga matang kecokelatan.'),
      RecipeStep(stepNumber: 4, instruction: 'Angkat dan sajikan selagi hangat dengan sayuran pendamping.'),
    ],
  ),
  Recipe(
    id: 'omelet_protein_tinggi',
    name: 'Omelet Protein Tinggi',
    category: 'Kaya Protein',
    description: 'Omelet putih telur dengan bayam segar dan jamur kancing, kaya akan protein berkualitas tinggi.',
    imagePath: 'assets/images/food_breakfast.png',
    caloriesKcal: 320,
    proteinG: 25,
    carbohydrateG: 5,
    fatG: 15,
    sugarG: 1,
    prepTimeMinutes: 15,
    difficulty: 'Mudah',
    servings: '1 Porsi',
    isMealPlanFriendly: true,
    nutritionTip: 'Bayam kaya zat besi yang membantu pengikatan oksigen dalam darah untuk performa olahraga maksimal.',
    ingredients: [
      RecipeIngredient(name: 'Putih telur', quantity: '4 butir'),
      RecipeIngredient(name: 'Telur utuh', quantity: '1 butir'),
      RecipeIngredient(name: 'Bayam segar', quantity: '50 gr'),
      RecipeIngredient(name: 'Jamur kancing iris', quantity: '50 gr'),
      RecipeIngredient(name: 'Minyak kelapa', quantity: '1 sdt'),
    ],
    steps: [
      RecipeStep(stepNumber: 1, instruction: 'Kocok telur dan putih telur dalam wadah, tambahkan sedikit garam dan merica.'),
      RecipeStep(stepNumber: 2, instruction: 'Tumis jamur dan bayam dalam wajan antilengket dengan minyak kelapa hingga layu.'),
      RecipeStep(stepNumber: 3, instruction: 'Tuang kocokan telur, masak dengan api kecil hingga bagian bawah matang.'),
      RecipeStep(stepNumber: 4, instruction: 'Lipat omelet menjadi setengah lingkaran dan balik perlahan hingga matang merata.'),
    ],
  ),
  Recipe(
    id: 'salad_sayur_segar',
    name: 'Salad Sayur Segar',
    category: 'Kaya Sayur',
    description: 'Kombinasi sayuran segar renyah dengan siraman dressing lemon olive oil yang segar dan ringan.',
    imagePath: 'assets/images/food_dinner.png',
    caloriesKcal: 180,
    proteinG: 4,
    carbohydrateG: 15,
    fatG: 8,
    sugarG: 4,
    prepTimeMinutes: 10,
    difficulty: 'Sangat Mudah',
    servings: '2 Porsi',
    isMealPlanFriendly: true,
    nutritionTip: 'Gunakan minyak zaitun extra virgin (EVOO) untuk asupan lemak sehat tak jenuh tunggal yang baik untuk jantung.',
    ingredients: [
      RecipeIngredient(name: 'Selada romania iris', quantity: '100 gr'),
      RecipeIngredient(name: 'Tomat ceri belah dua', quantity: '50 gr'),
      RecipeIngredient(name: 'Mentimun iris', quantity: '50 gr'),
      RecipeIngredient(name: 'Wortel parut halus', quantity: '50 gr'),
      RecipeIngredient(name: 'Olive oil extra virgin', quantity: '1 sdm'),
      RecipeIngredient(name: 'Air perasan lemon', quantity: '1 sdt'),
    ],
    steps: [
      RecipeStep(stepNumber: 1, instruction: 'Cuci bersih semua sayuran dengan air dingin mengalir.'),
      RecipeStep(stepNumber: 2, instruction: 'Potong-potong selada, mentimun, dan tomat ceri sesuai selera.'),
      RecipeStep(stepNumber: 3, instruction: 'Campurkan semua sayuran di dalam mangkuk salad besar.'),
      RecipeStep(stepNumber: 4, instruction: 'Siram dengan olive oil dan air lemon, lalu aduk perlahan hingga merata.'),
    ],
  ),
  Recipe(
    id: 'sup_sayuran',
    name: 'Sup Sayuran',
    category: 'Kaya Sayur',
    description: 'Sup hangat dengan potongan wortel, kentang, buncis, dan brokoli dalam kaldu bening yang gurih.',
    imagePath: 'assets/images/food_dinner.png',
    caloriesKcal: 150,
    proteinG: 3,
    carbohydrateG: 20,
    fatG: 2,
    sugarG: 3,
    prepTimeMinutes: 20,
    difficulty: 'Mudah',
    servings: '4 Porsi',
    isMealPlanFriendly: false,
    nutritionTip: 'Sup sayuran kaya serat pangan larut air yang mendukung kesehatan sistem pencernaan Anda.',
    ingredients: [
      RecipeIngredient(name: 'Kaldu sayur alami', quantity: '500 ml'),
      RecipeIngredient(name: 'Wortel potong bulat', quantity: '1 buah'),
      RecipeIngredient(name: 'Kentang potong dadu', quantity: '1 buah'),
      RecipeIngredient(name: 'Buncis potong 2cm', quantity: '50 gr'),
      RecipeIngredient(name: 'Brokoli potong per kuntum', quantity: '50 gr'),
      RecipeIngredient(name: 'Bawang bombay cincang', quantity: '1/4 buah'),
      RecipeIngredient(name: 'Daun bawang iris', quantity: '1 batang'),
    ],
    steps: [
      RecipeStep(stepNumber: 1, instruction: 'Didihkan kaldu sayur dalam panci ukuran sedang.'),
      RecipeStep(stepNumber: 2, instruction: 'Tumis bawang bombay hingga harum, lalu masukkan ke dalam panci kaldu.'),
      RecipeStep(stepNumber: 3, instruction: 'Masukkan kentang dan wortel terlebih dahulu, rebus selama 5 menit hingga agak empuk.'),
      RecipeStep(stepNumber: 4, instruction: 'Tambahkan buncis, brokoli, dan daun bawang. Masak dengan garam dan merica hingga matang.'),
    ],
  ),
  Recipe(
    id: 'nasi_merah_ayam_panggang',
    name: 'Nasi Merah Ayam Panggang',
    category: 'Seimbang',
    description: 'Kombinasi nasi merah pulen, dada ayam panggang juicy, dan tumis buncis wortel yang seimbang secara makro.',
    imagePath: 'assets/images/food_lunch.png',
    caloriesKcal: 450,
    proteinG: 30,
    carbohydrateG: 45,
    fatG: 10,
    sugarG: 2,
    prepTimeMinutes: 30,
    difficulty: 'Sedang',
    servings: '1 Porsi',
    isMealPlanFriendly: true,
    nutritionTip: 'Karbohidrat kompleks dari nasi merah dicerna lebih lambat sehingga memberi energi yang stabil sepanjang hari.',
    ingredients: [
      RecipeIngredient(name: 'Nasi merah hangat', quantity: '150 gr'),
      RecipeIngredient(name: 'Dada ayam panggang iris', quantity: '120 gr'),
      RecipeIngredient(name: 'Buncis iris', quantity: '50 gr'),
      RecipeIngredient(name: 'Wortel potong korek api', quantity: '50 gr'),
      RecipeIngredient(name: 'Minyak wijen', quantity: '1 sdt'),
    ],
    steps: [
      RecipeStep(stepNumber: 1, instruction: 'Siapkan nasi merah hangat di atas piring saji.'),
      RecipeStep(stepNumber: 2, instruction: 'Iris dada ayam panggang tipis-tipis menyerong.'),
      RecipeStep(stepNumber: 3, instruction: 'Tumis buncis dan wortel dengan sedikit minyak wijen hingga layu dan matang.'),
      RecipeStep(stepNumber: 4, instruction: 'Tata nasi merah, dada ayam panggang, dan tumisan sayur di piring lalu sajikan.'),
    ],
  ),
  Recipe(
    id: 'sandwich_sehat',
    name: 'Sandwich Sehat',
    category: 'Seimbang',
    description: 'Sandwich gandum dengan isian putih telur, smoked beef rendah lemak, selada, dan irisan alpukat mentega.',
    imagePath: 'assets/images/food_breakfast.png',
    caloriesKcal: 350,
    proteinG: 18,
    carbohydrateG: 35,
    fatG: 9,
    sugarG: 3,
    prepTimeMinutes: 12,
    difficulty: 'Mudah',
    servings: '1 Porsi',
    isMealPlanFriendly: true,
    nutritionTip: 'Alpukat memberikan asam lemak esensial omega-3 yang mendukung kesehatan otak dan sendi.',
    ingredients: [
      RecipeIngredient(name: 'Roti gandum', quantity: '2 lembar'),
      RecipeIngredient(name: 'Telur mata sapi (setengah matang/matang)', quantity: '1 butir'),
      RecipeIngredient(name: 'Selada segar', quantity: '2 lembar'),
      RecipeIngredient(name: 'Tomat iris', quantity: '3 iris'),
      RecipeIngredient(name: 'Alpukat mentega lumat', quantity: '1/4 buah'),
    ],
    steps: [
      RecipeStep(stepNumber: 1, instruction: 'Panggang roti gandum di wajan teflon tanpa mentega hingga sedikit kecokelatan.'),
      RecipeStep(stepNumber: 2, instruction: 'Oleskan alpukat lumat secara merata pada salah satu sisi roti gandum.'),
      RecipeStep(stepNumber: 3, instruction: 'Tata selada, tomat, dan telur mata sapi di atas bagian roti yang telah dioles alpukat.'),
      RecipeStep(stepNumber: 4, instruction: 'Tutup dengan roti gandum lainnya lalu potong secara diagonal.'),
    ],
  ),
  Recipe(
    id: 'yogurt_berry',
    name: 'Yogurt Berry',
    category: 'Rendah Gula',
    description: 'Greek yogurt polos yang creamy dipadukan dengan buah beri segar dan taburan chia seeds kaya serat.',
    imagePath: 'assets/images/food_snack.png',
    caloriesKcal: 190,
    proteinG: 12,
    carbohydrateG: 18,
    fatG: 4,
    sugarG: 5,
    prepTimeMinutes: 5,
    difficulty: 'Sangat Mudah',
    servings: '1 Porsi',
    isMealPlanFriendly: true,
    nutritionTip: 'Greek yogurt polos mengandung protein 2x lebih banyak dan gula 50% lebih sedikit daripada yogurt biasa.',
    ingredients: [
      RecipeIngredient(name: 'Greek yogurt plain', quantity: '150 gr'),
      RecipeIngredient(name: 'Stroberi iris', quantity: '4 buah'),
      RecipeIngredient(name: 'Bluberi segar', quantity: '10 butir'),
      RecipeIngredient(name: 'Chia seeds', quantity: '1 sdt'),
    ],
    steps: [
      RecipeStep(stepNumber: 1, instruction: 'Tuang greek yogurt polos ke dalam mangkuk saji.'),
      RecipeStep(stepNumber: 2, instruction: 'Tata irisan stroberi dan bluberi segar di atas permukaan yogurt.'),
      RecipeStep(stepNumber: 3, instruction: 'Taburkan chia seeds di atasnya untuk tekstur renyah kaya serat.'),
      RecipeStep(stepNumber: 4, instruction: 'Nikmati segera selagi dingin untuk sarapan atau camilan.'),
    ],
  ),
  Recipe(
    id: 'smoothie_tanpa_gula',
    name: 'Smoothie Tanpa Gula',
    category: 'Rendah Gula',
    description: 'Smoothie hijau lembut dari paduan bayam, pisang beku, alpukat, dan susu kedelai tanpa pemanis.',
    imagePath: 'assets/images/food_snack.png',
    caloriesKcal: 210,
    proteinG: 6,
    carbohydrateG: 22,
    fatG: 7,
    sugarG: 4,
    prepTimeMinutes: 8,
    difficulty: 'Sangat Mudah',
    servings: '1 Porsi',
    isMealPlanFriendly: false,
    nutritionTip: 'Pemanis alami dari buah pisang sudah cukup untuk memberi rasa manis tanpa perlu gula tambahan.',
    ingredients: [
      RecipeIngredient(name: 'Bayam baby segar', quantity: '1 genggam'),
      RecipeIngredient(name: 'Pisang ambon beku', quantity: '1/2 buah'),
      RecipeIngredient(name: 'Alpukat mentega', quantity: '1/4 buah'),
      RecipeIngredient(name: 'Susu kedelai tawar (unsweetened)', quantity: '200 ml'),
      RecipeIngredient(name: 'Es batu', quantity: 'secukupnya'),
    ],
    steps: [
      RecipeStep(stepNumber: 1, instruction: 'Masukkan bayam baby, alpukat, dan pisang beku ke dalam tabung blender.'),
      RecipeStep(stepNumber: 2, instruction: 'Tuangkan susu kedelai tawar dan tambahkan sedikit es batu.'),
      RecipeStep(stepNumber: 3, instruction: 'Blender semua bahan dengan kecepatan tinggi hingga halus dan lembut.'),
      RecipeStep(stepNumber: 4, instruction: 'Tuangkan ke dalam gelas saji tinggi dan nikmati selagi dingin.'),
    ],
  ),
  Recipe(
    id: 'sup_ayam_sayur',
    name: 'Sup Ayam Sayur',
    category: 'Rendah Kalori',
    description: 'Sup kaldu ayam gurih rendah lemak diisi potongan dada ayam empuk, wortel, kembang kol, dan daun seledri.',
    imagePath: 'assets/images/food_lunch.png',
    caloriesKcal: 220,
    proteinG: 22,
    carbohydrateG: 12,
    fatG: 5,
    sugarG: 2,
    prepTimeMinutes: 25,
    difficulty: 'Mudah',
    servings: '2 Porsi',
    isMealPlanFriendly: true,
    nutritionTip: 'Kaldu ayam bening kaya akan protein kolagen yang baik untuk kesehatan kulit dan pencernaan.',
    ingredients: [
      RecipeIngredient(name: 'Dada ayam fillet rebus', quantity: '100 gr'),
      RecipeIngredient(name: 'Wortel potong dadu', quantity: '1/2 buah'),
      RecipeIngredient(name: 'Kembang kol potong kecil', quantity: '50 gr'),
      RecipeIngredient(name: 'Daun seledri iris', quantity: '1 batang'),
      RecipeIngredient(name: 'Bawang putih memar', quantity: '2 siung'),
      RecipeIngredient(name: 'Kaldu ayam bening', quantity: '400 ml'),
    ],
    steps: [
      RecipeStep(stepNumber: 1, instruction: 'Rebus dada ayam fillet di air kaldu hingga matang, lalu suwir kasar.'),
      RecipeStep(stepNumber: 2, instruction: 'Tumis bawang putih memar di wajan terpisah, lalu masukkan ke air rebusan kaldu.'),
      RecipeStep(stepNumber: 3, instruction: 'Masukkan wortel dan kembang kol ke panci, rebus hingga sayuran empuk.'),
      RecipeStep(stepNumber: 4, instruction: 'Tambahkan ayam suwir dan irisan seledri, beri sedikit garam, lalu angkat dan sajikan.'),
    ],
  ),
  Recipe(
    id: 'tuna_salad_bowl',
    name: 'Tuna Salad Bowl',
    category: 'Rendah Kalori',
    description: 'Tuna kaleng dalam air (in water) disajikan dengan jagung manis pipil, tomat, timun, dan dressing mustard lemon.',
    imagePath: 'assets/images/food_lunch.png',
    caloriesKcal: 240,
    proteinG: 24,
    carbohydrateG: 10,
    fatG: 6,
    sugarG: 2,
    prepTimeMinutes: 15,
    difficulty: 'Mudah',
    servings: '1 Porsi',
    isMealPlanFriendly: true,
    nutritionTip: 'Ikan tuna adalah sumber protein rendah lemak dan tinggi asam lemak omega-3 EPA/DHA.',
    ingredients: [
      RecipeIngredient(name: 'Tuna kaleng in water tiriskan', quantity: '120 gr'),
      RecipeIngredient(name: 'Selada campur segar', quantity: '80 gr'),
      RecipeIngredient(name: 'Jagung manis rebus pipil', quantity: '30 gr'),
      RecipeIngredient(name: 'Mentimun iris tipis', quantity: '30 gr'),
      RecipeIngredient(name: 'Air lemon + dijon mustard (dressing)', quantity: '1 sdm + 1 sdt'),
    ],
    steps: [
      RecipeStep(stepNumber: 1, instruction: 'Tiriskan daging tuna kaleng dari air rendamannya.'),
      RecipeStep(stepNumber: 2, instruction: 'Tata selada campur, iris mentimun, dan jagung manis di mangkuk besar.'),
      RecipeStep(stepNumber: 3, instruction: 'Letakkan tuna di bagian tengah mangkuk sebagai toping.'),
      RecipeStep(stepNumber: 4, instruction: 'Campurkan dressing lemon mustard, siram di atas salad sesaat sebelum dinikmati.'),
    ],
  ),
];

Recipe getRecipeForMeal(String mealName) {
  final cleanName = mealName.toLowerCase();

  // Exact matching or substring matching
  for (var recipe in dummyRecipes) {
    if (cleanName.contains(recipe.name.toLowerCase()) || 
        recipe.name.toLowerCase().contains(cleanName)) {
      return recipe;
    }
  }

  // Keywords mapping
  if (cleanName.contains('ayam') || cleanName.contains('dada ayam') || cleanName.contains('chicken')) {
    if (cleanName.contains('panggang') || cleanName.contains('nasi merah')) {
      return dummyRecipes.firstWhere((r) => r.id == 'nasi_merah_ayam_panggang');
    }
    if (cleanName.contains('sup')) {
      return dummyRecipes.firstWhere((r) => r.id == 'sup_ayam_sayur');
    }
    return dummyRecipes.firstWhere((r) => r.id == 'ayam_panggang_herbal');
  }

  if (cleanName.contains('omelet') || cleanName.contains('telur') || cleanName.contains('egg')) {
    return dummyRecipes.firstWhere((r) => r.id == 'omelet_protein_tinggi');
  }

  if (cleanName.contains('salad') || cleanName.contains('gayo') || cleanName.contains('gado')) {
    if (cleanName.contains('tuna')) {
      return dummyRecipes.firstWhere((r) => r.id == 'tuna_salad_bowl');
    }
    return dummyRecipes.firstWhere((r) => r.id == 'salad_sayur_segar');
  }

  if (cleanName.contains('sup') || cleanName.contains('sayur') || cleanName.contains('tumis') || cleanName.contains('cah')) {
    if (cleanName.contains('ayam')) {
      return dummyRecipes.firstWhere((r) => r.id == 'sup_ayam_sayur');
    }
    return dummyRecipes.firstWhere((r) => r.id == 'sup_sayuran');
  }

  if (cleanName.contains('yogurt') || cleanName.contains('pudding') || cleanName.contains('chia')) {
    return dummyRecipes.firstWhere((r) => r.id == 'yogurt_berry');
  }

  if (cleanName.contains('smoothie')) {
    return dummyRecipes.firstWhere((r) => r.id == 'smoothie_tanpa_gula');
  }

  if (cleanName.contains('sandwich') || cleanName.contains('roti')) {
    return dummyRecipes.firstWhere((r) => r.id == 'sandwich_sehat');
  }

  // Default fallback (first item)
  return dummyRecipes.first;
}
