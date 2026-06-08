import 'package:flutter/material.dart';

class TambahKonsumsiManualScreen extends StatefulWidget {
  final String initialMealTime; // 'Sarapan', 'Makan Siang', 'Makan Malam', 'Snack'

  const TambahKonsumsiManualScreen({
    super.key,
    required this.initialMealTime,
  });

  @override
  State<TambahKonsumsiManualScreen> createState() => _TambahKonsumsiManualScreenState();
}

class _TambahKonsumsiManualScreenState extends State<TambahKonsumsiManualScreen> {
  // Tab state: 0 for Makanan, 1 for Minuman
  int _selectedTab = 0;

  // Selected meal time state
  late String _selectedMealTime;

  // Controllers
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController(text: '1');
  
  // Nutrients
  final TextEditingController _caloryController = TextEditingController(text: '0');
  final TextEditingController _proteinController = TextEditingController(text: '0');
  final TextEditingController _carbsController = TextEditingController(text: '0');
  final TextEditingController _fatController = TextEditingController(text: '0');
  final TextEditingController _sugarController = TextEditingController(text: '0');
  
  final TextEditingController _catatanController = TextEditingController();

  String _selectedSatuan = 'Piring';
  bool _hasPhoto = true;
  String _photoName = 'Makan Siang.jpg';
  String _photoSize = '2.4 MB';

  final List<String> _mealTimes = ['Sarapan', 'Makan Siang', 'Makan Malam', 'Snack'];
  final List<String> _satuanOptions = ['Piring', 'Gram', 'Porsi', 'Gelas', 'Mangkok', 'Mililiter'];

  @override
  void initState() {
    super.initState();
    _selectedMealTime = widget.initialMealTime;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    _caloryController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _sugarController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _simpanKonsumsi() {
    final name = _namaController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama konsumsi tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text('$name berhasil ditambahkan ke $_selectedMealTime!'),
          ],
        ),
        backgroundColor: const Color(0xFF095D40), // Dark green theme
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                      // 1. Tab Makanan / Minuman
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

                      // 2. Waktu Konsumsi
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

                      // 3. Nama Konsumsi
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
                          hintText: 'Cari atau masukkan nama makanan',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
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
                      const SizedBox(height: 24),

                      // 4. Jumlah & Satuan
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
                                  keyboardType: TextInputType.number,
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
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedSatuan,
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
                                  items: _satuanOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedSatuan = newValue;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 5. Informasi Nutrisi (Opsional)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderGray, width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Informasi Nutrisi (Opsional)',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                                Icon(
                                  Icons.qr_code_scanner,
                                  color: accentTeal.withValues(alpha: 0.8),
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Isi jika diketahui atau gunakan data hasil scan barcode.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textMuted,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Row 1: Kalori & Protein
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNutrientTextField(
                                    label: 'Kalori (kcal)',
                                    controller: _caloryController,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildNutrientTextField(
                                    label: 'Protein (g)',
                                    controller: _proteinController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Row 2: Karbohidrat & Lemak
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNutrientTextField(
                                    label: 'Karbohidrat (g)',
                                    controller: _carbsController,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildNutrientTextField(
                                    label: 'Lemak (g)',
                                    controller: _fatController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Row 3: Gula (Full Width or half width)
                            FractionallySizedBox(
                              widthFactor: 0.5,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: _buildNutrientTextField(
                                  label: 'Gula (g)',
                                  controller: _sugarController,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 6. Catatan (Opsional)
                      const Text(
                        'Catatan (Opsional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _catatanController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Tambahkan detail atau instruksi khusus...',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          contentPadding: const EdgeInsets.all(16),
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
                      const SizedBox(height: 24),

                      // 7. Foto Konsumsi (Opsional)
                      const Text(
                        'Foto Konsumsi (Opsional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_hasPhoto)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderGray, width: 1.2),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/food_lunch.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: accentTeal.withValues(alpha: 0.1),
                                    width: 50,
                                    height: 50,
                                    child: const Icon(Icons.restaurant, color: accentTeal),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _photoName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _photoSize,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  // Simulate changing photo
                                  setState(() {
                                    _photoName = 'Makan Siang_Baru.jpg';
                                    _photoSize = '1.8 MB';
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Foto berhasil diganti (simulasi)')),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  side: const BorderSide(color: borderGray),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Ganti',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textMuted,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() => _hasPhoto = false);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _hasPhoto = true;
                              _photoName = 'Unggahan.jpg';
                              _photoSize = '2.1 MB';
                            });
                          },
                          child: Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: borderGray,
                                width: 1.5,
                                style: BorderStyle.solid, // simulate dash with custom style or simple borders
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, color: textMuted),
                                SizedBox(height: 8),
                                Text(
                                  'Unggah Foto Makanan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                        color: accentTeal.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _simpanKonsumsi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Row(
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

  Widget _buildNutrientTextField({
    required String label,
    required TextEditingController controller,
  }) {
    const Color textDark = Color(0xFF1E293B);
    const Color borderGray = Color(0xFFE2E8F0);
    const Color accentTeal = Color(0xFF14B8A6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: borderGray, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: accentTeal, width: 1.8),
            ),
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
