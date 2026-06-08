import 'package:flutter/material.dart';
import 'detail_riwayat_screen.dart';

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
  late final _HistoryDataBundle _data7Days;
  late final _HistoryDataBundle _data30Days;
  late final _HistoryDataBundle _dataMonthly;

  @override
  void initState() {
    super.initState();
    _initDummyData();
  }

  void _initDummyData() {
    // 7 Days dummy data
    _data7Days = _HistoryDataBundle(
      periodText: 'Statistik 7 Hari',
      caloriesAvg: 1850,
      proteinAvg: 78,
      carbsAvg: 210,
      fatAvg: 52,
      sugarAvg: 24,
      consistentDays: 24,
      achievementPercentage: 92,
      targetCalories: 2000,
      chartBars: [
        _ChartBarData(label: '26', actual: 1600, target: 2000),
        _ChartBarData(label: '27', actual: 1400, target: 2000),
        _ChartBarData(label: '28', actual: 1950, target: 2000),
        _ChartBarData(label: '29', actual: 1500, target: 2000),
        _ChartBarData(label: '30', actual: 1900, target: 2000),
        _ChartBarData(label: '31', actual: 1300, target: 2000),
        _ChartBarData(label: '1 Jun', actual: 1800, target: 2000),
      ],
      proteinChartBars: [
        _ChartBarData(label: '26', actual: 70, target: 90),
        _ChartBarData(label: '27', actual: 65, target: 90),
        _ChartBarData(label: '28', actual: 88, target: 90),
        _ChartBarData(label: '29', actual: 60, target: 90),
        _ChartBarData(label: '30', actual: 85, target: 90),
        _ChartBarData(label: '31', actual: 55, target: 90),
        _ChartBarData(label: '1 Jun', actual: 75, target: 90),
      ],
      carbsChartBars: [
        _ChartBarData(label: '26', actual: 200, target: 250),
        _ChartBarData(label: '27', actual: 180, target: 250),
        _ChartBarData(label: '28', actual: 240, target: 250),
        _ChartBarData(label: '29', actual: 190, target: 250),
        _ChartBarData(label: '30', actual: 230, target: 250),
        _ChartBarData(label: '31', actual: 150, target: 250),
        _ChartBarData(label: '1 Jun', actual: 210, target: 250),
      ],
      fatChartBars: [
        _ChartBarData(label: '26', actual: 60, target: 70),
        _ChartBarData(label: '27', actual: 45, target: 70),
        _ChartBarData(label: '28', actual: 68, target: 70),
        _ChartBarData(label: '29', actual: 50, target: 70),
        _ChartBarData(label: '30', actual: 65, target: 70),
        _ChartBarData(label: '31', actual: 40, target: 70),
        _ChartBarData(label: '1 Jun', actual: 50, target: 70),
      ],
      dailyList: [
        _DailyHistoryItem(
          date: '1 Juni 2026',
          calories: 1800,
          status: _GoalStatus.tercapai,
          protein: 75,
          carbs: 210,
          fat: 50,
          sugar: 22,
        ),
        _DailyHistoryItem(
          date: '31 Mei 2026',
          calories: 1650,
          status: _GoalStatus.diBawah,
          protein: 68,
          carbs: 185,
          fat: 42,
          sugar: 18,
        ),
        _DailyHistoryItem(
          date: '30 Mei 2026',
          calories: 2100,
          status: _GoalStatus.tercapai, // 2100 is within margin of 2000
          protein: 85,
          carbs: 230,
          fat: 58,
          sugar: 26,
        ),
        _DailyHistoryItem(
          date: '29 Mei 2026',
          calories: 2450,
          status: _GoalStatus.terlampaui,
          protein: 98,
          carbs: 280,
          fat: 72,
          sugar: 35,
        ),
      ],
    );

    // 30 Days dummy data
    _data30Days = _HistoryDataBundle(
      periodText: 'Statistik 30 Hari',
      caloriesAvg: 1910,
      proteinAvg: 82,
      carbsAvg: 225,
      fatAvg: 55,
      sugarAvg: 26,
      consistentDays: 26,
      achievementPercentage: 87,
      targetCalories: 2000,
      chartBars: [
        _ChartBarData(label: 'W1', actual: 1880, target: 2000),
        _ChartBarData(label: 'W2', actual: 1950, target: 2000),
        _ChartBarData(label: 'W3', actual: 1720, target: 2000),
        _ChartBarData(label: 'W4', actual: 2090, target: 2000),
      ],
      proteinChartBars: [
        _ChartBarData(label: 'W1', actual: 80, target: 90),
        _ChartBarData(label: 'W2', actual: 84, target: 90),
        _ChartBarData(label: 'W3', actual: 72, target: 90),
        _ChartBarData(label: 'W4', actual: 92, target: 90),
      ],
      carbsChartBars: [
        _ChartBarData(label: 'W1', actual: 210, target: 250),
        _ChartBarData(label: 'W2', actual: 230, target: 250),
        _ChartBarData(label: 'W3', actual: 190, target: 250),
        _ChartBarData(label: 'W4', actual: 260, target: 250),
      ],
      fatChartBars: [
        _ChartBarData(label: 'W1', actual: 52, target: 70),
        _ChartBarData(label: 'W2', actual: 58, target: 70),
        _ChartBarData(label: 'W3', actual: 48, target: 70),
        _ChartBarData(label: 'W4', actual: 62, target: 70),
      ],
      dailyList: [
        _DailyHistoryItem(
          date: '28 Mei 2026',
          calories: 1920,
          status: _GoalStatus.tercapai,
          protein: 80,
          carbs: 220,
          fat: 55,
          sugar: 23,
        ),
        _DailyHistoryItem(
          date: '27 Mei 2026',
          calories: 1510,
          status: _GoalStatus.diBawah,
          protein: 60,
          carbs: 170,
          fat: 40,
          sugar: 15,
        ),
        _DailyHistoryItem(
          date: '26 Mei 2026',
          calories: 2300,
          status: _GoalStatus.terlampaui,
          protein: 94,
          carbs: 260,
          fat: 65,
          sugar: 30,
        ),
      ],
    );

    // Monthly dummy data
    _dataMonthly = _HistoryDataBundle(
      periodText: 'Statistik Bulanan',
      caloriesAvg: 1950,
      proteinAvg: 85,
      carbsAvg: 235,
      fatAvg: 58,
      sugarAvg: 27,
      consistentDays: 28,
      achievementPercentage: 90,
      targetCalories: 2000,
      chartBars: [
        _ChartBarData(label: 'Mar', actual: 1820, target: 2000),
        _ChartBarData(label: 'Apr', actual: 1980, target: 2000),
        _ChartBarData(label: 'Mei', actual: 2050, target: 2000),
      ],
      proteinChartBars: [
        _ChartBarData(label: 'Mar', actual: 78, target: 90),
        _ChartBarData(label: 'Apr', actual: 86, target: 90),
        _ChartBarData(label: 'Mei', actual: 91, target: 90),
      ],
      carbsChartBars: [
        _ChartBarData(label: 'Mar', actual: 215, target: 250),
        _ChartBarData(label: 'Apr', actual: 240, target: 250),
        _ChartBarData(label: 'Mei', actual: 255, target: 250),
      ],
      fatChartBars: [
        _ChartBarData(label: 'Mar', actual: 50, target: 70),
        _ChartBarData(label: 'Apr', actual: 60, target: 70),
        _ChartBarData(label: 'Mei', actual: 63, target: 70),
      ],
      dailyList: [
        _DailyHistoryItem(
          date: '25 Mei 2026',
          calories: 2020,
          status: _GoalStatus.tercapai,
          protein: 85,
          carbs: 235,
          fat: 58,
          sugar: 24,
        ),
        _DailyHistoryItem(
          date: '24 Mei 2026',
          calories: 1450,
          status: _GoalStatus.diBawah,
          protein: 58,
          carbs: 165,
          fat: 38,
          sugar: 12,
        ),
        _DailyHistoryItem(
          date: '23 Mei 2026',
          calories: 2500,
          status: _GoalStatus.terlampaui,
          protein: 102,
          carbs: 290,
          fat: 75,
          sugar: 38,
        ),
      ],
    );
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

    final activeBundle = _getActiveBundle();
    final chartBars = _getActiveChartBars(activeBundle);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Title, Period, Notification bell)
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Riwayat',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      Text(
                        'JUNI 2026',
                        style: TextStyle(
                          fontSize: 12,
                          color: textMuted,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
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
                child: SingleChildScrollView(
                  key: ValueKey<int>(_selectedPeriod),
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Ringkasan Nutrisi
                        _buildSummaryCard(activeBundle),
                        const SizedBox(height: 24),

                        // Section Grafik Nutrisi
                        _buildChartSection(activeBundle, chartBars),
                        const SizedBox(height: 24),

                        // Section Riwayat Harian
                        _buildDailyHistorySection(activeBundle),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
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
                      color: Colors.black.withValues(alpha: 0.05),
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
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Header: Title & statistics duration badge
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
                  value: '${bundle.caloriesAvg}',
                  unit: ' kcal',
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.fitness_center_outlined,
                  iconColor: primaryGreen,
                  label: 'Protein Rata-rata',
                  value: '${bundle.proteinAvg}',
                  unit: ' g',
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
                  value: '${bundle.carbsAvg}',
                  unit: ' g',
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.opacity_outlined,
                  iconColor: const Color(0xFF0284C7),
                  label: 'Lemak Rata-rata',
                  value: '${bundle.fatAvg}',
                  unit: ' g',
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
                  value: '${bundle.sugarAvg}',
                  unit: ' g',
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
              value: bundle.achievementPercentage / 100,
              backgroundColor: const Color(0xFFE2E8F0),
              color: accentTeal,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target: ${bundle.targetCalories} kcal',
                style: const TextStyle(fontSize: 11, color: textMuted, fontWeight: FontWeight.w500),
              ),
              Text(
                'Rata-rata: ${bundle.caloriesAvg} kcal',
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
                        'Aktual: ${chartBars.last.actual}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      // Simulated dashed line dot
                      const Text(
                        '---',
                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Target: ${chartBars.last.target}',
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
                      // Heights calculation (max 130px representation for graph bars)
                      const double maxBarHeight = 130.0;
                      
                      // Normalize heights against target height representation
                      final double targetHeight = maxBarHeight;
                      final double actualHeight = (bar.actual / bar.target * maxBarHeight).clamp(10.0, maxBarHeight * 1.2);

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
                                    color: accentTeal.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                                // Dotted horizontal target line simulation (placed at target boundary level)
                                Positioned(
                                  top: maxBarHeight - targetHeight,
                                  child: Container(
                                    width: 32,
                                    height: 1,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade300,
                                          style: BorderStyle.solid, // solid boundary line
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
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: bar.label == '1 Jun' ? FontWeight.bold : FontWeight.normal,
                              color: bar.label == '1 Jun' ? primaryGreen : const Color(0xFF64748B),
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

        // List of history item cards
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

    // Extraction day number for round visual
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
          // Circular Date representation
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

          // Detail info columns
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

          // Right side Actions: Badge & Button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Badge status
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
              // Button Lihat Detail
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
                    color: Color(0xFF14B8A6), // Accent Teal
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

// Data representation classes
class _HistoryDataBundle {
  final String periodText;
  final int caloriesAvg;
  final int proteinAvg;
  final int carbsAvg;
  final int fatAvg;
  final int sugarAvg;
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
