import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/meal_plan.dart';
import '../repositories/profile_repository.dart';
import '../repositories/meal_plan_repository.dart';
import 'edit_profil_screen.dart';

class ProfilTab extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfilTab({
    super.key,
    required this.onLogout,
  });

  @override
  State<ProfilTab> createState() => _ProfilTabState();
}

class _ProfilTabState extends State<ProfilTab> {
  bool _isLoading = true;
  String? _errorMessage;
  UserProfile? _userProfile;
  MealPlan? _activeMealPlan;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ProfileRepository();
      final profile = await repository.getProfile();
      MealPlan? activePlan;
      try {
        activePlan = await MealPlanRepository().getActiveMealPlan();
      } catch (e) {
        debugPrint('Error loading active meal plan: $e');
      }
      setState(() {
        _userProfile = profile;
        _activeMealPlan = activePlan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('HttpException: ', '');
        _isLoading = false;
      });
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'HP';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  int _getAge(String birthDateStr) {
    if (birthDateStr.isEmpty) return 0;
    try {
      final birthDate = DateTime.parse(birthDateStr);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }

  void _showLogoutConfirmation() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Keluar',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curve,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Row(
              children: [
                Icon(Icons.logout, color: Colors.redAccent),
                SizedBox(width: 8),
                Text(
                  'Keluar dari akun?',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ],
            ),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari akun Anda?',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batalkan',
                  style: TextStyle(
                    color: Color(0xFF095D40), 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  widget.onLogout(); // execute logout
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Keluar'),
              ),
            ],
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
    const Color borderGray = Color(0xFFE2E8F0);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF14B8A6),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: textDark, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _fetchProfileData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final profile = _userProfile!;
    
    // Calculate BMI
    double weight = profile.weightKg.toDouble();
    double heightM = profile.heightCm.toDouble() / 100.0;
    double bmi = heightM > 0 ? weight / (heightM * heightM) : 0.0;
    double formattedBmi = double.parse(bmi.toStringAsFixed(1));

    String bmiStatus = 'Normal';
    if (bmi < 18.5) {
      bmiStatus = 'Kurus';
    } else if (bmi >= 25.0) {
      bmiStatus = 'Overweight';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchProfileData,
          color: const Color(0xFF14B8A6),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header (Title, Profile avatar, edit button)
                  _buildHeader(profile, primaryGreen, textDark, textMuted),
                  const SizedBox(height: 24),

                  // 2. Health Summary Card
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 100),
                    child: _buildHealthSummaryCard(profile, formattedBmi, bmiStatus, textDark, textMuted, borderGray),
                  ),
                  const SizedBox(height: 20),

                  // 3. Target Nutrisi Harian Card
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildDailyTargetsCard(profile, primaryGreen, textDark, borderGray),
                  ),
                  const SizedBox(height: 20),

                  // Meal Plan Aktif Card
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 250),
                    child: _buildActiveMealPlanCard(primaryGreen, textDark, textMuted, borderGray),
                  ),
                  const SizedBox(height: 20),

                  // 4. Data Kesehatan Card
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 300),
                    child: _buildHealthDataCard(profile, textDark, textMuted, borderGray),
                  ),
                  const SizedBox(height: 20),

                  // 5. Progress Bulan Ini Card (Statis - Dummy)
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 400),
                    child: _buildMonthlyProgressCard(profile, primaryGreen, textDark, textMuted, borderGray),
                  ),
                  const SizedBox(height: 24),

                  // 6. Akun Section
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 500),
                    child: _buildAccountSection(primaryGreen, textDark, textMuted, borderGray),
                  ),
                  const SizedBox(height: 20),

                  // 7. Dukungan Section
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 600),
                    child: _buildSupportSection(primaryGreen, textDark, textMuted, borderGray),
                  ),
                  const SizedBox(height: 32),

                  // 8. Logout Button
                  FadeInSlideUp(
                    delay: const Duration(milliseconds: 700),
                    child: _buildLogoutButton(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserProfile profile, Color primaryGreen, Color textDark, Color textMuted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profil',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: primaryGreen,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              // Avatar with fallback to name initials
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
                      ? Image.network(
                          profile.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildInitialsAvatar(profile.name);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF14B8A6)));
                          },
                        )
                      : _buildInitialsAvatar(profile.name),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                profile.name.isNotEmpty ? profile.name : 'HealthPlate User',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email,
                style: TextStyle(
                  fontSize: 13,
                  color: textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 140,
                height: 38,
                child: OutlinedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilScreen(),
                      ),
                    );
                    _fetchProfileData();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryGreen,
                    side: BorderSide(color: primaryGreen, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Edit Profil',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInitialsAvatar(String name) {
    return Container(
      color: const Color(0xFFE6F4F1),
      alignment: Alignment.center,
      child: Text(
        _getInitials(name),
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Color(0xFF095D40),
        ),
      ),
    );
  }

  Widget _buildHealthSummaryCard(UserProfile profile, double bmi, String bmiStatus, Color textDark, Color textMuted, Color borderGray) {
    Color badgeColor = const Color(0xFF10B981); // Emerald Green for Normal
    switch (bmiStatus) {
      case 'Kurus':
        badgeColor = const Color(0xFFFBBF24); // Amber
        break;
      case 'Normal':
      case 'Ideal':
        badgeColor = const Color(0xFF10B981); // Emerald
        break;
      case 'Overweight':
        badgeColor = const Color(0xFFEF4444); // Red
        break;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGray, width: 1.2),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF095D40),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BMI', style: TextStyle(fontSize: 11, color: textMuted)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '$bmi',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            bmiStatus,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Berat Saat Ini', style: TextStyle(fontSize: 11, color: textMuted)),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.weightKg} kg',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Target Kalori Harian', style: TextStyle(fontSize: 11, color: textMuted)),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.caloriesKcal} kcal',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 20),
          Divider(height: 1, color: borderGray),
          const SizedBox(height: 16),
          _buildBmiIndicator(bmi),
        ],
      ),
    );
  }

  Widget _buildBmiIndicator(double bmi) {
    double minBmi = 15.0;
    double maxBmi = 35.0;
    double relativePos = (bmi - minBmi) / (maxBmi - minBmi);
    relativePos = relativePos.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kurus', style: TextStyle(fontSize: 11, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
            Text('Ideal', style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
            Text('Overweight', style: TextStyle(fontSize: 11, color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            double leftOffset = relativePos * constraints.maxWidth;
            leftOffset = leftOffset.clamp(4.0, constraints.maxWidth - 12.0);
            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Gradient range slider background
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFBBF24), // Yellow-orange for Kurus
                        Color(0xFF34D399), // Green for Ideal
                        Color(0xFFF87171), // Red for Overweight
                      ],
                      stops: [0.25, 0.5, 0.8],
                    ),
                  ),
                ),
                // Floating Indicator Pointer
                Positioned(
                  left: leftOffset - 4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF095D40),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDailyTargetsCard(UserProfile profile, Color primaryGreen, Color textDark, Color borderGray) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGray, width: 1.2),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Target Nutrisi Harian',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF095D40),
            ),
          ),
          const SizedBox(height: 20),
          _buildNutrientRow(Icons.local_fire_department_outlined, const Color(0xFFEF4444), 'Kalori', '${profile.caloriesKcal} kcal'),
          Divider(height: 24, color: borderGray),
          _buildNutrientRow(Icons.fitness_center_outlined, primaryGreen, 'Protein', '${profile.proteinG} g'),
          Divider(height: 24, color: borderGray),
          _buildNutrientRow(Icons.bakery_dining_outlined, const Color(0xFFF97316), 'Karbohidrat', '${profile.carbohydrateG} g'),
          Divider(height: 24, color: borderGray),
          _buildNutrientRow(Icons.opacity, const Color(0xFF0284C7), 'Lemak', '${profile.fatG} g'),
          Divider(height: 24, color: borderGray),
          _buildNutrientRow(Icons.cookie_outlined, const Color(0xFFD97706), 'Gula', '${profile.sugarG} g'),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(IconData icon, Color color, String name, String target) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        Text(
          target,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthDataCard(UserProfile profile, Color textDark, Color textMuted, Color borderGray) {
    final genderText = profile.gender == 'Male' ? 'Pria' : (profile.gender == 'Female' ? 'Wanita' : '-');
    final ageText = _getAge(profile.birthDate);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGray, width: 1.2),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Kesehatan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF095D40),
            ),
          ),
          const SizedBox(height: 16),
          _buildHealthDataRow('Jenis Kelamin', genderText, textDark, textMuted),
          Divider(height: 20, color: borderGray),
          _buildHealthDataRow('Usia', '$ageText Tahun', textDark, textMuted),
          Divider(height: 20, color: borderGray),
          _buildHealthDataRow('Tinggi Badan', '${profile.heightCm} cm', textDark, textMuted),
          Divider(height: 20, color: borderGray),
          _buildHealthDataRow('Berat Badan', '${profile.weightKg} kg', textDark, textMuted),
        ],
      ),
    );
  }

  Widget _buildHealthDataRow(String label, String value, Color textDark, Color textMuted) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: textMuted, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 14, color: textDark, fontWeight: FontWeight.bold)),
      ],
    );
  }
  Widget _buildMonthlyProgressCard(UserProfile profile, Color primaryGreen, Color textDark, Color textMuted, Color borderGray) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGray, width: 1.2),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Bulan Ini',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF095D40),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Icon(Icons.analytics_outlined, color: textMuted.withOpacity(0.5), size: 36),
                  const SizedBox(height: 12),
                  Text(
                    'Data akan tersedia setelah penggunaan rutin.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(Color primaryGreen, Color textDark, Color textMuted, Color borderGray) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 12),
          child: Text(
            'AKUN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderGray, width: 1.2),
          ),
          child: Column(
            children: [
              _buildListTile(Icons.person_outline, primaryGreen, 'Informasi Akun', textDark, borderGray, true),
              _buildListTile(Icons.notifications_none, primaryGreen, 'Notifikasi', textDark, borderGray, true),
              _buildListTile(Icons.security_outlined, primaryGreen, 'Privasi & Keamanan', textDark, borderGray, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(Color primaryGreen, Color textDark, Color textMuted, Color borderGray) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 12),
          child: Text(
            'DUKUNGAN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderGray, width: 1.2),
          ),
          child: Column(
            children: [
              _buildListTile(Icons.help_outline, primaryGreen, 'Bantuan', textDark, borderGray, true),
              _buildListTile(Icons.info_outline, primaryGreen, 'Tentang Aplikasi', textDark, borderGray, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(
    IconData icon,
    Color iconColor,
    String title,
    Color textDark,
    Color borderGray,
    bool showDivider,
  ) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor, size: 22),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 20),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Simulasi membuka menu: $title'),
                duration: const Duration(milliseconds: 500),
              ),
            );
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Divider(height: 1, color: borderGray),
          ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2), // soft light red background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2), // light red border
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: _showLogoutConfirmation,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_outlined, color: Colors.redAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveMealPlanCard(Color primaryGreen, Color textDark, Color textMuted, Color borderGray) {
    final activePlan = _activeMealPlan;
    
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
            children: [
              const Icon(Icons.restaurant, color: Color(0xFF14B8A6), size: 20),
              const SizedBox(width: 8),
              Text(
                'Meal Plan Aktif',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (activePlan != null) ...[
            Text(
              activePlan.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.track_changes, size: 14, color: Color(0xFF2563EB)),
                      const SizedBox(width: 6),
                      Text(
                        activePlan.nutritionFocus,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Color(0xFF16A34A)),
                      const SizedBox(width: 6),
                      Text(
                        '${activePlan.durationDays} Hari',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              activePlan.description,
              style: TextStyle(
                fontSize: 13,
                color: textMuted,
                height: 1.4,
              ),
            ),
          ] else ...[
            Text(
              'Belum Ada Meal Plan Aktif',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Silakan pilih paket meal plan di tab Meal Plan untuk menyinkronkan target menu harian Anda.',
              style: TextStyle(
                fontSize: 12,
                color: textMuted,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Staggered Fade In + Slide Up Custom Animator
class FadeInSlideUp extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const FadeInSlideUp({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<FadeInSlideUp> createState() => _FadeInSlideUpState();
}

class _FadeInSlideUpState extends State<FadeInSlideUp> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
