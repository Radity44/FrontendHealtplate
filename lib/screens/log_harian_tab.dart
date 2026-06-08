import 'package:flutter/material.dart';
import 'tambah_konsumsi_manual_screen.dart';
import 'scan_barcode_screen.dart';

class LogHarianTab extends StatefulWidget {
  const LogHarianTab({super.key});

  @override
  State<LogHarianTab> createState() => _LogHarianTabState();
}

class _LogHarianTabState extends State<LogHarianTab> {
  // Switch to toggle between empty state and filled state
  bool _isTestingEmptyState = false;

  DateTime _selectedDate = DateTime.now();
  late final PageController _calendarPageController;
  late final DateTime _baseMonday;
  int _currentCalendarPage = 500;

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
  }

  @override
  void dispose() {
    _calendarPageController.dispose();
    super.dispose();
  }

  // Indonesian Date Formatter
  String _formatIndonesianDate(DateTime date) {
    final List<String> days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  // Monthly title based on page index
  String _getCalendarHeader(int pageIndex) {
    final mondayOfWeek = _baseMonday.add(Duration(days: (pageIndex - 500) * 7));
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[mondayOfWeek.month - 1]}, ${mondayOfWeek.year}';
  }

  Widget _buildDayNameHeader(String name) {
    final isSunday = name == 'MIN';
    return SizedBox(
      width: 36,
      child: Center(
        child: Text(
          name,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSunday ? const Color(0xFFDC2626) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  // Show Option Bottom Sheet
  void _showTambahKonsumsiSheet(String mealTime) {
    const Color primaryGreen = Color(0xFF095D40);
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tambah Konsumsi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pilih metode pencatatan konsumsi',
                    style: TextStyle(
                      fontSize: 14,
                      color: textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Option 1: Input Manual
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0FDFB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_note_outlined,
                        color: primaryGreen,
                        size: 24,
                      ),
                    ),
                    title: const Text(
                      'Input Manual',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textDark,
                      ),
                    ),
                    subtitle: const Text(
                      'Masukkan data makanan atau minuman secara manual.',
                      style: TextStyle(fontSize: 12, color: textMuted, height: 1.3),
                    ),
                    onTap: () {
                      Navigator.pop(context); // close bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TambahKonsumsiManualScreen(initialMealTime: mealTime),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Option 2: Scan Barcode
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0FDFB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_outlined,
                        color: primaryGreen,
                        size: 24,
                      ),
                    ),
                    title: const Text(
                      'Scan Barcode',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textDark,
                      ),
                    ),
                    subtitle: const Text(
                      'Isi data nutrisi secara otomatis melalui barcode produk.',
                      style: TextStyle(fontSize: 12, color: textMuted, height: 1.3),
                    ),
                    onTap: () {
                      Navigator.pop(context); // close bottom sheet
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScanBarcodeScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Batal Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF095D40);
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Log Harian, Date, Bell Notification, Switch Simulator)
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
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: primaryGreen,
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Log Harian',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                          Text(
                            _formatIndonesianDate(_selectedDate),
                            style: const TextStyle(
                              fontSize: 12,
                              color: textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Simulation Toggle Switch
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Data Terisi',
                            style: TextStyle(fontSize: 9, color: textMuted, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 28,
                            child: Switch(
                              value: !_isTestingEmptyState,
                              onChanged: (val) {
                                setState(() {
                                  _isTestingEmptyState = !val;
                                });
                              },
                              activeThumbColor: primaryGreen,
                              activeTrackColor: const Color(0xFFCCFBF1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      // Notification Bell Card
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
                ],
              ),
            ),

            // 2. Weekly Calendar Card (Snaps week-by-week)
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
                          fontSize: 15,
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
                                  color: Color(0xFF0284C7), // Solid blue background
                                  shape: BoxShape.circle,
                                );
                                textColor = Colors.white;
                              } else if (isToday) {
                                boxDecoration = BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF0284C7), // Blue outline border
                                    width: 1.5,
                                  ),
                                );
                                textColor = const Color(0xFF0284C7); // Blue text
                              } else {
                                boxDecoration = const BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                );
                                textColor = isSunday
                                    ? const Color(0xFFDC2626) // Red text
                                    : const Color(0xFF1E293B); // Dark slate
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
                                      fontSize: 14,
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

            const SizedBox(height: 10),

            // 3. Main content (Sections List)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Column(
                    children: [
                      // Section 1: Sarapan
                      _buildMealSection(
                        title: 'Sarapan',
                        timeRange: '07:00 - 09:00',
                        icon: Icons.wb_sunny_outlined,
                        iconColor: const Color(0xFFF59E0B), // Warm yellow/orange
                        iconBgColor: const Color(0xFFFEF3C7),
                        mealItems: _isTestingEmptyState
                            ? []
                            : [
                                _MealItemData(
                                  name: 'Nasi Goreng Spesial',
                                  detail: '200 gram • 450 kcal',
                                  icon: Icons.flatware,
                                ),
                                _MealItemData(
                                  name: 'Teh Manis',
                                  detail: '250 ml • 120 kcal',
                                  icon: Icons.local_drink_outlined,
                                ),
                              ],
                        totalCalories: _isTestingEmptyState ? 0 : 570,
                      ),
                      const SizedBox(height: 16),

                      // Section 2: Makan Siang
                      _buildMealSection(
                        title: 'Makan Siang',
                        timeRange: '12:00 - 14:00',
                        icon: Icons.restaurant_menu_outlined,
                        iconColor: const Color(0xFF10B981), // Solid green
                        iconBgColor: const Color(0xFFD1FAE5),
                        mealItems: _isTestingEmptyState
                            ? []
                            : [
                                _MealItemData(
                                  name: 'Ayam Panggang Nasi Merah',
                                  detail: '450 gram • 650 kcal',
                                  icon: Icons.flatware,
                                ),
                              ],
                        totalCalories: _isTestingEmptyState ? 0 : 650,
                      ),
                      const SizedBox(height: 16),

                      // Section 3: Makan Malam
                      _buildMealSection(
                        title: 'Makan Malam',
                        timeRange: '18:00 - 20:00',
                        icon: Icons.nightlight_round_outlined,
                        iconColor: const Color(0xFF6366F1), // Soft blue/indigo
                        iconBgColor: const Color(0xFFE0E7FF),
                        mealItems: _isTestingEmptyState
                            ? []
                            : [
                                _MealItemData(
                                  name: 'Ayam Kukus Bayam',
                                  detail: '350 gram • 550 kcal',
                                  icon: Icons.flatware,
                                ),
                              ],
                        totalCalories: _isTestingEmptyState ? 0 : 550,
                      ),
                      const SizedBox(height: 16),

                      // Section 4: Snack
                      _buildMealSection(
                        title: 'Snack',
                        timeRange: 'Kapan Saja',
                        icon: Icons.cookie_outlined,
                        iconColor: const Color(0xFFD97706), // Brownish amber
                        iconBgColor: const Color(0xFFFEF3C7),
                        mealItems: _isTestingEmptyState
                            ? []
                            : [
                                _MealItemData(
                                  name: 'Yogurt Rendah Gula',
                                  detail: '1 porsi • 150 kcal',
                                  icon: Icons.coffee_outlined,
                                ),
                              ],
                        totalCalories: _isTestingEmptyState ? 0 : 150,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Meal Section Card
  Widget _buildMealSection({
    required String title,
    required String timeRange,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required List<_MealItemData> mealItems,
    required int totalCalories,
  }) {
    const Color primaryGreen = Color(0xFF095D40);
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
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header line: Icon, Name, Time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const Spacer(),
              Text(
                timeRange,
                style: const TextStyle(
                  fontSize: 12,
                  color: textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // If no items: Empty state card inside the section
          if (mealItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderGray.withValues(alpha: 0.5), width: 1.2),
              ),
              child: Column(
                children: [
                  const Text(
                    'Belum ada konsumsi tercatat',
                    style: TextStyle(
                      fontSize: 13,
                      color: textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showTambahKonsumsiSheet(title),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      'Tambah Konsumsi',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // List of filled items
            Column(
              children: mealItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderGray, width: 1),
                          ),
                          child: Icon(item.icon, color: textMuted, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.detail,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: textMuted),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Menu aksi untuk ${item.name} (simulasi)'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            // Bottom stats and action line
            const SizedBox(height: 6),
            const Divider(color: borderGray, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Total ',
                      style: TextStyle(
                        fontSize: 13,
                        color: textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        color: textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$totalCalories kcal',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: () => _showTambahKonsumsiSheet(title),
                  icon: const Icon(Icons.add, size: 16, color: primaryGreen),
                  label: const Text(
                    'Tambah Lagi',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryGreen),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryGreen, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _MealItemData {
  final String name;
  final String detail;
  final IconData icon;

  _MealItemData({
    required this.name,
    required this.detail,
    required this.icon,
  });
}
