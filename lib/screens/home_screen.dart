import 'package:flutter/material.dart';
import 'log_harian_tab.dart';
import '../repositories/meal_plan_repository.dart';
import '../models/meal_plan_day.dart';
import '../models/meal_plan_meal.dart';
import 'riwayat_tab.dart';
import 'profil_tab.dart';
import '../models/meal_plan.dart';
import '../models/user_profile.dart';
import '../models/dashboard_summary.dart';
import '../models/log_entry.dart';
import '../models/daily_log.dart';
import '../repositories/profile_repository.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/log_repository.dart';
import 'personal_data_setup_screen.dart';
import 'pilih_fokus_nutrisi_screen.dart';
import 'daftar_resep_screen.dart';
import 'detail_resep_screen.dart';
import '../data/recipe_dummy_data.dart';
import '../repositories/auth_repository.dart';
import 'tambah_konsumsi_manual_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const Color primaryGreen = Color(0xFF095D40);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  int _currentTab = 0;
  bool _hasActiveMealPlan = false;
  DateTime _selectedDate = DateTime.now();

  final MealPlanRepository _mealPlanRepository = MealPlanRepository();
  MealPlan? _activeMealPlan;

  bool get _isMealPlanActiveOnSelectedDate {
    if (!_hasActiveMealPlan || _activeMealPlan == null) return false;
    final start = DateTime(
      _activeMealPlan!.activationDate.year,
      _activeMealPlan!.activationDate.month,
      _activeMealPlan!.activationDate.day,
    );
    final end = start.add(Duration(days: _activeMealPlan!.durationDays - 1));
    final sel = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    return !sel.isBefore(start) && !sel.isAfter(end);
  }

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

  // Water tracking state.
  int _waterIntake = 0;

  // Profile data state loaded from backend
  final ProfileRepository _profileRepository = ProfileRepository();
  final DashboardRepository _dashboardRepository = DashboardRepository();
  final LogRepository _logRepository = LogRepository();
  UserProfile? _userProfile;
  DashboardSummary? _dashboardSummary;
  DailyLog? _todayLog;
  bool _isProfileLoading = true;
  String? _profileError;



  // Dynamic getters from DailyLog (for consumption) and UserProfile/DashboardSummary (for targets)
  int get _consumedCalories => _todayLog?.totalCalories.toInt() ?? 0;
  int get _consumedProtein => _todayLog?.totalProtein.toInt() ?? 0;
  int get _consumedCarbs => _todayLog?.totalCarbohydrate.toInt() ?? 0;
  int get _consumedFat => _todayLog?.totalFat.toInt() ?? 0;
  int get _consumedSugar => _todayLog?.totalSugar.toInt() ?? 0;

  String get _profileName => _userProfile?.name ?? 'Pengguna';
  int get _targetCalories => _userProfile?.caloriesKcal ?? 0;
  int get _targetProtein => _userProfile?.proteinG ?? 0;
  int get _targetCarbs => _userProfile?.carbohydrateG ?? 0;
  int get _targetFat => _userProfile?.fatG ?? 0;
  int get _targetSugar => _userProfile?.sugarG ?? 0;

  String _getMealImage(String mealName) {
    final lower = mealName.toLowerCase();
    if (lower.contains('dada ayam') || lower.contains('ayam') || lower.contains('chicken') || lower.contains('indomie')) {
      return 'assets/images/food_lunch.png';
    } else if (lower.contains('pisang') || lower.contains('teh') || lower.contains('chitato') || lower.contains('nutella') || lower.contains('snack') || lower.contains('yogurt')) {
      return 'assets/images/food_snack.png';
    } else if (lower.contains('telur') || lower.contains('roti') || lower.contains('oatmeal') || lower.contains('breakfast')) {
      return 'assets/images/food_breakfast.png';
    }
    return 'assets/images/image_splash_screen.png';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final now = ProfileRepository.useMockDataForTests ? DateTime(2026, 6, 10) : DateTime.now();
    _selectedDate = now;
    _baseMonday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    _calendarPageController = PageController(initialPage: 500);
    _currentCalendarPage = 500;
    _fetchDashboardData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _calendarPageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchDashboardData();
    }
  }

  DateTime get _todayDate {
    final now = DateTime.now();
    if (ProfileRepository.useMockDataForTests) {
      return DateTime(2026, 6, 10);
    }
    return DateTime(now.year, now.month, now.day);
  }

  bool _isToday(DateTime date) {
    final today = _todayDate;
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  bool _isPast(DateTime date) {
    final today = _todayDate;
    final compareDate = DateTime(date.year, date.month, date.day);
    return compareDate.isBefore(today);
  }

  String _formatDateString(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() {
      _profileError = null;
      if (_userProfile == null) {
        _isProfileLoading = true;
      }
    });

    try {
      debugPrint('STEP 1');
      final profileFuture = _profileRepository.getCurrentProfile();
      final summaryFuture = _dashboardRepository.fetchDashboardSummary();
      final activePlanFuture = _mealPlanRepository.getActiveMealPlan();
      final todayLogFuture = _logRepository.fetchDailyLog(_formatDateString(_selectedDate));
      
      final results = await Future.wait([
        profileFuture,
        summaryFuture,
        activePlanFuture,
        todayLogFuture,
      ]);
      debugPrint('STEP 2');

      final userProfile = results[0] as UserProfile;
      debugPrint('STEP 3');
      
      final summary = results[1] as DashboardSummary;
      debugPrint('STEP 4');
      
      final activePlan = results[2] as MealPlan?;
      debugPrint('STEP 5');
      
      final dailyLog = results[3] as DailyLog?;
      debugPrint('STEP 6');

      debugPrint('SUMMARY: ${summary.toJson()}');
      debugPrint('TODAY LOG: ${dailyLog?.toJson()}');
      debugPrint('ACTIVE PLAN: ${activePlan?.toJson()}');

      if (mounted) {
        setState(() {
          _userProfile = userProfile;
          _dashboardSummary = summary;
          _activeMealPlan = activePlan;
          _todayLog = dailyLog;
          
          _waterIntake = ((_todayLog?.totalWaterMl ?? 0.0) / 250.0).round().clamp(0, 8);
          
          if (activePlan != null) {
            _hasActiveMealPlan = true;
            _activePackage = dummyMealPackages.firstWhere(
              (p) => p.name == activePlan.name,
              orElse: () => dummyMealPackages.first,
            );
          } else {
            _hasActiveMealPlan = false;
            _activePackage = null;
          }
          
          _isProfileLoading = false;
        });
        debugPrint('STEP 7');
      }
    } catch (e, stackTrace) {
      debugPrint('DASHBOARD ERROR: $e');
      debugPrint(stackTrace.toString());
      if (mounted) {
        setState(() {
          _profileError = e.toString();
          _isProfileLoading = false;
        });
      }
    }
  }

  Future<void> _updateWaterIntake(int newVal) async {
    final previousWater = _waterIntake;
    setState(() {
      _waterIntake = newVal;
    });

    try {
      final dateStr = _formatDateString(_selectedDate);

      await _logRepository.updateWaterIntake(
        date: dateStr,
        totalWaterMl: newVal * 250.0,
      );
      
      final summary = await _dashboardRepository.fetchDashboardSummary();
      final todayLog = await _logRepository.fetchDailyLog(dateStr);
      
      if (mounted) {
        setState(() {
          _dashboardSummary = summary;
          _todayLog = todayLog;
          _waterIntake = ((_todayLog?.totalWaterMl ?? 0.0) / 250.0).round().clamp(0, 8);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _waterIntake = previousWater;
        });
        _showInfoSnackbar('Gagal memperbarui air minum: $e');
      }
    }
  }

  Future<void> _toggleMealConsumption(
    String mealTime,
    List<MealPlanMeal> meals,
    bool isCurrentlyConsumed,
  ) async {
    if (!_isToday(_selectedDate)) {
      if (_isPast(_selectedDate)) {
        _showInfoSnackbar('Data pada tanggal lampau hanya dapat dilihat dan tidak dapat diubah.');
      } else {
        _showInfoSnackbar('Data pada tanggal masa depan hanya dapat dilihat dan tidak dapat diubah.');
      }
      return;
    }

    if (meals.isEmpty) {
      _showInfoSnackbar('Tidak ada menu rekomendasi untuk dicatat.');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isCurrentlyConsumed ? 'Menghapus Konsumsi...' : 'Mencatat Konsumsi...',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCurrentlyConsumed
                        ? 'Sedang menghapus hidangan dari log harian Anda.'
                        : 'Menambahkan hidangan rekomendasi ke log harian Anda.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final dateStr = _formatDateString(_selectedDate);
      if (isCurrentlyConsumed) {
        final entries = _getEntriesForMeal(mealTime);
        for (var entry in entries) {
          await _logRepository.deleteFoodEntry(date: dateStr, entryId: entry.entryId);
        }
        if (mounted) {
          Navigator.pop(context); // pop loading dialog
          _showInfoSnackbar('Konsumsi berhasil dihapus.');
        }
      } else {
        for (var meal in meals) {
          await _logRepository.addFoodEntry(
            date: dateStr,
            productId: meal.id,
            mealTime: mealTime,
            portion: meal.portion,
          );
        }
        if (mounted) {
          Navigator.pop(context); // pop loading dialog
          _showInfoSnackbar('Konsumsi berhasil dicatat!');
        }
      }
      await _fetchDashboardData();
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // pop loading dialog
        _showInfoSnackbar('Gagal memperbarui konsumsi: $e');
      }
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'HP';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
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
        return LogHarianTab(
          selectedDate: _selectedDate,
          onDateChanged: (date) {
            setState(() {
              _selectedDate = date;
            });
            _fetchDashboardData();
          },
          onRefreshDashboard: _fetchDashboardData,
          dailyLog: _todayLog,
          activeMealPlan: _activeMealPlan,
          isLoading: _isProfileLoading,
        );
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
        if (index == 0) {
          _fetchDashboardData();
        }
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
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        color: primaryGreen,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildDashboardBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, $_profileName',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatIndonesianDate(DateTime.now()),
              style: const TextStyle(
                fontSize: 13,
                color: textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Row(
          children: [
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
            const SizedBox(width: 12),
            _buildAvatarWidget(),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarWidget() {
    final avatarUrl = _userProfile?.avatarUrl;
    final name = _profileName;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: ClipOval(
        child: avatarUrl != null && avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialsAvatar(name);
                },
              )
            : _buildInitialsAvatar(name),
      ),
    );
  }

  Widget _buildInitialsAvatar(String name) {
    return Container(
      width: 44,
      height: 44,
      color: primaryGreen,
      alignment: Alignment.center,
      child: Text(
        _getInitials(name),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDashboardBody() {
    if (_isProfileLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
              ),
              SizedBox(height: 16),
              Text(
                'Memuat data dashboard...',
                style: TextStyle(
                  fontSize: 14,
                  color: textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_profileError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
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
            border: Border.all(color: const Color(0xFFFEE2E2), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFDC2626),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tidak dapat memuat data dashboard.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tarik ke bawah untuk mencoba lagi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 140,
                height: 40,
                child: ElevatedButton(
                  onPressed: _fetchDashboardData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Coba Lagi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _userProfile;
    final hasTargets = profile != null && profile.hasNutritionTarget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2. Nutrition Summary Card / Empty target handling
        if (!hasTargets)
          _buildEmptyTargetCard()
        else
          _buildNutritionSummaryCard(),
        const SizedBox(height: 24),

        // 3. Water Tracking (UI Only) - placed below Nutrition Summary Card
        _buildWaterTrackingCard(),
        const SizedBox(height: 24),

        // 4. Dashboard Insight Card (BMI / Target limits display)
        _buildInsightCard(),
        const SizedBox(height: 24),

        // 5. Quick Access
        const Text(
          'Akses Cepat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessItem(
                icon: Icons.playlist_add_outlined,
                title: 'Tambah Konsumsi',
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TambahKonsumsiManualScreen(
                        initialMealTime: 'Sarapan',
                        selectedDate: _selectedDate,
                      ),
                    ),
                  );
                  if (result == true) {
                    _fetchDashboardData();
                  }
                },
                enabled: _isToday(_selectedDate),
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

        // 6. Meal Plan Berikutnya Section
        const Text(
          'Meal Plan Berikutnya',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 16),
        _buildNextMealCard(),
        const SizedBox(height: 28),

        // 7. Log Harian Section
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
        _buildDailyLogs(),
        const SizedBox(height: 24),

        // 8. Tip Nutrisi Card
        _buildNutritionTip(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEmptyTargetCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          const Icon(
            Icons.playlist_add_check_circle_outlined,
            color: Color(0xFF14B8A6),
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Target belum tersedia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Lengkapi profil untuk mendapatkan rekomendasi target harian',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PersonalDataSetupScreen(),
                  ),
                ).then((_) => _fetchDashboardData());
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
                'Lengkapi Profil',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    final profile = _userProfile;
    if (profile == null || !profile.hasNutritionTarget) return const SizedBox.shrink();

    final bmiValue = profile.bmi;
    final bmiStatus = profile.bmiStatus;

    Color bmiBadgeColor;
    Color bmiTextColor;
    switch (bmiStatus) {
      case 'Kurus':
        bmiBadgeColor = const Color(0xFFE0F2FE);
        bmiTextColor = const Color(0xFF0369A1);
        break;
      case 'Normal':
        bmiBadgeColor = const Color(0xFFDCFCE7);
        bmiTextColor = const Color(0xFF15803D);
        break;
      case 'Overweight':
        bmiBadgeColor = const Color(0xFFFEF3C7);
        bmiTextColor = const Color(0xFFB45309);
        break;
      case 'Obesitas':
        bmiBadgeColor = const Color(0xFFFEE2E2);
        bmiTextColor = const Color(0xFFB91C1C);
        break;
      default:
        bmiBadgeColor = const Color(0xFFF1F5F9);
        bmiTextColor = const Color(0xFF475569);
    }

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Insight Kesehatan dan Target',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'BMI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      bmiValue > 0 ? bmiValue.toStringAsFixed(1) : '-',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: bmiBadgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bmiStatus,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: bmiTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                width: 1,
                color: const Color(0xFFE2E8F0),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Target Kalori',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${profile.caloriesKcal} kcal',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Harian',
                      style: TextStyle(
                        fontSize: 11,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                width: 1,
                color: const Color(0xFFE2E8F0),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Target Protein',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${profile.proteinG} gram',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Harian',
                      style: TextStyle(
                        fontSize: 11,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummaryCard() {
    return Container(
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
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: _targetCalories > 0 ? (_consumedCalories / _targetCalories).clamp(0.0, 1.0) : 0.0,
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
                        _targetCalories > 0 ? '${((_consumedCalories / _targetCalories) * 100).toInt()}%' : '0%',
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
                      _targetProtein > 0 ? (_consumedProtein / _targetProtein).clamp(0.0, 1.0) : 0.0,
                      primaryGreen,
                    ),
                    const SizedBox(height: 16),
                    _buildMacroBar(
                      'Lemak',
                      '$_consumedFat/${_targetFat}g',
                      _targetFat > 0 ? (_consumedFat / _targetFat).clamp(0.0, 1.0) : 0.0,
                      const Color(0xFF0284C7),
                    ),
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
                      _targetCarbs > 0 ? (_consumedCarbs / _targetCarbs).clamp(0.0, 1.0) : 0.0,
                      const Color(0xFFF97316),
                    ),
                    const SizedBox(height: 16),
                    _buildMacroBar(
                      'Gula',
                      '$_consumedSugar/${_targetSugar}g',
                      _targetSugar > 0 ? (_consumedSugar / _targetSugar).clamp(0.0, 1.0) : 0.0,
                      const Color(0xFFDC2626),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildOverConsumptionWarnings(),
        ],
      ),
    );
  }

  Widget _buildNextMealCard() {
    final MealPlan? activePlan = _activeMealPlan;
    if (activePlan == null && !ProfileRepository.useMockDataForTests) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
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
            const Icon(
              Icons.restaurant_menu_outlined,
              color: accentTeal,
              size: 40,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada Meal Plan aktif',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih paket meal plan untuk mendapatkan rekomendasi menu harian yang sesuai dengan target nutrisi Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 160,
              height: 38,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentTab = 1;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19),
                  ),
                ),
                child: const Text(
                  'Buat Meal Plan',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final MealPackage pkg = _activePackage ?? dummyMealPackages.first;
    String nextMealName = '';
    int nextMealCal = 0;

    if (ProfileRepository.useMockDataForTests) {
      nextMealName = 'Ayam Panggang + Nasi Merah';
      nextMealCal = 650;
    } else {
      final hour = DateTime.now().hour;
      final todayNum = DateTime.now().weekday;
      final todayData = activePlan?.days.firstWhere(
        (d) => d.dayNumber == todayNum,
        orElse: () => MealPlanDay(
          dayNumber: todayNum,
          breakfast: [],
          lunch: [],
          dinner: [],
          snack: [],
          totalCalories: 0,
        ),
      );

      if (hour < 9) {
        nextMealName = todayData != null && todayData.breakfast.isNotEmpty
            ? todayData.breakfast.map((m) => m.name).join(' + ')
            : pkg.breakfastMenu;
        nextMealCal = todayData != null && todayData.breakfast.isNotEmpty
            ? todayData.breakfast.fold(0, (s, m) => s + m.calories)
            : pkg.breakfastCal;
      } else if (hour < 14) {
        nextMealName = todayData != null && todayData.lunch.isNotEmpty
            ? todayData.lunch.map((m) => m.name).join(' + ')
            : pkg.lunchMenu;
        nextMealCal = todayData != null && todayData.lunch.isNotEmpty
            ? todayData.lunch.fold(0, (s, m) => s + m.calories)
            : pkg.lunchCal;
      } else if (hour < 20) {
        nextMealName = todayData != null && todayData.dinner.isNotEmpty
            ? todayData.dinner.map((m) => m.name).join(' + ')
            : pkg.dinnerMenu;
        nextMealCal = todayData != null && todayData.dinner.isNotEmpty
            ? todayData.dinner.fold(0, (s, m) => s + m.calories)
            : pkg.dinnerCal;
      } else {
        nextMealName = todayData != null && todayData.snack.isNotEmpty
            ? todayData.snack.map((m) => m.name).join(' + ')
            : pkg.snackMenu;
        nextMealCal = todayData != null && todayData.snack.isNotEmpty
            ? todayData.snack.fold(0, (s, m) => s + m.calories)
            : pkg.snackCal;
      }
    }

    String? backendImageUrl;
    if (!ProfileRepository.useMockDataForTests && activePlan != null) {
      final hour = DateTime.now().hour;
      final todayNum = DateTime.now().weekday;
      final todayData = activePlan.days.firstWhere(
        (d) => d.dayNumber == todayNum,
        orElse: () => MealPlanDay(
          dayNumber: todayNum,
          breakfast: [],
          lunch: [],
          dinner: [],
          snack: [],
          totalCalories: 0,
        ),
      );
      List<MealPlanMeal>? meals;
      if (hour < 9) {
        meals = todayData.breakfast;
      } else if (hour < 14) {
        meals = todayData.lunch;
      } else if (hour < 20) {
        meals = todayData.dinner;
      } else {
        meals = todayData.snack;
      }
      if (meals.isNotEmpty && meals.first.imageUrl != null && meals.first.imageUrl!.isNotEmpty) {
        backendImageUrl = meals.first.imageUrl;
      }
    }

    return Container(
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            child: Container(
              height: 160,
              width: double.infinity,
              color: const Color(0xFFF0FDFB),
              child: backendImageUrl != null && backendImageUrl.isNotEmpty
                  ? Image.network(
                      backendImageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Image.asset(
                            _getMealImage(nextMealName),
                            height: 130,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Image.asset(
                        _getMealImage(nextMealName),
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
                Text(
                  nextMealName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: accentTeal,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$nextMealCal kcal',
                      style: const TextStyle(
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
                      final recipe = getRecipeForMeal(nextMealName);
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
    );
  }

  List<LogEntry> _getEntriesForMeal(String backendMealTime) {
    if (_todayLog == null) return [];
    return _todayLog!.logEntries.where(
      (entry) => entry.mealTime.toLowerCase() == backendMealTime.toLowerCase(),
    ).toList();
  }

  int _getMealCalories(List<LogEntry> entries) {
    double sum = 0;
    for (var entry in entries) {
      sum += (entry.foodProduct.caloriesKcal * (entry.portion / 100.0));
    }
    return sum.toInt();
  }

  Widget _buildLogItem(String title, String backendMealTime) {
    final entries = _getEntriesForMeal(backendMealTime);
    final bool isChecked = entries.isNotEmpty;
    final int count = entries.length;
    final int cal = _getMealCalories(entries);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isChecked ? const Color(0xFFECFDF5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isChecked ? const Color(0xFFA7F3D0) : const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isChecked ? const Color(0xFF10B981) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isChecked ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
            ),
            child: isChecked
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isChecked ? const Color(0xFF065F46) : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isChecked ? '$count makanan dicatat' : 'Belum ada makanan dicatat',
                  style: TextStyle(
                    fontSize: 12,
                    color: isChecked ? const Color(0xFF047857) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$cal kcal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isChecked ? const Color(0xFF065F46) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyLogs() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLogItem('Sarapan', 'Breakfast'),
          const SizedBox(height: 12),
          _buildLogItem('Makan Siang', 'Lunch'),
          const SizedBox(height: 12),
          _buildLogItem('Makan Malam', 'Dinner'),
        ],
      ),
    );
  }

  Widget _buildNutritionTip() {
    final profile = _userProfile;
    if (profile == null || !profile.hasNutritionTarget) {
      return const SizedBox.shrink();
    }

    final displayProtein = _targetProtein - _consumedProtein > 0 ? _targetProtein - _consumedProtein : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFB),
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
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: textDark,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'Konsumsi protein '),
                TextSpan(
                  text: '$displayProtein gram lagi',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: ' untuk mencapai target harian kamu hari ini.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              Icons.trending_up,
              color: Color(0x33095D40),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverConsumptionWarnings() {
    final profile = _userProfile;
    if (profile == null || !profile.hasNutritionTarget) {
      return const SizedBox.shrink();
    }

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

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: warnings.map((w) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: w,
        )).toList(),
      ),
    );
  }

  Widget _buildWarningCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFEE2E2), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFDC2626),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF991B1B),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildWaterTrackingCard() {
    // TODO: Target air minum diambil dari backend (target.water_ml pada /dashboard/summary) jika tersedia, jika tidak menggunakan default 2000 ml.
    final double targetWater = (_dashboardSummary?.targetWaterMl != null && _dashboardSummary!.targetWaterMl > 0)
        ? _dashboardSummary!.targetWaterMl
        : 2000.0;
    final int totalGlasses = (targetWater / 250.0).round();
    final bool targetReached = _waterIntake >= totalGlasses;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Air Minum Hari Ini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Target hidrasi harian',
                      style: TextStyle(
                        fontSize: 12,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Target: ${targetWater.toInt()} ml',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$totalGlasses Gelas per Hari',
                    style: const TextStyle(
                      fontSize: 11,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final double circleSize = (constraints.maxWidth - ((totalGlasses - 1) * 8)) / totalGlasses;
              final double size = circleSize.clamp(20.0, 28.0);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(totalGlasses, (index) {
                  final bool isActive = index < _waterIntake;
                  return GestureDetector(
                    onTap: !_isToday(_selectedDate)
                        ? null
                        : () {
                            if (index == _waterIntake) {
                              _updateWaterIntake((_waterIntake + 1).clamp(0, totalGlasses));
                            } else if (index == _waterIntake - 1) {
                              _updateWaterIntake((_waterIntake - 1).clamp(0, totalGlasses));
                            }
                          },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: isActive ? accentTeal : const Color(0xFFE2E8F0),
                          shape: BoxShape.circle,
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: accentTeal.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_waterIntake / $totalGlasses Gelas',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              if (targetReached)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFBBF7D0),
                    ),
                  ),
                  child: const Text(
                    '🎉 Target Tercapai',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
            ],
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
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
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
      ),
    );
  }

  // Removed unused _buildUncheckedLogItem method

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
                              final isToday = _isToday(date);
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
                                  _fetchDashboardData();
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
                  child: _isMealPlanActiveOnSelectedDate
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
          'Belum ada Meal Plan aktif',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pilih paket meal plan untuk mendapatkan rekomendasi menu harian yang sesuai dengan target nutrisi Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: textMuted, height: 1.5),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isPast(_selectedDate)
                ? null
                : () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PilihFokusNutrisiScreen(),
                      ),
                    );
                    if (result != null && result is MealPackage) {
                      await _fetchDashboardData();
                      _showInfoSnackbar('Meal Plan berhasil digunakan.');
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

  Widget _buildActiveMealPlanState() {
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);

    final activePackage = _activePackage ?? dummyMealPackages.first;
    final focusObj = dummyMealFocuses.firstWhere(
      (f) => f.id == activePackage.focusId,
      orElse: () => dummyMealFocuses.first,
    );
    final categoryName = focusObj.title;

    final dayNum = _selectedDate.weekday;
    final dayData = _activeMealPlan?.days.firstWhere(
      (d) => d.dayNumber == dayNum,
      orElse: () => MealPlanDay(
        dayNumber: dayNum,
        breakfast: [],
        lunch: [],
        dinner: [],
        snack: [],
        totalCalories: 0,
      ),
    );

    final String bfTitle = dayData != null && dayData.breakfast.isNotEmpty 
        ? dayData.breakfast.map((m) => m.name).join(' + ')
        : activePackage.breakfastMenu;
    final int bfCal = dayData != null && dayData.breakfast.isNotEmpty
        ? dayData.breakfast.fold(0, (s, m) => s + m.calories)
        : activePackage.breakfastCal;

    final String lnTitle = dayData != null && dayData.lunch.isNotEmpty 
        ? dayData.lunch.map((m) => m.name).join(' + ')
        : activePackage.lunchMenu;
    final int lnCal = dayData != null && dayData.lunch.isNotEmpty
        ? dayData.lunch.fold(0, (s, m) => s + m.calories)
        : activePackage.lunchCal;

    final String dnTitle = dayData != null && dayData.dinner.isNotEmpty 
        ? dayData.dinner.map((m) => m.name).join(' + ')
        : activePackage.dinnerMenu;
    final int dnCal = dayData != null && dayData.dinner.isNotEmpty
        ? dayData.dinner.fold(0, (s, m) => s + m.calories)
        : activePackage.dinnerCal;

    final String snTitle = dayData != null && dayData.snack.isNotEmpty 
        ? dayData.snack.map((m) => m.name).join(' + ')
        : activePackage.snackMenu;
    final int snCal = dayData != null && dayData.snack.isNotEmpty
        ? dayData.snack.fold(0, (s, m) => s + m.calories)
        : activePackage.snackCal;

    final List<MealPlanMeal> bfMeals = dayData?.breakfast ?? [];
    final List<MealPlanMeal> lnMeals = dayData?.lunch ?? [];
    final List<MealPlanMeal> dnMeals = dayData?.dinner ?? [];
    final List<MealPlanMeal> snMeals = dayData?.snack ?? [];

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
                  if (!_isPast(_selectedDate))
                    GestureDetector(
                      onTap: () async {
                        // 1. Show confirmation dialog
                        final confirm = await showGeneralDialog<bool>(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: 'Hentikan',
                          transitionDuration: const Duration(milliseconds: 250),
                          pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
                          transitionBuilder: (context, anim1, anim2, child) {
                            final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
                            return ScaleTransition(
                              scale: curve,
                              child: AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                title: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Hentikan Meal Plan ini?',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                      ),
                                    ),
                                  ],
                                ),
                                content: const Text(
                                  'Apakah Anda yakin ingin menghentikan Meal Plan aktif saat ini?',
                                  style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text(
                                      'Batal',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('Hentikan'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );

                        if (confirm != true) return;

                        // 2. Show loading dialog
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const PopScope(
                            canPop: false,
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                              content: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryGreen)),
                                    SizedBox(height: 20),
                                    Text(
                                      'Mengganti Meal Plan...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Sedang menyiapkan menu harian baru Anda.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );

                        try {
                          await _mealPlanRepository.deactivateActiveMealPlans();
                          if (mounted) {
                            Navigator.pop(context); // Dismiss loading dialog
                            setState(() {
                              _hasActiveMealPlan = false;
                              _activePackage = null;
                              _selectedFocus = null;
                              _activeMealPlan = null;
                            });
                            _showInfoSnackbar('Meal Plan berhasil dihentikan.');
                          }
                        } catch (e) {
                          debugPrint('Error deactivating meal plan: $e');
                          if (mounted) {
                            Navigator.pop(context); // Dismiss loading dialog
                            _showInfoSnackbar('Gagal mengganti Meal Plan. Silakan coba lagi.');
                          }
                        }
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
          title: bfTitle,
          calories: '$bfCal kcal',
          assetPath: 'assets/images/food_breakfast.png',
          mealTime: 'Breakfast',
          meals: bfMeals,
          recipeDetail:
              'Rincian menu sarapan lezat kaya nutrisi untuk mendukung target kesehatan harian Anda.',
        ),
        const SizedBox(height: 16),
        _buildActiveMealCard(
          category: 'MAKAN SIANG',
          title: lnTitle,
          calories: '$lnCal kcal',
          assetPath: 'assets/images/food_lunch.png',
          mealTime: 'Lunch',
          meals: lnMeals,
          recipeDetail:
              'Menu makan siang terkalibrasi untuk mencukupi kebutuhan gizi makro di siang hari.',
        ),
        const SizedBox(height: 16),
        _buildActiveMealCard(
          category: 'MAKAN MALAM',
          title: dnTitle,
          calories: '$dnCal kcal',
          assetPath: 'assets/images/food_dinner.png',
          mealTime: 'Dinner',
          meals: dnMeals,
          recipeDetail:
              'Makan malam yang ringan dan sehat untuk menjaga metabolisme tubuh tetap ideal.',
        ),
        const SizedBox(height: 16),
        _buildActiveMealCard(
          category: 'SNACK',
          title: snTitle,
          calories: '$snCal kcal',
          assetPath: 'assets/images/food_snack.png',
          mealTime: 'Snack',
          meals: snMeals,
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
    required String mealTime,
    required List<MealPlanMeal> meals,
    required String recipeDetail,
  }) {
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);
    final bool isConsumed = _getEntriesForMeal(mealTime).isNotEmpty;

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
                        onTap: !_isToday(_selectedDate)
                            ? () {
                                if (_isPast(_selectedDate)) {
                                  _showInfoSnackbar('Data pada tanggal lampau hanya dapat dilihat dan tidak dapat diubah.');
                                } else {
                                  _showInfoSnackbar('Data pada tanggal masa depan hanya dapat dilihat dan tidak dapat diubah.');
                                }
                              }
                            : () => _toggleMealConsumption(mealTime, meals, isConsumed),
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
