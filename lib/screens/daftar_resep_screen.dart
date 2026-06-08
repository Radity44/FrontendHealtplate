import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../data/recipe_dummy_data.dart';
import 'detail_resep_screen.dart';

class DaftarResepScreen extends StatefulWidget {
  const DaftarResepScreen({super.key});

  @override
  State<DaftarResepScreen> createState() => _DaftarResepScreenState();
}

class _DaftarResepScreenState extends State<DaftarResepScreen> with SingleTickerProviderStateMixin {
  // Theme colors
  static const Color primaryGreen = Color(0xFF095D40);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color bgSoft = Color(0xFFF8FAFC);

  // Search & Filter state
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  final Set<String> _favoriteRecipeIds = {}; // Local favorite state (UI only)

  final List<String> _categories = [
    'Semua',
    'Kaya Protein',
    'Kaya Sayur',
    'Seimbang',
    'Rendah Gula',
    'Rendah Kalori',
  ];

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<Recipe> get _filteredRecipes {
    return dummyRecipes.where((recipe) {
      final matchesSearch = recipe.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          recipe.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          recipe.category.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == 'Semua' || recipe.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _toggleFavorite(String recipeId) {
    setState(() {
      if (_favoriteRecipeIds.contains(recipeId)) {
        _favoriteRecipeIds.remove(recipeId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dihapus dari Favorit'),
            duration: Duration(milliseconds: 800),
          ),
        );
      } else {
        _favoriteRecipeIds.add(recipeId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ditambahkan ke Favorit'),
            duration: Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRecipes;

    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: _showSearchBar
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Cari resep sehat...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: textMuted, fontSize: 16),
                ),
                style: const TextStyle(color: textDark, fontSize: 16),
              )
            : const Text(
                'Resep Sehat',
                style: TextStyle(
                  color: textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearchBar ? Icons.close : Icons.search,
              color: textDark,
            ),
            onPressed: () {
              setState(() {
                if (_showSearchBar) {
                  _showSearchBar = false;
                  _searchController.clear();
                  _searchQuery = '';
                } else {
                  _showSearchBar = true;
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Collapsible Search Bar under AppBar (fallback/alternative style if preferred, but AppBar textfield is very clean.
          // Let's add a soft shadow divider
          Container(
            height: 1,
            color: Colors.black.withValues(alpha: 0.05),
          ),

          // Horizontal Category Chips
          _buildCategoryFilter(),

          // Grid / List Recipes Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: filtered.isEmpty
                  ? _buildEmptyState()
                  : _buildRecipeList(filtered),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? primaryGreen : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryGreen.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : textDark,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeList(List<Recipe> recipes) {
    return ListView.builder(
      key: ValueKey(_selectedCategory),
      padding: const EdgeInsets.all(20.0),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        final isFav = _favoriteRecipeIds.contains(recipe.id);

        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval((1.0 / recipes.length) * index, 1.0, curve: Curves.easeOut),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailResepScreen(
                          recipe: recipe,
                          initialFavorite: isFav,
                          onFavoriteToggled: (newFav) {
                            if (newFav) {
                              _favoriteRecipeIds.add(recipe.id);
                            } else {
                              _favoriteRecipeIds.remove(recipe.id);
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food Image with Hero & Badges
                      Stack(
                        children: [
                          Hero(
                            tag: 'recipe_image_${recipe.id}',
                            child: Image.asset(
                              recipe.imagePath,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 180,
                                  color: const Color(0xFFF1F5F9),
                                  child: const Icon(
                                    Icons.restaurant,
                                    color: textMuted,
                                    size: 48,
                                  ),
                                );
                              },
                            ),
                          ),
                          // Overlay Gradient
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.4),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
                          // Category Tag
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                recipe.category,
                                style: const TextStyle(
                                  color: primaryGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          // Favorite Button
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                                icon: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.red : textDark,
                                  size: 20,
                                ),
                                onPressed: () => _toggleFavorite(recipe.id),
                              ),
                            ),
                          ),
                          // Meal Plan Friendly Badge
                          if (recipe.isMealPlanFriendly)
                            Positioned(
                              bottom: 12,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFBAE6FD)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '⭐ ',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Text(
                                      'Meal Plan Friendly',
                                      style: TextStyle(
                                        color: Color(0xFF0369A1),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Info Section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              recipe.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: textMuted,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Micro Stats Row (Calories, Duration, Difficulty, Servings)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildRecipeStat(
                                  icon: Icons.local_fire_department,
                                  value: '${recipe.caloriesKcal} kcal',
                                  color: accentTeal,
                                ),
                                _buildRecipeStat(
                                  icon: Icons.access_time_filled,
                                  value: '${recipe.prepTimeMinutes} min',
                                  color: const Color(0xFFF59E0B),
                                ),
                                _buildRecipeStat(
                                  icon: Icons.speed,
                                  value: recipe.difficulty,
                                  color: const Color(0xFF3B82F6),
                                ),
                                _buildRecipeStat(
                                  icon: Icons.restaurant_menu,
                                  value: recipe.servings,
                                  color: primaryGreen,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipeStat({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 80,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum ada resep yang ditemukan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coba gunakan kata kunci lain.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
