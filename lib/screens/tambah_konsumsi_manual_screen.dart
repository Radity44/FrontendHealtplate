import 'dart:async';
import 'package:flutter/material.dart';
import '../models/food_product.dart';
import '../repositories/log_repository.dart';
import '../repositories/nutrition_repository.dart';

class TambahKonsumsiManualScreen extends StatefulWidget {
  final String initialMealTime; // 'Sarapan', 'Makan Siang', 'Makan Malam', 'Snack'
  final DateTime selectedDate;

  const TambahKonsumsiManualScreen({
    super.key,
    required this.initialMealTime,
    required this.selectedDate,
  });

  @override
  State<TambahKonsumsiManualScreen> createState() => _TambahKonsumsiManualScreenState();
}

class _TambahKonsumsiManualScreenState extends State<TambahKonsumsiManualScreen> {
  int _selectedTab = 0; // 0 for Makanan, 1 for Minuman
  late String _selectedMealTime;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController(text: '100');

  // Selected product from search
  FoodProduct? _selectedProduct;
  List<FoodProduct> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  // Repositories
  final NutritionRepository _nutritionRepository = NutritionRepository();
  final LogRepository _logRepository = LogRepository();

  bool _isSaving = false;
  String? _errorMessage;

  final List<String> _mealTimes = ['Sarapan', 'Makan Siang', 'Makan Malam', 'Snack'];

  @override
  void initState() {
    super.initState();
    // Map Indonesian UI names to backend meal times if needed
    _selectedMealTime = widget.initialMealTime;
    _namaController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _namaController.removeListener(_onSearchChanged);
    _namaController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _namaController.text.trim();
      if (query.length >= 2 && (_selectedProduct == null || _selectedProduct!.productName != query)) {
        _performSearch(query);
      } else if (query.isEmpty) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final results = await _nutritionRepository.searchFoods(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _errorMessage = 'Gagal memuat pencarian makanan. Periksa koneksi Anda.';
      });
    }
  }

  String _mapMealTimeToBackend(String uiMealTime) {
    switch (uiMealTime) {
      case 'Sarapan':
        return 'Breakfast';
      case 'Makan Siang':
        return 'Lunch';
      case 'Makan Malam':
        return 'Dinner';
      case 'Snack':
        return 'Snack';
      default:
        return 'Breakfast';
    }
  }

  Future<void> _simpanKonsumsi() async {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan cari dan pilih produk makanan terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final portionStr = _jumlahController.text.trim();
    final portion = double.tryParse(portionStr) ?? 0.0;
    if (portion <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Porsi makanan harus lebih dari 0 gram.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final year = widget.selectedDate.year;
      final month = widget.selectedDate.month.toString().padLeft(2, '0');
      final day = widget.selectedDate.day.toString().padLeft(2, '0');
      final dateStr = '$year-$month-$day';

      await _logRepository.addFoodEntry(
        date: dateStr,
        productId: _selectedProduct!.productId,
        mealTime: _mapMealTimeToBackend(_selectedMealTime),
        portion: portion,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Konsumsi berhasil ditambahkan.'),
              ],
            ),
            backgroundColor: const Color(0xFF095D40),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true); // Return true to trigger dashboard refresh
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  // Get portion multiplier based on 100g base reference
  double get _portionMultiplier {
    final portion = double.tryParse(_jumlahController.text) ?? 100.0;
    return portion / 100.0;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF095D40);
    const Color accentTeal = Color(0xFF14B8A6);
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);
    const Color borderGray = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Konsumsi',
          style: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error display if any
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFEE2E2)),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Tab Makanan / Minuman
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTab = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 0 ? accentTeal : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Makanan',
                                    style: TextStyle(
                                      color: _selectedTab == 0 ? Colors.white : textMuted,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTab = 1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 1 ? accentTeal : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Minuman',
                                    style: TextStyle(
                                      color: _selectedTab == 1 ? Colors.white : textMuted,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Waktu Konsumsi
                      const Text(
                        'Waktu Konsumsi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _mealTimes.map((time) {
                            final isSelected = _selectedMealTime == time;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(time),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedMealTime = time);
                                  }
                                },
                                showCheckmark: false,
                                selectedColor: accentTeal,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : textDark,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? accentTeal : borderGray,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Nama Makanan Search Field
                      const Text(
                        'Nama Konsumsi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _namaController,
                        decoration: InputDecoration(
                          hintText: 'Cari nama makanan...',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                          suffixIcon: _isSearching
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(strokeWidth: 2, color: accentTeal),
                                  ),
                                )
                              : _namaController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: textMuted),
                                      onPressed: () {
                                        setState(() {
                                          _namaController.clear();
                                          _selectedProduct = null;
                                          _searchResults = [];
                                        });
                                      },
                                    )
                                  : null,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: borderGray, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: accentTeal, width: 2.0),
                          ),
                        ),
                      ),

                      // Search Results Overlay/Inline List
                      if (_searchResults.isNotEmpty && _selectedProduct == null) ...[
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderGray),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final food = _searchResults[index];
                              return ListTile(
                                title: Text(
                                  food.productName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                subtitle: Text(
                                  '${food.brandName ?? "Generic"} • ${food.caloriesKcal.toInt()} kcal / 100g',
                                  style: const TextStyle(color: textMuted, fontSize: 12),
                                ),
                                trailing: const Icon(Icons.add, color: accentTeal),
                                onTap: () {
                                  setState(() {
                                    _selectedProduct = food;
                                    _namaController.text = food.productName;
                                    _searchResults = [];
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Portion Size (Jumlah)
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Jumlah',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _jumlahController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (_) => setState(() {}),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: borderGray, width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: accentTeal, width: 2.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Satuan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: borderGray, width: 1.5),
                                  ),
                                  child: const Text(
                                    'Gram',
                                    style: TextStyle(fontWeight: FontWeight.w500, color: textDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Selected Food Nutrition Preview Card
                      if (_selectedProduct != null) ...[
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderGray, width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kandungan Gizi (${_jumlahController.text.isEmpty ? "0" : _jumlahController.text}g)',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildGiziPreviewItem('Kalori', '${(_selectedProduct!.caloriesKcal * _portionMultiplier).toInt()} kcal', primaryGreen),
                                  _buildGiziPreviewItem('Protein', '${(_selectedProduct!.proteinG * _portionMultiplier).toStringAsFixed(1)}g', const Color(0xFF0284C7)),
                                  _buildGiziPreviewItem('Karbo', '${(_selectedProduct!.carbohydrateG * _portionMultiplier).toStringAsFixed(1)}g', const Color(0xFFF97316)),
                                  _buildGiziPreviewItem('Lemak', '${(_selectedProduct!.fatG * _portionMultiplier).toStringAsFixed(1)}g', const Color(0xFFDC2626)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Simpan Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: accentTeal.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _simpanKonsumsi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_outlined, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Simpan ke Log Harian',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

  Widget _buildGiziPreviewItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
