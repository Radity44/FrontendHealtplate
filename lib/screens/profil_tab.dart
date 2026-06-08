import 'package:flutter/material.dart';
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
  // Static dummy data for the user profile
  final String _name = 'Ridho Rizky';
  final String _email = 'ridho@email.com';
  final String _gender = 'Pria';
  final int _age = 28;
  final int _height = 175;
  final int _weight = 70;
  final double _bmi = 22.9;
  final String _bmiStatus = 'Normal';
  
  // Daily target nutrients
  final int _targetCalories = 2000;
  final int _targetProtein = 75;
  final int _targetCarbs = 250;
  final int _targetFat = 60;
  final int _targetSugar = 30;

  // Monthly stats
  final int _consistentDays = 24;
  final int _achievementPercentage = 92;
  final int _avgCalories = 1850;

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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header (Title, Profile avatar, edit button)
                _buildHeader(primaryGreen, textDark, textMuted),
                const SizedBox(height: 24),

                // 2. Health Summary Card (NEW)
                FadeInSlideUp(
                  delay: const Duration(milliseconds: 100),
                  child: _buildHealthSummaryCard(textDark, textMuted, borderGray),
                ),
                const SizedBox(height: 20),

                // 3. Target Nutrisi Harian Card (NEW)
                FadeInSlideUp(
                  delay: const Duration(milliseconds: 200),
                  child: _buildDailyTargetsCard(primaryGreen, textDark, borderGray),
                ),
                const SizedBox(height: 20),

                // 4. Data Kesehatan Card
                FadeInSlideUp(
                  delay: const Duration(milliseconds: 300),
                  child: _buildHealthDataCard(textDark, textMuted, borderGray),
                ),
                const SizedBox(height: 20),

                // 5. Progress Bulan Ini Card (NEW)
                FadeInSlideUp(
                  delay: const Duration(milliseconds: 400),
                  child: _buildMonthlyProgressCard(primaryGreen, textDark, textMuted, borderGray),
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
    );
  }

  Widget _buildHeader(Color primaryGreen, Color textDark, Color textMuted) {
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
              // Avatar with camera/pencil overlay
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/avatar_ridho.png'),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF095D40),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _email,
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilScreen(),
                      ),
                    );
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

  Widget _buildHealthSummaryCard(Color textDark, Color textMuted, Color borderGray) {
    Color badgeColor = const Color(0xFF10B981); // Emerald Green for Normal
    switch (_bmiStatus) {
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
          // 2x2 Grid using columns/rows
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
                          '$_bmi',
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
                            _bmiStatus,
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
                      '$_weight kg',
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
                      '$_targetCalories kcal',
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
          _buildBmiIndicator(),
        ],
      ),
    );
  }

  Widget _buildBmiIndicator() {
    double minBmi = 15.0;
    double maxBmi = 35.0;
    double relativePos = (_bmi - minBmi) / (maxBmi - minBmi);
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

  Widget _buildDailyTargetsCard(Color primaryGreen, Color textDark, Color borderGray) {
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
          _buildNutrientRow(Icons.local_fire_department_outlined, const Color(0xFFEF4444), 'Kalori', '$_targetCalories kcal'),
          Divider(height: 24, color: borderGray),
          _buildNutrientRow(Icons.fitness_center_outlined, primaryGreen, 'Protein', '$_targetProtein g'),
          Divider(height: 24, color: borderGray),
          _buildNutrientRow(Icons.bakery_dining_outlined, const Color(0xFFF97316), 'Karbohidrat', '$_targetCarbs g'),
          Divider(height: 24, color: borderGray),
          _buildNutrientRow(Icons.opacity, const Color(0xFF0284C7), 'Lemak', '$_targetFat g'),
          Divider(height: 24, color: borderGray),
          _buildNutrientRow(Icons.cookie_outlined, const Color(0xFFD97706), 'Gula', '$_targetSugar g'),
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

  Widget _buildHealthDataCard(Color textDark, Color textMuted, Color borderGray) {
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
          _buildHealthDataRow('Jenis Kelamin', _gender, textDark, textMuted),
          Divider(height: 20, color: borderGray),
          _buildHealthDataRow('Usia', '$_age Tahun', textDark, textMuted),
          Divider(height: 20, color: borderGray),
          _buildHealthDataRow('Tinggi Badan', '$_height cm', textDark, textMuted),
          Divider(height: 20, color: borderGray),
          _buildHealthDataRow('Berat Badan', '$_weight kg', textDark, textMuted),
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

  Widget _buildMonthlyProgressCard(Color primaryGreen, Color textDark, Color textMuted, Color borderGray) {
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
          Row(
            children: [
              Expanded(
                child: _buildProgressColumn(
                  Icons.local_fire_department,
                  Colors.orange,
                  'Hari Konsisten',
                  '$_consistentDays Hari',
                  textDark,
                  textMuted,
                ),
              ),
              Container(width: 1, height: 40, color: borderGray),
              Expanded(
                child: _buildProgressColumn(
                  Icons.ads_click,
                  primaryGreen,
                  'Target Tercapai',
                  '$_achievementPercentage%',
                  textDark,
                  textMuted,
                ),
              ),
              Container(width: 1, height: 40, color: borderGray),
              Expanded(
                child: _buildProgressColumn(
                  Icons.insights,
                  Colors.blue,
                  'Rata-rata Kalori',
                  '$_avgCalories kcal',
                  textDark,
                  textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressColumn(
    IconData icon,
    Color iconColor,
    String title,
    String value,
    Color textDark,
    Color textMuted,
  ) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: textMuted, fontWeight: FontWeight.w500),
        ),
      ],
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
}

// Fade In + Slide Up staggered animator kustom
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
