import 'package:flutter/material.dart';
import '../models/recipe.dart';

class DetailResepScreen extends StatefulWidget {
  final Recipe recipe;
  final bool initialFavorite;
  final ValueChanged<bool>? onFavoriteToggled;

  const DetailResepScreen({
    super.key,
    required this.recipe,
    this.initialFavorite = false,
    this.onFavoriteToggled,
  });

  @override
  State<DetailResepScreen> createState() => _DetailResepScreenState();
}

class _DetailResepScreenState extends State<DetailResepScreen> {
  // Theme colors
  static const Color primaryGreen = Color(0xFF095D40);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color bgSoft = Color(0xFFF8FAFC);

  late bool _isFavorite;
  final Set<int> _checkedIngredients = {}; // UI-only checkoff state

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialFavorite;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    if (widget.onFavoriteToggled != null) {
      widget.onFavoriteToggled!(_isFavorite);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? 'Ditambahkan ke Favorit' : 'Dihapus dari Favorit'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Scaffold(
      backgroundColor: bgSoft,
      body: CustomScrollView(
        slivers: [
          // Hero Image AppBar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: primaryGreen,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: textDark, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : textDark,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'recipe_image_${recipe.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      recipe.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(
                            Icons.restaurant,
                            color: textMuted,
                            size: 64,
                          ),
                        );
                      },
                    ),
                    // Shadow overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Recipe Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meal Plan Friendly Badge if active
                  if (recipe.isMealPlanFriendly) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('⭐ ', style: TextStyle(fontSize: 12)),
                          Text(
                            'Meal Plan Friendly',
                            style: TextStyle(
                              color: Color(0xFF0369A1),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Title & Category
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          recipe.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recipe.category.toUpperCase(),
                    style: const TextStyle(
                      color: accentTeal,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Row: Duration, Difficulty, Servings
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.access_time_filled,
                          label: 'DURASI',
                          value: '${recipe.prepTimeMinutes} Menit',
                          color: const Color(0xFFF59E0B),
                        ),
                        Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
                        _buildStatItem(
                          icon: Icons.speed,
                          label: 'KESULITAN',
                          value: recipe.difficulty,
                          color: const Color(0xFF3B82F6),
                        ),
                        Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
                        _buildStatItem(
                          icon: Icons.restaurant_menu,
                          label: 'PORSI',
                          value: recipe.servings,
                          color: primaryGreen,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    recipe.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: textMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nutrition Cards
                  const Text(
                    'Kandungan Nutrisi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildNutritionGrid(recipe),
                  const SizedBox(height: 24),

                  // Ingredients
                  const Text(
                    'Bahan yang Dibutuhkan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sentuh bahan untuk menandai yang sudah siap.',
                    style: TextStyle(
                      fontSize: 12,
                      color: textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildIngredientsList(recipe),
                  const SizedBox(height: 24),

                  // Steps
                  const Text(
                    'Langkah Memasak',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStepsTimeline(recipe),
                  const SizedBox(height: 28),

                  // Nutrition Tips Card
                  _buildNutritionTipCard(recipe),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionGrid(Recipe recipe) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Calories main card inside
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_fire_department, color: accentTeal, size: 24),
              const SizedBox(width: 6),
              Text(
                '${recipe.caloriesKcal} kcal',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Estimasi Kalori per Porsi',
            style: TextStyle(fontSize: 11, color: textMuted),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 20),
          // Macro grid details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroProgress('Protein', '${recipe.proteinG}g', primaryGreen),
              _buildMacroProgress('Karbo', '${recipe.carbohydrateG}g', const Color(0xFFF97316)),
              _buildMacroProgress('Lemak', '${recipe.fatG}g', const Color(0xFF0284C7)),
              _buildMacroProgress('Gula', '${recipe.sugarG}g', const Color(0xFFDC2626)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroProgress(String name, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList(Recipe recipe) {
    return Column(
      children: List.generate(recipe.ingredients.length, (index) {
        final ingredient = recipe.ingredients[index];
        final isChecked = _checkedIngredients.contains(index);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isChecked) {
                _checkedIngredients.remove(index);
              } else {
                _checkedIngredients.add(index);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isChecked ? const Color(0xFFECFDF5) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isChecked ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isChecked ? primaryGreen : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isChecked ? primaryGreen : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 12,
                    color: isChecked ? Colors.white : Colors.transparent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    ingredient.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: isChecked ? textMuted : textDark,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      fontWeight: isChecked ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  ingredient.quantity,
                  style: TextStyle(
                    fontSize: 14,
                    color: isChecked ? textMuted : primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepsTimeline(Recipe recipe) {
    return Column(
      children: List.generate(recipe.steps.length, (index) {
        final step = recipe.steps[index];
        final isLast = index == recipe.steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline circle and line
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${step.stepNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: const Color(0xFFCBD5E1),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Step card
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  step.instruction,
                  style: const TextStyle(
                    fontSize: 14,
                    color: textDark,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNutritionTipCard(Recipe recipe) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFE0DA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tips Nutrisi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  recipe.nutritionTip,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0F4030),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
