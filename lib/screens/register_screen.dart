import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define the theme colors
    const Color accentTeal = Color(0xFF14B8A6); // Teal Accent
    const Color textDark = Color(0xFF1E293B); // Dark Slate
    const Color textMuted = Color(0xFF64748B); // Cool Gray
    const Color borderGray = Color(0xFFE2E8F0); // Light Gray Border

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark), // Plain arrow back as in design
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Left-aligned layout for consistency
              children: [
                // Title
                const Text(
                  'Buat Akun Baru',
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
                  'Mulai perjalanan hidup sehat bersama HealthPlate.',
                  style: TextStyle(
                    fontSize: 15,
                    color: textMuted,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 32),



                // Email Label
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                // Email TextField
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'contoh@email.com',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                    prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF94A3B8)),
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
                const SizedBox(height: 6),
                // Email Caption
                const Text(
                  'Email akan digunakan untuk verifikasi akun.',
                  style: TextStyle(
                    fontSize: 12,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 20),

                // Password Label
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                // Password TextField
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Masukkan password',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF94A3B8)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
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
                const SizedBox(height: 10),
                // Password Strength Indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: accentTeal, // Filled segment 1
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: accentTeal, // Filled segment 2
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: borderGray, // Empty segment 3
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sedang',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accentTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Konfirmasi Password Label
                const Text(
                  'Konfirmasi Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                // Konfirmasi Password TextField
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Masukkan ulang password',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                    prefixIcon: const Icon(Icons.history, color: Color(0xFF94A3B8)), // Icon indicating confirmation or repeat
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: const Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
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
                const SizedBox(height: 20),

                // Terms and Conditions Checkbox Row
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeToTerms,
                        activeColor: accentTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        side: const BorderSide(color: borderGray, width: 1.5),
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 14, color: textDark),
                          children: [
                            TextSpan(text: 'Saya menyetujui '),
                            TextSpan(
                              text: 'Syarat & Ketentuan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: accentTeal,
                              ),
                            ),
                            TextSpan(text: ' HealthPlate'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Daftar Button
                SizedBox(
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
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('temp_email', _emailController.text);
                        // Navigate to Profile Picture Setup (Step 1 of 3)
                        if (context.mounted) {
                          Navigator.pushNamed(context, '/profile-pic-setup');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentTeal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Footer (Sudah memiliki akun? Masuk)
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah memiliki akun? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: textMuted,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to Login page
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: accentTeal,
                          ),
                        ),
                      ),
                    ],
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
