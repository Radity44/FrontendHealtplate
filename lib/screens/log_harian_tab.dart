import 'package:flutter/material.dart';
import '../models/daily_log.dart';
import '../models/log_entry.dart';
import '../models/meal_plan.dart';
import '../models/meal_plan_day.dart';
import '../models/meal_plan_meal.dart';
import '../repositories/log_repository.dart';
import 'tambah_konsumsi_manual_screen.dart';

import '../repositories/profile_repository.dart';

class LogHarianTab extends StatefulWidget {
  final VoidCallback? onRefreshDashboard;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final DailyLog? dailyLog;
  final MealPlan? activeMealPlan;
  final bool isLoading;

  const LogHarianTab({
    super.key,
    this.onRefreshDashboard,
    required this.selectedDate,
    required this.onDateChanged,
    this.dailyLog,
    this.activeMealPlan,
    this.isLoading = false,
  });

  @override
  State<LogHarianTab> createState() => _LogHarianTabState();
}

class _LogHarianTabState extends State<LogHarianTab> {
  DateTime _selectedDate = DateTime.now();
  late final PageController _calendarPageController;
  late final DateTime _baseMonday;
  int _currentCalendarPage = 500;

  // Repository
  final LogRepository _logRepository = LogRepository();

  DailyLog? get _dailyLog => widget.dailyLog;
  MealPlan? get _activeMealPlan => widget.activeMealPlan;
  bool _isLoading = true;
  String? _errorMessage;

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

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    final now = ProfileRepository.useMockDataForTests ? DateTime(2026, 6, 10) : DateTime.now();
    _baseMonday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    _calendarPageController = PageController(initialPage: 500);
    _currentCalendarPage = 500;
    _isLoading = widget.isLoading;
  }

  @override
  void didUpdateWidget(covariant LogHarianTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      setState(() {
        _selectedDate = widget.selectedDate;
      });
    }
    if (oldWidget.isLoading != widget.isLoading) {
      setState(() {
        _isLoading = widget.isLoading;
      });
    }
  }

  @override
  void dispose() {
    _calendarPageController.dispose();
    super.dispose();
  }

  String _formatDateString(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _refreshData() async {
    widget.onRefreshDashboard?.call();
  }

  Future<void> _logRecommendation(String mealTime, List<MealPlanMeal> meals) async {
    const Color primaryGreen = Color(0xFF095D40);
    
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
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Mencatat Konsumsi...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Menambahkan hidangan rekomendasi ke log harian Anda.',
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
        );
      },
    );

    try {
      final dateStr = _formatDateString(_selectedDate);
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rekomendasi menu berhasil dicatat!'),
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _refreshData();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // pop loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencatat rekomendasi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteEntry(LogEntry entry) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final dateStr = _formatDateString(_selectedDate);
      await _logRepository.deleteFoodEntry(date: dateStr, entryId: entry.entryId);
      await _refreshData();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konsumsi berhasil dihapus.'),
            backgroundColor: Color(0xFF095D40),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal menghapus makanan: $e';
      });
    }
  }

  void _showEditPortionDialog(LogEntry entry) {
    final TextEditingController portionController =
        TextEditingController(text: entry.portion.toInt().toString());
    const Color primaryGreen = Color(0xFF095D40);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ubah Porsi Makanan', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.foodProduct.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: portionController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Porsi (Gram)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final newPortion = double.tryParse(portionController.text) ?? 0.0;
                if (newPortion <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Porsi harus lebih dari 0.')),
                  );
                  return;
                }
                Navigator.pop(context);
                _executeEditFlow(entry, newPortion);
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Delete + Recreate sequential flow with loading dialog overlay
  Future<void> _executeEditFlow(LogEntry entry, double newPortion) async {
    const Color primaryGreen = Color(0xFF095D40);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(primaryGreen)),
                const SizedBox(height: 16),
                const Text('Memproses perubahan...', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final dateStr = _formatDateString(_selectedDate);
      // 1. Delete
      await _logRepository.deleteFoodEntry(date: dateStr, entryId: entry.entryId);
      // 2. Re-create
      await _logRepository.addFoodEntry(
        date: dateStr,
        productId: entry.foodProduct.productId,
        mealTime: entry.mealTime,
        portion: newPortion,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading overlay
        await _refreshData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Konsumsi berhasil diubah.'),
              backgroundColor: primaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading overlay
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah konsumsi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showEntryActions(LogEntry entry) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Ubah Porsi'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditPortionDialog(entry);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus Konsumsi', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteEntry(entry);
                },
              ),
            ],
          ),
        );
      },
    );
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
                    onTap: () async {
                      Navigator.pop(context); // close bottom sheet
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TambahKonsumsiManualScreen(
                            initialMealTime: mealTime,
                            selectedDate: _selectedDate,
                          ),
                        ),
                      );
                      if (result == true) {
                        _refreshData();
                      }
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
            // 1. Header (Log Harian, Date, Bell Notification)
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
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
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
                                  color: Color(0xFF0284C7),
                                  shape: BoxShape.circle,
                                );
                                textColor = Colors.white;
                              } else if (isToday) {
                                boxDecoration = BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF0284C7),
                                    width: 1.5,
                                  ),
                                );
                                textColor = const Color(0xFF0284C7);
                              } else {
                                boxDecoration = const BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                );
                                textColor = isSunday
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF1E293B);
                              }

                              return GestureDetector(
                                onTap: () {
                                  widget.onDateChanged(date);
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

            if (!_isToday(_selectedDate))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isPast(_selectedDate)
                              ? 'Data pada tanggal lampau hanya dapat dilihat dan tidak dapat diubah.'
                              : 'Data pada tanggal masa depan hanya dapat dilihat dan tidak dapat diubah.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB45309),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 3. Main content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                      ),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  'Gagal memuat log harian.\n$_errorMessage',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: textDark, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _refreshData,
                                  style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                                  child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _refreshData,
                          color: primaryGreen,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                              child: Column(
                                children: [
                                  _buildMealSection(
                                    title: 'Sarapan',
                                    timeRange: '07:00 - 09:00',
                                    icon: Icons.wb_sunny_outlined,
                                    iconColor: const Color(0xFFF59E0B),
                                    iconBgColor: const Color(0xFFFEF3C7),
                                    mealItems: _filterEntriesByMealTime('Breakfast'),
                                    totalCalories: _sumCaloriesByMealTime('Breakfast'),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildMealSection(
                                    title: 'Makan Siang',
                                    timeRange: '12:00 - 14:00',
                                    icon: Icons.restaurant_menu_outlined,
                                    iconColor: const Color(0xFF10B981),
                                    iconBgColor: const Color(0xFFD1FAE5),
                                    mealItems: _filterEntriesByMealTime('Lunch'),
                                    totalCalories: _sumCaloriesByMealTime('Lunch'),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildMealSection(
                                    title: 'Makan Malam',
                                    timeRange: '18:00 - 20:00',
                                    icon: Icons.nightlight_round_outlined,
                                    iconColor: const Color(0xFF6366F1),
                                    iconBgColor: const Color(0xFFE0E7FF),
                                    mealItems: _filterEntriesByMealTime('Dinner'),
                                    totalCalories: _sumCaloriesByMealTime('Dinner'),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildMealSection(
                                    title: 'Snack',
                                    timeRange: 'Kapan Saja',
                                    icon: Icons.cookie_outlined,
                                    iconColor: const Color(0xFFD97706),
                                    iconBgColor: const Color(0xFFFEF3C7),
                                    mealItems: _filterEntriesByMealTime('Snack'),
                                    totalCalories: _sumCaloriesByMealTime('Snack'),
                                  ),
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

  List<LogEntry> _filterEntriesByMealTime(String mealTime) {
    if (_dailyLog == null) return [];
    return _dailyLog!.logEntries.where((entry) => entry.mealTime.toLowerCase() == mealTime.toLowerCase()).toList();
  }

  int _sumCaloriesByMealTime(String mealTime) {
    final entries = _filterEntriesByMealTime(mealTime);
    double sum = 0;
    for (var entry in entries) {
      // potion is gram, caloriesKcal is per 100g.
      sum += (entry.foodProduct.caloriesKcal * (entry.portion / 100.0));
    }
    return sum.toInt();
  }

  Widget _buildMealSection({
    required String title,
    required String timeRange,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required List<LogEntry> mealItems,
    required int totalCalories,
  }) {
    const Color primaryGreen = Color(0xFF095D40);
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);
    const Color borderGray = Color(0xFFE2E8F0);

    final String mealType;
    if (title == 'Sarapan') {
      mealType = 'Breakfast';
    } else if (title == 'Makan Siang') {
      mealType = 'Lunch';
    } else if (title == 'Makan Malam') {
      mealType = 'Dinner';
    } else {
      mealType = 'Snack';
    }

    String? recMenuName;
    int? recCalories;
    List<MealPlanMeal>? recMeals;

    if (_activeMealPlan != null) {
      final activePlan = _activeMealPlan!;
      final activePackage = dummyMealPackages.firstWhere(
        (p) => p.name == activePlan.name,
        orElse: () => dummyMealPackages.first,
      );

      final dayNum = _selectedDate.weekday;
      final dayData = activePlan.days.firstWhere(
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

      List<MealPlanMeal> mealsForTime = [];
      String fallbackMenu = '';
      int fallbackCal = 0;

      if (mealType == 'Breakfast') {
        mealsForTime = dayData.breakfast;
        fallbackMenu = activePackage.breakfastMenu;
        fallbackCal = activePackage.breakfastCal;
      } else if (mealType == 'Lunch') {
        mealsForTime = dayData.lunch;
        fallbackMenu = activePackage.lunchMenu;
        fallbackCal = activePackage.lunchCal;
      } else if (mealType == 'Dinner') {
        mealsForTime = dayData.dinner;
        fallbackMenu = activePackage.dinnerMenu;
        fallbackCal = activePackage.dinnerCal;
      } else {
        mealsForTime = dayData.snack;
        fallbackMenu = activePackage.snackMenu;
        fallbackCal = activePackage.snackCal;
      }

      if (mealsForTime.isNotEmpty) {
        recMenuName = mealsForTime.map((m) => m.name).join(' + ');
        recCalories = mealsForTime.fold<int>(0, (s, m) => s + m.calories);
        recMeals = mealsForTime;
      } else if (fallbackMenu.isNotEmpty) {
        recMenuName = fallbackMenu;
        recCalories = fallbackCal;
      }
    }

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
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          if (recMenuName != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.tips_and_updates_outlined, size: 16, color: Color(0xFF2563EB)),
                            const SizedBox(width: 6),
                            Text(
                              'Rekomendasi Menu $title:',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          recMenuName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$recCalories kcal',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (recMeals != null && recMeals.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: !_isToday(_selectedDate)
                          ? null
                          : () => _logRecommendation(mealType, recMeals!),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Makan Ini',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (mealItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderGray.withOpacity(0.5), width: 1.2),
              ),
              child: Column(
                children: [
                  const Text(
                    'Belum ada konsumsi tercatat hari ini.',
                    style: TextStyle(
                      fontSize: 13,
                      color: textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tambahkan makanan pertama Anda untuk mulai memantau nutrisi harian.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: textMuted,
                    ),
                  ),
                  if (_isToday(_selectedDate)) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showTambahKonsumsiSheet(title),
                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                      label: const Text(
                        'Tambah Konsumsi',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else ...[
            Column(
              children: mealItems.map((item) {
                // calculate portion calories
                final calories = (item.foodProduct.caloriesKcal * (item.portion / 100.0)).toInt();
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
                          child: const Icon(Icons.flatware, color: textMuted, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.foodProduct.productName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.portion.toInt()} gram • $calories kcal',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isToday(_selectedDate))
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: textMuted),
                            onPressed: () => _showEntryActions(item),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
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
            if (_isToday(_selectedDate)) ...[
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
            ],
          ]
        ],
      ),
    );
  }
}
