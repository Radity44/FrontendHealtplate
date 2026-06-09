import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/profile_repository.dart';
import '../services/session_manager.dart';

class GoalsSetupScreen extends StatefulWidget {
  const GoalsSetupScreen({super.key});

  @override
  State<GoalsSetupScreen> createState() => _GoalsSetupScreenState();
}

class _GoalsSetupScreenState extends State<GoalsSetupScreen> {
  // Nutrient target controllers with sane default values
  final TextEditingController _caloriesController = TextEditingController(text: '2000');
  final TextEditingController _proteinController = TextEditingController(text: '90');
  final TextEditingController _carbohydrateController = TextEditingController(text: '250');
  final TextEditingController _fatController = TextEditingController(text: '70');
  final TextEditingController _sugarController = TextEditingController(text: '30');

  bool _isLoading = false;

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbohydrateController.dispose();
    _fatController.dispose();
    _sugarController.dispose();
    super.dispose();
  }

  // Complete onboarding flow, save to backend and update SessionManager
  Future<void> _completeOnboarding() async {
    final caloriesText = _caloriesController.text.trim();
    final proteinText = _proteinController.text.trim();
    final carbsText = _carbohydrateController.text.trim();
    final fatText = _fatController.text.trim();
    final sugarText = _sugarController.text.trim();

    if (caloriesText.isEmpty || int.tryParse(caloriesText) == null) {
      _showSnackBar('Target kalori tidak valid');
      return;
    }
    if (proteinText.isEmpty || int.tryParse(proteinText) == null) {
      _showSnackBar('Target protein tidak valid');
      return;
    }
    if (carbsText.isEmpty || int.tryParse(carbsText) == null) {
      _showSnackBar('Target karbohidrat tidak valid');
      return;
    }
    if (fatText.isEmpty || int.tryParse(fatText) == null) {
      _showSnackBar('Target lemak tidak valid');
      return;
    }
    if (sugarText.isEmpty || int.tryParse(sugarText) == null) {
      _showSnackBar('Target gula tidak valid');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final caloriesVal = int.parse(caloriesText);
      final proteinVal = int.parse(proteinText);
      final carbsVal = int.parse(carbsText);
      final fatVal = int.parse(fatText);
      final sugarVal = int.parse(sugarText);

      final Map<String, dynamic> updatePayload = {
        'calories_kcal': caloriesVal,
        'protein_g': proteinVal,
        'carbohydrate_g': carbsVal,
        'fat_g': fatVal,
        'sugar_g': sugarVal,
      };

      final profileRepository = ProfileRepository();
      await profileRepository.updateProfile(updatePayload);

      // Save to SharedPreferences for local compatibility/fallbacks
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('profile_calories', caloriesVal);
      await prefs.setInt('profile_protein', proteinVal);
      await prefs.setInt('profile_carbohydrate', carbsVal);
      await prefs.setInt('profile_fat', fatVal);
      await prefs.setInt('profile_sugar', sugarVal);
      await prefs.setBool('is_logged_in', true);

      await SessionManager().setOnboardingCompleted(true);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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
    const Color textMuted = Color(0xFF64748B); // Cool Gray

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
          'Langkah 3 dari 3',
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
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rebranded Title
                const Text(
                  'Target Nutrisi Harian',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                // Subtitle
                const Text(
                  'Tentukan batas target konsumsi gizi Anda untuk memantau progres harian dengan akurat.',
                  style: TextStyle(
                    fontSize: 15,
                    color: textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Subtitle Info Box banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDFB), // Mint/light-teal bg
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFCCFBF1), width: 1.2),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: primaryGreen, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Target nutrisi digunakan untuk menghitung progres konsumsi harian dan memberikan peringatan ketika konsumsi melebihi batas yang ditentukan.',
                          style: TextStyle(
                            fontSize: 13,
                            color: primaryGreen,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Nutrient Target Inputs
                _buildNutrientInput(
                  label: 'Target Kalori Harian',
                  controller: _caloriesController,
                  suffix: 'kcal',
                  icon: Icons.local_fire_department_outlined,
                  hint: '2000',
                ),
                const SizedBox(height: 20),

                _buildNutrientInput(
                  label: 'Target Protein',
                  controller: _proteinController,
                  suffix: 'gram',
                  icon: Icons.fitness_center_outlined,
                  hint: '90',
                ),
                const SizedBox(height: 20),

                _buildNutrientInput(
                  label: 'Target Karbohidrat',
                  controller: _carbohydrateController,
                  suffix: 'gram',
                  icon: Icons.rice_bowl_outlined,
                  hint: '250',
                ),
                const SizedBox(height: 20),

                _buildNutrientInput(
                  label: 'Target Lemak',
                  controller: _fatController,
                  suffix: 'gram',
                  icon: Icons.opacity_outlined,
                  hint: '70',
                ),
                const SizedBox(height: 20),

                _buildNutrientInput(
                  label: 'Target Gula',
                  controller: _sugarController,
                  suffix: 'gram',
                  icon: Icons.cookie_outlined,
                  hint: '30',
                ),
                const SizedBox(height: 36),

                // Complete Button
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
                      onPressed: _isLoading ? null : _completeOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
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
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Mulai Menggunakan HealthPlate',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
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

  // Nutrient Input Form Field Builder
  Widget _buildNutrientInput({
    required String label,
    required TextEditingController controller,
    required String suffix,
    required IconData icon,
    required String hint,
  }) {
    const Color textDark = Color(0xFF1E293B);
    const Color accentTeal = Color(0xFF14B8A6);
    const Color borderGray = Color(0xFFE2E8F0);
    const Color textMuted = Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
            suffixText: suffix,
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
    );
  }
}
