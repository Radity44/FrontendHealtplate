import 'package:flutter/material.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  
  String _selectedGender = 'Pria';
  DateTime _selectedBirthDate = DateTime(1998, 6, 1); // For age 28 in 2026
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Ridho Rizky');
    _emailController = TextEditingController(text: 'ridho@email.com');
    _heightController = TextEditingController(text: '175');
    _weightController = TextEditingController(text: '70');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF095D40), // header bg color
              onPrimary: Colors.white, // header text color
              onSurface: Color(0xFF1E293B), // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF095D40), // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Perubahan profil berhasil disimpan!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF095D40),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Go back to profile screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF095D40);
    const Color accentTeal = Color(0xFF14B8A6);
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);
    const Color borderGray = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Photo Selector Area
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 54,
                            backgroundImage: AssetImage('assets/images/avatar_ridho.png'),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 36,
                            width: 36,
                            decoration: const BoxDecoration(
                              color: accentTeal,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Simulasi edit foto profil'),
                                    duration: Duration(milliseconds: 800),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Fields Section
                  const Text(
                    'Informasi Dasar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nama Lengkap
                  _buildLabel('Nama Lengkap'),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 15, color: textDark),
                    decoration: _buildInputDecoration(
                      hint: 'Masukkan nama lengkap',
                      prefixIcon: Icons.person_outline,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Email
                  _buildLabel('Email'),
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(fontSize: 15, color: textDark),
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration(
                      hint: 'contoh@email.com',
                      prefixIcon: Icons.email_outlined,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Jenis Kelamin
                  _buildLabel('Jenis Kelamin'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGenderCard('Pria', Icons.male),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGenderCard('Wanita', Icons.female),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tanggal Lahir
                  _buildLabel('Tanggal Lahir'),
                  GestureDetector(
                    onTap: _selectBirthDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderGray, width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 20, color: textMuted),
                              const SizedBox(width: 12),
                              Text(
                                _formatDate(_selectedBirthDate),
                                style: const TextStyle(fontSize: 15, color: textDark, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: textMuted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tinggi & Berat Badan
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Tinggi Badan'),
                            TextFormField(
                              controller: _heightController,
                              style: const TextStyle(fontSize: 15, color: textDark, fontWeight: FontWeight.bold),
                              keyboardType: TextInputType.number,
                              decoration: _buildInputDecoration(
                                hint: '175',
                                suffixText: 'cm',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Tinggi wajib diisi';
                                }
                                if (int.tryParse(val) == null) {
                                  return 'Harus angka';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Berat Badan'),
                            TextFormField(
                              controller: _weightController,
                              style: const TextStyle(fontSize: 15, color: textDark, fontWeight: FontWeight.bold),
                              keyboardType: TextInputType.number,
                              decoration: _buildInputDecoration(
                                hint: '70',
                                suffixText: 'kg',
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Berat wajib diisi';
                                }
                                if (int.tryParse(val) == null) {
                                  return 'Harus angka';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Simpan Perubahan Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildGenderCard(String gender, IconData icon) {
    final bool isSelected = _selectedGender == gender;
    const Color accentTeal = Color(0xFF14B8A6);
    const Color borderGray = Color(0xFFE2E8F0);
    const Color textDark = Color(0xFF1E293B);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE6F4F1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentTeal : borderGray,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? accentTeal : const Color(0xFF64748B),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? accentTeal : textDark,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    IconData? prefixIcon,
    String? suffixText,
  }) {
    const Color textMuted = Color(0xFF94A3B8);
    const Color borderGray = Color(0xFFE2E8F0);
    const Color primaryGreen = Color(0xFF095D40);

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: textMuted, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: textMuted, size: 20) : null,
      suffixText: suffixText,
      suffixStyle: const TextStyle(
        color: Color(0xFF1E293B),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderGray, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
