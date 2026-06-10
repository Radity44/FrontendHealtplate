import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'detail_riwayat_screen.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/profile_repository.dart';
import '../models/user_profile.dart';

class RiwayatTab extends StatefulWidget {
  const RiwayatTab({super.key});

  @override
  State<RiwayatTab> createState() => _RiwayatTabState();
}

class _RiwayatTabState extends State<RiwayatTab> with SingleTickerProviderStateMixin {
  // Period filter state: 0 for 7 Hari, 1 for 30 Hari, 2 for Bulanan
  int _selectedPeriod = 0;

  // Chart nutrient filter: 0 for Kalori, 1 for Protein, 2 for Karbohidrat, 3 for Lemak
  int _selectedChartNutrient = 0;

  // Datasets for 7 Days, 30 Days, and Bulanan
  late _HistoryDataBundle _data7Days;
  late _HistoryDataBundle _data30Days;
  late _HistoryDataBundle _dataMonthly;

  bool _isLoading = true;
  String? _errorMessage;
  String? _profileErrorMessage;
  UserProfile? _userProfile;
  List<Map<String, dynamic>>? _raw90Data;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();
  }

  Future<void> _fetchHistoryData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _profileErrorMessage = null;
    });

    final repo = DashboardRepository();
    final profileRepo = ProfileRepository();

    List<Map<String, dynamic>>? raw7;
    List<Map<String, dynamic>>? raw90;
    UserProfile? profile;

    // Fetch 7 days history
    try {
      raw7 = await repo.fetchDashboardHistory(days: 7);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('HttpException: ', '');
    }

    // Fetch 90 days history
    try {
      raw90 = await repo.fetchDashboardHistory(days: 90);
    } catch (e) {
      _errorMessage ??= e.toString().replaceAll('Exception: ', '').replaceAll('HttpException: ', '');
    }

    // Fetch user profile
    try {
      profile = await profileRepo.getProfile();
    } catch (e) {
      _profileErrorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('HttpException: ', '');
    }

    setState(() {
      _userProfile = profile;
      _isLoading = false;

      if (raw7 != null && raw90 != null) {
        _raw90Data = raw90;
        _data7Days = _parseHistoryData(raw7, 'Statistik 7 Hari', profile);
        
        // Filter the raw90 list for the last 30 days of data
        final now = DateTime.now();
        final limitDate30 = now.subtract(const Duration(days: 30));
        final raw30 = raw90.where((item) {
          final parsed = DateTime.tryParse(item['log_date'] as String);
          return parsed == null || parsed.isAfter(limitDate30);
        }).toList();
        
        _data30Days = _parseHistoryData(raw30, 'Statistik 30 Hari', profile);
        _dataMonthly = _parseHistoryData(raw90, 'Statistik Bulanan', profile, filterMonth: _selectedMonth);
      }
    });
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + offset);
      if (_raw90Data != null) {
        _dataMonthly = _parseHistoryData(_raw90Data!, 'Statistik Bulanan', _userProfile, filterMonth: _selectedMonth);
      }
    });
  }

  _HistoryDataBundle _parseHistoryData(
    List<Map<String, dynamic>> rawList,
    String periodText,
    UserProfile? profile, {
    DateTime? filterMonth,
  }) {
    // If filterMonth is set, filter by year and month
    final filteredList = rawList.where((item) {
      if (filterMonth == null) return true;
      final parsedDate = DateTime.tryParse(item['log_date'] as String);
      if (parsedDate == null) return false;
      return parsedDate.year == filterMonth.year && parsedDate.month == filterMonth.month;
    }).toList();

    double totalCal = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalSugar = 0;

    final targetCalories = profile != null && profile.caloriesKcal > 0 ? profile.caloriesKcal.toDouble() : 2000.0;
    final targetProtein = profile != null && profile.proteinG > 0 ? profile.proteinG.toDouble() : 60.0;
    final targetCarbs = profile != null && profile.carbohydrateG > 0 ? profile.carbohydrateG.toDouble() : 300.0;
    final targetFat = profile != null && profile.fatG > 0 ? profile.fatG.toDouble() : 65.0;

    List<_ChartBarData> calBars = [];
    List<_ChartBarData> proteinBars = [];
    List<_ChartBarData> carbsBars = [];
    List<_ChartBarData> fatBars = [];
    List<_DailyHistoryItem> dailyList = [];

    // Sort by log_date ascending
    final sortedList = List<Map<String, dynamic>>.from(filteredList);
    sortedList.sort((a, b) => (a['log_date'] as String).compareTo(b['log_date'] as String));

    for (var item in sortedList) {
      final dateStr = item['log_date'] as String;
      final double cal = (item['total_calories'] as num?)?.toDouble() ?? 0.0;
      final double prot = (item['total_protein'] as num?)?.toDouble() ?? 0.0;
      final double carbs = (item['total_carbohydrate'] as num?)?.toDouble() ?? 0.0;
      final double fat = (item['total_fat'] as num?)?.toDouble() ?? 0.0;
      final double sugar = (item['total_sugar'] as num?)?.toDouble() ?? 0.0;

      final parsedDate = DateTime.tryParse(dateStr);
      final label = parsedDate != null ? '${parsedDate.day}' : dateStr;

      calBars.add(_ChartBarData(label: label, actual: cal, target: targetCalories));
      proteinBars.add(_ChartBarData(label: label, actual: prot, target: targetProtein));
      carbsBars.add(_ChartBarData(label: label, actual: carbs, target: targetCarbs));
      fatBars.add(_ChartBarData(label: label, actual: fat, target: targetFat));

      totalCal += cal;
      totalProtein += prot;
      totalCarbs += carbs;
      totalFat += fat;
      totalSugar += sugar;

      dailyList.add(_DailyHistoryItem(
        date: _formatHistoryDate(parsedDate ?? DateTime.now()),
        calories: cal.toInt(),
        status: cal >= targetCalories ? _GoalStatus.tercapai : _GoalStatus.diBawah,
        protein: prot.toInt(),
        carbs: carbs.toInt(),
        fat: fat.toInt(),
        sugar: sugar.toInt(),
      ));
    }

    final hasData = sortedList.isNotEmpty;
    final count = hasData ? sortedList.length : 1;

    final caloriesAvg = hasData ? (totalCal / count).round() : null;
    final proteinAvg = hasData ? (totalProtein / count).round() : null;
    final carbsAvg = hasData ? (totalCarbs / count).round() : null;
    final fatAvg = hasData ? (totalFat / count).round() : null;
    final sugarAvg = hasData ? (totalSugar / count).round() : null;

    final achievementPercentage = hasData && caloriesAvg != null
        ? (caloriesAvg / targetCalories * 100).round()
        : 0;

    return _HistoryDataBundle(
      periodText: periodText,
      caloriesAvg: caloriesAvg,
      proteinAvg: proteinAvg,
      carbsAvg: carbsAvg,
      fatAvg: fatAvg,
      sugarAvg: sugarAvg,
      consistentDays: sortedList.length,
      achievementPercentage: achievementPercentage,
      targetCalories: targetCalories.toInt(),
      chartBars: calBars.isNotEmpty ? calBars : [
        _ChartBarData(label: '-', actual: 0, target: targetCalories)
      ],
      proteinChartBars: proteinBars.isNotEmpty ? proteinBars : [
        _ChartBarData(label: '-', actual: 0, target: targetProtein)
      ],
      carbsChartBars: carbsBars.isNotEmpty ? carbsBars : [
        _ChartBarData(label: '-', actual: 0, target: targetCarbs)
      ],
      fatChartBars: fatBars.isNotEmpty ? fatBars : [
        _ChartBarData(label: '-', actual: 0, target: targetFat)
      ],
      dailyList: dailyList,
    );
  }

  String _formatHistoryDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'id').format(date);
  }

  _HistoryDataBundle _getActiveBundle() {
    switch (_selectedPeriod) {
      case 0:
        return _data7Days;
      case 1:
        return _data30Days;
      case 2:
        return _dataMonthly;
      default:
        return _data7Days;
    }
  }

  List<_ChartBarData> _getActiveChartBars(_HistoryDataBundle bundle) {
    switch (_selectedChartNutrient) {
      case 0:
        return bundle.chartBars;
      case 1:
        return bundle.proteinChartBars;
      case 2:
        return bundle.carbsChartBars;
      case 3:
        return bundle.fatChartBars;
      default:
        return bundle.chartBars;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF095D40);
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);
    const Color borderGray = Color(0xFFE2E8F0);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
          ),
        ),
      );
    }

    // Kasus C: Keduanya gagal
    if (_errorMessage != null && _userProfile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat data.\n$_errorMessage\n${_profileErrorMessage ?? ""}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: textDark, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchHistoryData,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                  child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget bodyContent;

    // Kasus B: Profile berhasil, History gagal
    if (_errorMessage != null && _userProfile != null) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data riwayat.\n$_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: textDark, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchHistoryData,
                style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    } else if (_userProfile != null && !_userProfile!.hasNutritionTarget) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.playlist_add_check_circle_outlined,
                color: Color(0xFF14B8A6),
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Target nutrisi belum diatur',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan lengkapi profil Anda di menu Profil untuk mengaktifkan target nutrisi harian.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final activeBundle = _getActiveBundle();
      final chartBars = _getActiveChartBars(activeBundle);

      bodyContent = SingleChildScrollView(
        key: ValueKey<int>(_selectedPeriod),
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kasus A: History berhasil, Profile gagal (Show error banner inside card/section)
              if (_profileErrorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Gagal memuat target dari profil: $_profileErrorMessage. Menggunakan target default.',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              _buildSummaryCard(activeBundle),
              const SizedBox(height: 24),
              _buildChartSection(activeBundle, chartBars),
              const SizedBox(height: 24),
              _buildDailyHistorySection(activeBundle),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Title, Period navigation, Notification bell)
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Riwayat',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_selectedPeriod == 2)
                            GestureDetector(
                              onTap: () => _changeMonth(-1),
                              child: const Icon(Icons.chevron_left, size: 18, color: textMuted),
                            ),
                          Text(
                            _selectedPeriod == 2
                                ? DateFormat('MMMM yyyy', 'id').format(_selectedMonth).toUpperCase()
                                : DateFormat('MMMM yyyy', 'id').format(DateTime.now()).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: textMuted,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          if (_selectedPeriod == 2)
                            GestureDetector(
                              onTap: () => _changeMonth(1),
                              child: const Icon(Icons.chevron_right, size: 18, color: textMuted),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderGray),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_none_outlined,
                        color: textDark,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Belum ada pemberitahuan baru'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 2. Filter Periode (Segmented control)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildPeriodButton(0, '7 Hari'),
                    _buildPeriodButton(1, '30 Hari'),
                    _buildPeriodButton(2, 'Bulanan'),
                  ],
                ),
              ),
            ),

            // 3. Scrollable Content Area
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: bodyContent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Segmented control button builder
  Widget _buildPeriodButton(int index, String label) {
    final bool isSelected = _selectedPeriod == index;
    const Color accentTeal = Color(0xFF14B8A6);
    const Color textMuted = Color(0xFF64748B);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = index;
            // Force re-calculation of monthly if switched back to bulanan
            if (index == 2 && _raw90Data != null) {
              _dataMonthly = _parseHistoryData(_raw90Data!, 'Statistik Bulanan', _userProfile, filterMonth: _selectedMonth);
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? accentTeal : textMuted,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // Summary Card Builder
  Widget _buildSummaryCard(_HistoryDataBundle bundle) {
    const Color primaryGreen = Color(0xFF095D40);
    const Color accentTeal = Color(0xFF14B8A6);
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);
    const Color borderGray = Color(0xFFE2E8F0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGray, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ringkasan Nutrisi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  bundle.periodText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Metrics grid: 3 rows x 2 cols
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.local_fire_department_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  label: 'Kalori Rata-rata',
                  value: bundle.caloriesAvg != null ? '${bundle.caloriesAvg}' : '-',
                  unit: bundle.caloriesAvg != null ? ' kcal' : '',
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.fitness_center_outlined,
                  iconColor: primaryGreen,
                  label: 'Protein Rata-rata',
                  value: bundle.proteinAvg != null ? '${bundle.proteinAvg}' : '-',
                  unit: bundle.proteinAvg != null ? ' g' : '',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.rice_bowl_outlined,
                  iconColor: const Color(0xFFF97316),
                  label: 'Karbohidrat Rata-rata',
                  value: bundle.carbsAvg != null ? '${bundle.carbsAvg}' : '-',
                  unit: bundle.carbsAvg != null ? ' g' : '',
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.opacity_outlined,
                  iconColor: const Color(0xFF0284C7),
                  label: 'Lemak Rata-rata',
                  value: bundle.fatAvg != null ? '${bundle.fatAvg}' : '-',
                  unit: bundle.fatAvg != null ? ' g' : '',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.cookie_outlined,
                  iconColor: const Color(0xFFDC2626),
                  label: 'Gula Rata-rata',
                  value: bundle.sugarAvg != null ? '${bundle.sugarAvg}' : '-',
                  unit: bundle.sugarAvg != null ? ' g' : '',
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.task_alt_outlined,
                  iconColor: primaryGreen,
                  label: 'Hari Konsisten',
                  value: '${bundle.consistentDays}',
                  unit: ' Hari',
                  valueColor: const Color(0xFFD97706),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(color: borderGray),
          const SizedBox(height: 16),

          // Achievement progress section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pencapaian',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textMuted,
                ),
              ),
              Text(
                '${bundle.achievementPercentage}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: accentTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (bundle.achievementPercentage / 100).clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE2E8F0),
              color: accentTeal,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Asupan Kalori vs Target',
                style: TextStyle(fontSize: 11, color: textMuted, fontWeight: FontWeight.w500),
              ),
              Text(
                '${bundle.caloriesAvg ?? "-"} / ${bundle.targetCalories} kcal',
                style: const TextStyle(fontSize: 11, color: textDark, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
    Color? valueColor,
  }) {
    const Color textMuted = Color(0xFF64748B);
    const Color textDark = Color(0xFF1E293B);

    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: valueColor ?? textDark,
                      ),
                    ),
                    TextSpan(
                      text: unit,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Nutrition Chart Section Builder
  Widget _buildChartSection(_HistoryDataBundle bundle, List<_ChartBarData> chartBars) {
    const Color primaryGreen = Color(0xFF095D40);
    const Color accentTeal = Color(0xFF14B8A6);
    const Color textDark = Color(0xFF1E293B);
    const Color borderGray = Color(0xFFE2E8F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Grafik Nutrisi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Analisis Lengkap grafik nutrisi (simulasi)'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Analisis Lengkap →',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Nutrient sub-filters (Kalori, Protein, Karbohidrat, Lemak)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildChartFilterChip(0, 'Kalori'),
            _buildChartFilterChip(1, 'Protein'),
            _buildChartFilterChip(2, 'Karbohidrat'),
            _buildChartFilterChip(3, 'Lemak'),
          ],
        ),
        const SizedBox(height: 16),

        // The Bar Chart Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderGray, width: 1.2),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Legend row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: accentTeal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Aktual: ${chartBars.isNotEmpty ? chartBars.last.actual : 0}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Text(
                        '---',
                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Target: ${chartBars.isNotEmpty ? chartBars.last.target : 0}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Animated Graph Bars Grid
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: SizedBox(
                  height: 180,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: chartBars.map((bar) {
                      const double maxBarHeight = 130.0;
                      final double targetHeight = maxBarHeight;
                      final double actualHeight = bar.target > 0 
                          ? (bar.actual / bar.target * maxBarHeight).clamp(10.0, maxBarHeight * 1.2) 
                          : 10.0;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // Background Bar (Target boundary)
                                Container(
                                  width: 22,
                                  height: targetHeight,
                                  decoration: BoxDecoration(
                                    color: accentTeal.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                                Positioned(
                                  top: maxBarHeight - targetHeight,
                                  child: Container(
                                    width: 32,
                                    height: 1,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade300,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Foreground Bar (Actual consumption)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutBack,
                                  width: 22,
                                  height: actualHeight,
                                  decoration: BoxDecoration(
                                    color: accentTeal,
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            bar.label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartFilterChip(int index, String label) {
    final bool isSelected = _selectedChartNutrient == index;
    const Color accentTeal = Color(0xFF14B8A6);
    const Color borderGray = Color(0xFFE2E8F0);
    const Color textDark = Color(0xFF1E293B);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChartNutrient = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentTeal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentTeal : borderGray,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Daily History List Section Builder
  Widget _buildDailyHistorySection(_HistoryDataBundle bundle) {
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Harian',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 12),

        if (bundle.dailyList.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Text(
                'Tidak ada riwayat konsumsi pada periode ini.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                ),
              ),
            ),
          )
        else
          Column(
            children: bundle.dailyList.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildDailyHistoryCard(item),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildDailyHistoryCard(_DailyHistoryItem item) {
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);
    const Color borderGray = Color(0xFFE2E8F0);

    Color badgeBgColor;
    Color badgeTextColor;
    String badgeText;

    switch (item.status) {
      case _GoalStatus.tercapai:
        badgeBgColor = const Color(0xFFD1FAE5);
        badgeTextColor = const Color(0xFF065F46);
        badgeText = 'Target Tercapai';
        break;
      case _GoalStatus.diBawah:
        badgeBgColor = const Color(0xFFFEE2E2);
        badgeTextColor = const Color(0xFF991B1B);
        badgeText = 'Di Bawah Target';
        break;
      case _GoalStatus.terlampaui:
        badgeBgColor = const Color(0xFFFFEDD5);
        badgeTextColor = const Color(0xFF9A3412);
        badgeText = 'Target Terlampaui';
        break;
    }

    final dayNum = item.date.split(' ').first;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGray, width: 1.2),
      ),
      padding: const EdgeInsets.all(14.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFE6F4F1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              dayNum,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF095D40),
              ),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${item.calories}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const TextSpan(
                        text: ' kcal',
                        style: TextStyle(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.status == _GoalStatus.tercapai 
                          ? Icons.check_circle_outline 
                          : (item.status == _GoalStatus.diBawah ? Icons.warning_amber_rounded : Icons.info_outline),
                      color: badgeTextColor,
                      size: 11,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: badgeTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailRiwayatScreen(
                        date: item.date,
                        totalCalories: item.calories,
                        protein: item.protein,
                        carbs: item.carbs,
                        fat: item.fat,
                        sugar: item.sugar,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Lihat Detail',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF14B8A6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryDataBundle {
  final String periodText;
  final int? caloriesAvg;
  final int? proteinAvg;
  final int? carbsAvg;
  final int? fatAvg;
  final int? sugarAvg;
  final int consistentDays;
  final int achievementPercentage;
  final int targetCalories;
  final List<_ChartBarData> chartBars;
  final List<_ChartBarData> proteinChartBars;
  final List<_ChartBarData> carbsChartBars;
  final List<_ChartBarData> fatChartBars;
  final List<_DailyHistoryItem> dailyList;

  _HistoryDataBundle({
    required this.periodText,
    required this.caloriesAvg,
    required this.proteinAvg,
    required this.carbsAvg,
    required this.fatAvg,
    required this.sugarAvg,
    required this.consistentDays,
    required this.achievementPercentage,
    required this.targetCalories,
    required this.chartBars,
    required this.proteinChartBars,
    required this.carbsChartBars,
    required this.fatChartBars,
    required this.dailyList,
  });
}

class _ChartBarData {
  final String label;
  final double actual;
  final double target;

  _ChartBarData({
    required this.label,
    required this.actual,
    required this.target,
  });
}

enum _GoalStatus {
  tercapai,
  diBawah,
  terlampaui,
}

class _DailyHistoryItem {
  final String date;
  final int calories;
  final _GoalStatus status;
  final int protein;
  final int carbs;
  final int fat;
  final int sugar;

  _DailyHistoryItem({
    required this.date,
    required this.calories,
    required this.status,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
  });
}
