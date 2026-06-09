import 'package:flutter/material.dart';
import '../repositories/profile_repository.dart';

class PersonalDataSetupScreen extends StatefulWidget {
  const PersonalDataSetupScreen({super.key});

  @override
  State<PersonalDataSetupScreen> createState() => _PersonalDataSetupScreenState();
}

class _PersonalDataSetupScreenState extends State<PersonalDataSetupScreen> {
  // Input controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // Gender selection state: 0 for none, 1 for Male, 2 for Female
  int _selectedGender = 0;

  // Date of birth DateTime state
  DateTime? _selectedBirthDate;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // Date picker launcher
  Future<void> _selectDate(BuildContext context) async {
    if (_isLoading) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF095D40), // Header color
              onPrimary: Colors.white, // Header text color
              onSurface: Color(0xFF1E293B), // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF095D40), // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        // Format date as DD/MM/YYYY for user display
        final day = picked.day.toString().padLeft(2, '0');
        final month = picked.month.toString().padLeft(2, '0');
        final year = picked.year;
        _dobController.text = '$day/$month/$year';
      });
    }
  }

  // Method to update user profile and navigate to Step 3
  Future<void> _submitData() async {
    final name = _nameController.text.trim();
    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();

    if (name.isEmpty) {
      _showSnackBar('Nama lengkap tidak boleh kosong');
      return;
    }
    if (_selectedGender == 0) {
      _showSnackBar('Silakan pilih jenis kelamin Anda');
      return;
    }
    if (_selectedBirthDate == null) {
      _showSnackBar('Silakan masukkan tanggal lahir Anda');
      return;
    }
    if (heightText.isEmpty || int.tryParse(heightText) == null) {
      _showSnackBar('Tinggi badan tidak valid');
      return;
    }
    if (weightText.isEmpty || int.tryParse(weightText) == null) {
      _showSnackBar('Berat badan tidak valid');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final formattedMonth = _selectedBirthDate!.month.toString().padLeft(2, '0');
      final formattedDay = _selectedBirthDate!.day.toString().padLeft(2, '0');
      final isoBirthDate = '${_selectedBirthDate!.year}-$formattedMonth-$formattedDay';

      final Map<String, dynamic> updatePayload = {
        'name': name,
        'gender': _selectedGender == 1 ? 'Male' : 'Female',
        'birth_date': isoBirthDate,
        'height_cm': int.parse(heightText),
        'weight_kg': int.parse(weightText),
      };

      final profileRepository = ProfileRepository();
      await profileRepository.updateProfile(updatePayload);

      if (mounted) {
        Navigator.pushNamed(context, '/goals-setup');
      }
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception: ', '').replaceAll('HttpException: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF095D40); // Dark Green
    const Color accentTeal = Color(0xFF14B8A6); // Teal Accent
    const Color textDark = Color(0xFF1E293B); // Dark Slate
    const Color textMuted = Color(0xFF64748B); // Cool Gray
    const Color borderGray = Color(0xFFE2E8F0); // Light border

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryGreen),
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
        ),
        title: const Text(
          'Langkah 2 dari 3',
          style: TextStyle(
            color: primaryGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Lengkapi Data Diri',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                // Subtitle
                const Text(
                  'Informasi dasar ini membantu kami memberikan rekomendasi nutrisi yang lebih sesuai.',
                  style: TextStyle(
                    fontSize: 15,
                    color: textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                // Nama Lengkap
                const Text(
                  'Nama Lengkap',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Masukkan nama Anda',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: borderGray, width: 1.5),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: borderGray, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: accentTeal, width: 2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Jenis Kelamin
                const Text(
                  'Jenis Kelamin',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Card Pria (Male)
                    Expanded(
                      child: GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _selectedGender = 1;
                                });
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: _selectedGender == 1
                                ? const Color(0xFFE6F4F1) // Light teal selected color
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedGender == 1 ? accentTeal : borderGray,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.male,
                                size: 28,
                                color: _selectedGender == 1 ? primaryGreen : textMuted,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pria',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedGender == 1 ? primaryGreen : textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Card Wanita (Female)
                    Expanded(
                      child: GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _selectedGender = 2;
                                });
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: _selectedGender == 2
                                ? const Color(0xFFE6F4F1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedGender == 2 ? accentTeal : borderGray,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.female,
                                size: 28,
                                color: _selectedGender == 2 ? primaryGreen : textMuted,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Wanita',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedGender == 2 ? primaryGreen : textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tanggal Lahir
                const Text(
                  'Tanggal Lahir',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dobController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: 'dd/mm/yyyy',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                        prefixIcon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF94A3B8)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: borderGray, width: 1.5),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: borderGray, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: accentTeal, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tinggi & Berat Badan
                Row(
                  children: [
                    // Tinggi Badan
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tinggi Badan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                              suffixText: 'cm',
                              suffixStyle: const TextStyle(color: textMuted, fontWeight: FontWeight.bold),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: borderGray, width: 1.5),
                              ),
                              disabledBorder: OutlineInputBorder(
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
                    // Berat Badan
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Berat Badan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                              suffixText: 'kg',
                              suffixStyle: const TextStyle(color: textMuted, fontWeight: FontWeight.bold),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: borderGray, width: 1.5),
                              ),
                              disabledBorder: OutlineInputBorder(
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
                  ],
                ),
                const SizedBox(height: 48),

                // Lanjutkan Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen, // Dark Green
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Lanjutkan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
