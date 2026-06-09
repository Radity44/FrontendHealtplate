import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'log_harian_tab.dart';
import 'riwayat_tab.dart';
import 'profil_tab.dart';
import '../models/meal_plan.dart';
import 'pilih_fokus_nutrisi_screen.dart';
import 'daftar_resep_screen.dart';
import 'detail_resep_screen.dart';
import '../data/recipe_dummy_data.dart';
import '../repositories/auth_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  bool _hasActiveMealPlan = false;
  DateTime _selectedDate = DateTime.now();
  final Set<String> _consumedMeals = {'sarapan'};

  // Meal Plan Flow state
  // FUTURE INTEGRATION ARCHITECTURE NOTE:
  // Currently, the active state is based on `MealPackage? _activePackage` for simple simulation.
  // In the future, this structure will expand to support date-based meal planning:
  // e.g. `Map<DateTime, MealPackage> _dateMealPlans` where the app maps a specific Date to a Meal Package.
  MealPackage? _activePackage;
  // ignore: unused_field
  String? _selectedFocus;

  late final PageController _calendarPageController;
  late final DateTime _baseMonday;
  int _currentCalendarPage = 500;

  // Profile data and target values loaded from SharedPreferences
  String _profileName = 'Ridho';
  int _targetCalories = 2000;
  int _targetProtein = 90;
  int _targetCarbs = 250;
  int _targetFat = 70;
  int _targetSugar = 30;

  // Simulated daily consumption values for target progress and warning cards
  final int _consumedCalories = 2200;
  final int _consumedProtein = 75;
  final int _consumedCarbs = 180;
  final int _consumedFat = 55;
  final int _consumedSugar = 40;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _baseMonday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    _calendarPageController = PageController(initialPage: 500);
    _currentCalendarPage = 500;
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileName = prefs.getString('profile_name') ?? 'Ridho';
      _targetCalories = prefs.getInt('profile_calories') ?? 2000;
      _targetProtein = prefs.getInt('profile_protein') ?? 90;
      _targetCarbs = prefs.getInt('profile_carbohydrate') ?? 250;
      _targetFat = prefs.getInt('profile_fat') ?? 70;
      _targetSugar = prefs.getInt('profile_sugar') ?? 30;
    });
  }

  @override
  void dispose() {
    _calendarPageController.dispose();
    super.dispose();
  }

  // Sign out method
  Future<void> _logout() async {
    final authRepository = AuthRepository();
    await authRepository.logout();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
    }
  }

  // Handle Tab Switch
  Widget _getBody() {
    switch (_currentTab) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildMealPlanTab();
      case 2:
        return const LogHarianTab();
      case 3:
        return const RiwayatTab();
      case 4:
        return ProfilTab(onLogout: _logout);
      default:
        return _buildDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Very soft background
      body: _getBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home, 'Home'),
                _buildNavItem(1, Icons.restaurant, 'Meal Plan'),
                _buildNavItem(
                  2,
                  Icons.playlist_add_check_outlined,
                  'Log Harian',
                ),
                _buildNavItem(3, Icons.history, 'Riwayat'),
                _buildNavItem(4, Icons.person_outline, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _currentTab == index;
    const Color primaryGreen = Color(0xFF095D40);
    const Color textMuted = Color(0xFF94A3B8);

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTab = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? primaryGreen : textMuted, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? primaryGreen : textMuted,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 4),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Dashboard Tab Content
  Widget _buildDashboard() {
    const Color primaryGreen = Color(0xFF095D40);
    const Color accentTeal = Color(0xFF14B8A6);
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Halo, $_profileName',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('👋', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Senin, 1 Juni 2026', // Corrected from Senis to Senin
                        style: TextStyle(
                          fontSize: 13,
                          color: textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_none_outlined,
                        color: textDark,
                      ),
                      onPressed: () {
                        _showInfoSnackbar('Belum ada pemberitahuan baru');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Calorie progress card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Circular Calorie Indicator (75% filled)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: (_consumedCalories / _targetCalories).clamp(0.0, 1.0),
                                strokeWidth: 10,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  primaryGreen,
                                ),
                                backgroundColor: const Color(0xFFF1F5F9),
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${((_consumedCalories / _targetCalories) * 100).toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                                Text(
                                  '$_consumedCalories kcal',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        // Target Text Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Target Harian',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_targetCalories kcal',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => _showInfoSnackbar(
                                  'Membuka detail target harian',
                                ),
                                child: const Row(
                                  children: [
                                    Text(
                                      'Lihat Detail',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: accentTeal,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: accentTeal,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildMacroBar(
                                'Protein',
                                '$_consumedProtein/${_targetProtein}g',
                                (_consumedProtein / _targetProtein).clamp(0.0, 1.0),
                                primaryGreen,
                              ),
                              const SizedBox(height: 16),
                              _buildMacroBar(
                                'Lemak',
                                '$_consumedFat/${_targetFat}g',
                                (_consumedFat / _targetFat).clamp(0.0, 1.0),
                                const Color(0xFF0284C7),
                              ), // Blue
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: [
                              _buildMacroBar(
                                'Karbohidrat',
                                '$_consumedCarbs/${_targetCarbs}g',
                                (_consumedCarbs / _targetCarbs).clamp(0.0, 1.0),
                                const Color(0xFFF97316),
                              ), // Orange
                              const SizedBox(height: 16),
                              _buildMacroBar(
                                'Gula',
                                '$_consumedSugar/${_targetSugar}g',
                                (_consumedSugar / _targetSugar).clamp(0.0, 1.0),
                                const Color(0xFFDC2626),
                              ), // Red
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Over-Consumption Warning Cards
              _buildOverConsumptionWarnings(),

              // Akses Cepat Section
              const Text(
                'Akses Cepat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 16),
              // Akses Cepat Grid
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAccessItem(
                      icon: Icons.playlist_add_outlined,
                      title: 'Tambah Konsumsi',
                      onTap: () => _showInfoSnackbar('Fitur Tambah Konsumsi'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickAccessItem(
                      icon: Icons.restaurant,
                      title: 'Meal Plan',
                      onTap: () => setState(() => _currentTab = 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAccessItem(
                      icon: Icons.menu_book,
                      title: 'Resep',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DaftarResepScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickAccessItem(
                      icon: Icons.history,
                      title: 'Riwayat',
                      onTap: () => setState(() => _currentTab = 3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Meal Plan Berikutnya Section
              const Text(
                'Meal Plan Berikutnya',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 16),
              // Meal Plan Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food Image (Splash screen image placeholder)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        color: const Color(0xFFF0FDFB),
                        child: Center(
                          child: Image.asset(
                            'assets/images/image_splash_screen.png',
                            height: 130,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nasi Merah Ayam Panggang Sayuran Hijau',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: accentTeal,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '420 kcal',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                final recipe = getRecipeForMeal('Nasi Merah Ayam Panggang Sayuran Hijau');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailResepScreen(recipe: recipe),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text(
                                'Lihat Resep',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Log Harian Section
              const Text(
                'LOG HARIAN',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              // Daily Logs Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Checked Item: Sarapan
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_box, color: primaryGreen, size: 22),
                          SizedBox(width: 12),
                          Text(
                            'Sarapan: Oatmeal Pisang',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Unchecked: Makan Siang
                    _buildUncheckedLogItem('Makan Siang'),
                    const SizedBox(height: 12),
                    // Unchecked: Makan Malam
                    _buildUncheckedLogItem('Makan Malam'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tip Nutrisi Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFB), // Very light teal background
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFCCFBF1), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: primaryGreen,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tip Nutrisi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: textDark,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(text: 'Konsumsi protein '),
                          TextSpan(
                            text: '30 gram lagi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                ' untuk mencapai target harian kamu hari ini.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        Icons.trending_up,
                        color: Color(0x33095D40), // Transparent primary green
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Warning Cards for Over-Consumption
  Widget _buildOverConsumptionWarnings() {
    final List<Widget> warnings = [];

    if (_consumedCalories > _targetCalories) {
      warnings.add(
        _buildWarningCard(
          'Target kalori harian telah terlampaui sebesar ${_consumedCalories - _targetCalories} kcal.',
        ),
      );
    }
    if (_consumedSugar > _targetSugar) {
      warnings.add(
        _buildWarningCard(
          'Konsumsi gula hari ini telah melebihi batas harian sebesar ${_consumedSugar - _targetSugar} g.',
        ),
      );
    }
    if (_consumedFat > _targetFat) {
      warnings.add(
        _buildWarningCard(
          'Konsumsi lemak hari ini telah melebihi batas harian sebesar ${_consumedFat - _targetFat} g.',
        ),
      );
    }
    if (_consumedProtein > _targetProtein) {
      warnings.add(
        _buildWarningCard(
          'Konsumsi protein hari ini telah melebihi batas harian sebesar ${_consumedProtein - _targetProtein} g.',
        ),
      );
    }
    if (_consumedCarbs > _targetCarbs) {
      warnings.add(
        _buildWarningCard(
          'Konsumsi karbohidrat hari ini telah melebihi batas harian sebesar ${_consumedCarbs - _targetCarbs} g.',
        ),
      );
    }

    if (warnings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: warnings.map((w) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: w,
      )).toList(),
    );
  }

  Widget _buildWarningCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // Light red warning background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEE2E2), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFDC2626), // Premium red warning color
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF991B1B), // Dark red text
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBar(
    String label,
    String value,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: const Color(0xFFF1F5F9),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDFB), // Very light mint/teal
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF095D40), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUncheckedLogItem(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // Profile tab is now integrated as ProfilTab widget.

  void _showInfoSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF095D40),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Indonesian Date Helpers
  String _getIndonesianDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
        return 'Minggu';
      default:
        return '';
    }
  }

  String _getIndonesianMonthName(int month) {
    switch (month) {
      case 1:
        return 'Januari';
      case 2:
        return 'Februari';
      case 3:
        return 'Maret';
      case 4:
        return 'April';
      case 5:
        return 'Mei';
      case 6:
        return 'Juni';
      case 7:
        return 'Juli';
      case 8:
        return 'Agustus';
      case 9:
        return 'September';
      case 10:
        return 'Oktober';
      case 11:
        return 'November';
      case 12:
        return 'Desember';
      default:
        return '';
    }
  }

  String _formatIndonesianDate(DateTime date) {
    final dayName = _getIndonesianDayName(date.weekday);
    final monthName = _getIndonesianMonthName(date.month);
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  String _getCalendarHeader(int page) {
    final mondayOfWeek = _baseMonday.add(Duration(days: (page - 500) * 7));
    final middleOfWeek = mondayOfWeek.add(const Duration(days: 3));
    final monthName = _getIndonesianMonthName(middleOfWeek.month);
    return '$monthName, ${middleOfWeek.year}';
  }

  Widget _buildDayNameHeader(String label) {
    return SizedBox(
      width: 36,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8), // slate-300
          ),
        ),
      ),
    );
  }

  // Main Meal Plan Tab Builder
  Widget _buildMealPlanTab() {
    const Color primaryGreen = Color(0xFF095D40);
    const Color textDark = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 16.0,
                bottom: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Meal Plan',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_none_outlined,
                        color: textDark,
                      ),
                      onPressed: () {
                        _showInfoSnackbar('Belum ada pemberitahuan baru');
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Weekly Calendar Card (Snaps week-by-week)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    // Top Row: Month and Year (e.g., "Juni, 2026")
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _getCalendarHeader(_currentCalendarPage),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Day Names Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDayNameHeader('SEN'),
                        _buildDayNameHeader('SEL'),
                        _buildDayNameHeader('RAB'),
                        _buildDayNameHeader('KAM'),
                        _buildDayNameHeader('JUM'),
                        _buildDayNameHeader('SAB'),
                        _buildDayNameHeader('MIN'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // PageView for Snapping Week-by-Week
                    SizedBox(
                      height: 40,
                      child: PageView.builder(
                        controller: _calendarPageController,
                        onPageChanged: (page) {
                          setState(() {
                            _currentCalendarPage = page;
                          });
                        },
                        itemBuilder: (context, pageIndex) {
                          final mondayOfWeek = _baseMonday.add(
                            Duration(days: (pageIndex - 500) * 7),
                          );
                          final List<DateTime> weekDates = List.generate(7, (
                            index,
                          ) {
                            return mondayOfWeek.add(Duration(days: index));
                          });

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: weekDates.map((date) {
                              final now = DateTime.now();
                              final isToday =
                                  date.day == now.day &&
                                  date.month == now.month &&
                                  date.year == now.year;
                              final isSelected =
                                  date.day == _selectedDate.day &&
                                  date.month == _selectedDate.month &&
                                  date.year == _selectedDate.year;
                              final isSunday = date.weekday == DateTime.sunday;

                              BoxDecoration boxDecoration;
                              Color textColor;

                              if (isSelected) {
                                boxDecoration = const BoxDecoration(
                                  color: Color(
                                    0xFF0284C7,
                                  ), // Solid blue background
                                  shape: BoxShape.circle,
                                );
                                textColor = Colors.white;
                              } else if (isToday) {
                                boxDecoration = BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(
                                      0xFF0284C7,
                                    ), // Blue outline border
                                    width: 1.5,
                                  ),
                                );
                                textColor = const Color(
                                  0xFF0284C7,
                                ); // Blue text for today
                              } else {
                                boxDecoration = const BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                );
                                textColor = isSunday
                                    ? const Color(
                                        0xFFDC2626,
                                      ) // Red text for Sunday
                                    : const Color(
                                        0xFF1E293B,
                                      ); // Dark slate for others
                              }

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = date;
                                  });
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: boxDecoration,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Date Title under calendar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Text(
                _formatIndonesianDate(_selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ),

            // Active/Empty state list
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _hasActiveMealPlan
                      ? _buildActiveMealPlanState()
                      : _buildEmptyMealPlanState(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build empty state
  Widget _buildEmptyMealPlanState() {
    const Color primaryGreen = Color(0xFF095D40);
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 220,
            width: double.infinity,
            color: Colors.white,
            child: Image.asset(
              'assets/images/gambar_null_mealplan.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Belum Ada Meal Plan Aktif',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pilih paket meal plan yang sesuai dengan kebutuhan nutrisi Anda untuk mulai mendapatkan rekomendasi menu harian.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: textMuted, height: 1.5),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PilihFokusNutrisiScreen(),
                ),
              );
              if (result != null && result is MealPackage) {
                setState(() {
                  _activePackage = result;
                  _selectedFocus = result.focusId;
                  _hasActiveMealPlan = true;
                  _consumedMeals.clear(); // Clear consumed status for new package
                });
                _showInfoSnackbar('Meal Plan "${result.name}" diaktifkan!');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text(
              'Buat Meal Plan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mengapa Menggunakan Meal Plan?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 16),
              _buildBenefitRow('Menu harian lebih terstruktur'),
              const SizedBox(height: 12),
              _buildBenefitRow('Membantu mencapai target nutrisi'),
              const SizedBox(height: 12),
              _buildBenefitRow('Terintegrasi dengan Log Harian'),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildBenefitRow(String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Color(0xFFE6F4F1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 14, color: Color(0xFF095D40)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  // Build active state
  Widget _buildActiveMealPlanState() {
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);

    final activePackage = _activePackage ?? dummyMealPackages.first;
    final focusObj = dummyMealFocuses.firstWhere(
      (f) => f.id == activePackage.focusId,
      orElse: () => dummyMealFocuses.first,
    );
    final categoryName = focusObj.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'AKTIF',
                      style: TextStyle(
                        color: Color(0xFF0284C7),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _hasActiveMealPlan = false;
                        _activePackage = null;
                        _selectedFocus = null;
                      });
                      _showInfoSnackbar('Meal Plan dinonaktifkan.');
                    },
                    child: const Text(
                      'Ganti Paket',
                      style: TextStyle(
                        color: Color(0xFF14B8A6),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                activePackage.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TARGET KALORI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${activePackage.caloriesKcal} kcal',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KATEGORI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          categoryName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Jadwal Hari Ini',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 16),

        _buildActiveMealCard(
          category: 'SARAPAN',
          title: activePackage.breakfastMenu,
          calories: '${activePackage.breakfastCal} kcal',
          assetPath: 'assets/images/food_breakfast.png',
          mealKey: 'sarapan',
          recipeDetail:
              'Rincian menu sarapan lezat kaya nutrisi untuk mendukung target kesehatan harian Anda.',
        ),
        const SizedBox(height: 16),
        _buildActiveMealCard(
          category: 'MAKAN SIANG',
          title: activePackage.lunchMenu,
          calories: '${activePackage.lunchCal} kcal',
          assetPath: 'assets/images/food_lunch.png',
          mealKey: 'makansiang',
          recipeDetail:
              'Menu makan siang terkalibrasi untuk mencukupi kebutuhan gizi makro di siang hari.',
        ),
        const SizedBox(height: 16),
        _buildActiveMealCard(
          category: 'MAKAN MALAM',
          title: activePackage.dinnerMenu,
          calories: '${activePackage.dinnerCal} kcal',
          assetPath: 'assets/images/food_dinner.png',
          mealKey: 'makanmalam',
          recipeDetail:
              'Makan malam yang ringan dan sehat untuk menjaga metabolisme tubuh tetap ideal.',
        ),
        const SizedBox(height: 16),
        _buildActiveMealCard(
          category: 'SNACK',
          title: activePackage.snackMenu,
          calories: '${activePackage.snackCal} kcal',
          assetPath: 'assets/images/food_snack.png',
          mealKey: 'snack',
          recipeDetail:
              'Camilan sehat terkalibrasi untuk memuaskan rasa lapar di antara waktu makan utama.',
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildActiveMealCard({
    required String category,
    required String title,
    required String calories,
    required String assetPath,
    required String mealKey,
    required String recipeDetail,
  }) {
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);
    final bool isConsumed = _consumedMeals.contains(mealKey);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isConsumed ? const Color(0xFFECFDF5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConsumed ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isConsumed
                          ? const Color(0xFF059669)
                          : const Color(0xFF14B8A6),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    calories,
                    style: const TextStyle(
                      fontSize: 12,
                      color: textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isConsumed) {
                              _consumedMeals.remove(mealKey);
                            } else {
                              _consumedMeals.add(mealKey);
                            }
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isConsumed
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 20,
                              color: isConsumed
                                  ? const Color(0xFF10B981)
                                  : textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isConsumed
                                  ? 'Sudah Dikonsumsi'
                                  : 'Belum Dikonsumsi',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isConsumed
                                    ? const Color(0xFF10B981)
                                    : textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          final recipe = getRecipeForMeal(title);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailResepScreen(recipe: recipe),
                            ),
                          );
                        },
                        child: const Text(
                          'Lihat Resep',
                          style: TextStyle(
                            color: Color(0xFF14B8A6),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 72,
                height: 72,
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(Icons.restaurant, color: textMuted),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
