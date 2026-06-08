import 'package:flutter/material.dart';
import '../models/meal_plan.dart';

class PilihPaketMealPlanScreen extends StatelessWidget {
  final MealFocus focus;

  const PilihPaketMealPlanScreen({
    super.key,
    required this.focus,
  });

  void _showActivationDialog(BuildContext context, MealPackage package) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Aktifkan',
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
                Icon(Icons.check_circle_outline, color: Color(0xFF095D40)),
                SizedBox(width: 8),
                Text(
                  'Aktifkan Meal Plan?',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${package.caloriesKcal} kcal',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF14B8A6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 8),
                  const Text(
                    'RINGKASAN MENU:',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDialogMenuRow('Sarapan', package.breakfastMenu),
                  const SizedBox(height: 6),
                  _buildDialogMenuRow('Siang', package.lunchMenu),
                  const SizedBox(height: 6),
                  _buildDialogMenuRow('Malam', package.dinnerMenu),
                  const SizedBox(height: 6),
                  _buildDialogMenuRow('Snack', package.snackMenu),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // pop dialog
                  Navigator.pop(context, package); // return chosen package
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF095D40),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Gunakan Paket'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogMenuRow(String category, String menuName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            category.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF14B8A6),
            ),
          ),
        ),
        Expanded(
          child: Text(
            menuName,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF095D40);
    const Color accentTeal = Color(0xFF14B8A6);
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);
    const Color borderGray = Color(0xFFE2E8F0);

    // Filter packages matching the focus id
    final filteredPackages = dummyMealPackages.where((p) => p.focusId == focus.id).toList();

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
          'Pilih Paket Meal Plan',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                const Text(
                  'Pilih paket yang paling sesuai dengan preferensi Anda untuk memulai perjalanan kesehatan Anda hari ini.',
                  style: TextStyle(
                    fontSize: 14,
                    color: textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // List of filtered packages
                Column(
                  children: filteredPackages.map((package) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: _buildPackageCard(context, package, primaryGreen, accentTeal, borderGray, textDark, textMuted),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),

                // Education Card "Nutrisi Terkalibrasi"
                _buildEducationCard(borderGray, textDark, textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    MealPackage package,
    Color primaryGreen,
    Color accentTeal,
    Color borderGray,
    Color textDark,
    Color textMuted,
  ) {
    // If it is popular or recommended, we give it a more highlighted visual border
    final bool highlighted = package.isPopular || package.isRecommended;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: highlighted ? primaryGreen : borderGray,
          width: highlighted ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row of Package Card
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F4F1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: Color(0xFF095D40),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),

                // Middle Text & Badge Stack
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              package.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                          ),
                          if (package.isPopular)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'POPULER',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF065F46),
                                ),
                              ),
                            ),
                          if (package.isRecommended)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '⭐ RECOMMENDED',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.bolt, size: 14, color: Color(0xFF14B8A6)),
                          const SizedBox(width: 2),
                          Text(
                            '${package.caloriesKcal} kcal',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF14B8A6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu breakdown (staggered list in card)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMenuRow('Sarapan', package.breakfastMenu),
                  const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  _buildMenuRow('Siang', package.lunchMenu),
                  const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  _buildMenuRow('Malam', package.dinnerMenu),
                  const Divider(height: 16, color: Color(0xFFE2E8F0)),
                  _buildMenuRow('Snack', package.snackMenu),
                ],
              ),
            ),
          ),

          // Select Package button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => _showActivationDialog(context, package),
                style: ElevatedButton.styleFrom(
                  backgroundColor: highlighted ? primaryGreen : Colors.white,
                  foregroundColor: highlighted ? Colors.white : primaryGreen,
                  elevation: 0,
                  side: BorderSide(color: primaryGreen, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Pilih Paket',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow(String time, String menu) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            time.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Text(
            menu,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEducationCard(Color borderGray, Color textDark, Color textMuted) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGray, width: 1.2),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrisi Terkalibrasi',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF095D40),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Semua paket makanan kami telah dihitung secara presisi oleh ahli gizi untuk memastikan Anda mendapatkan nutrisi seimbang setiap hari.',
            style: TextStyle(
              fontSize: 12,
              color: textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: double.infinity,
              height: 150,
              child: Image.asset(
                'assets/images/nutrition_placeholder.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: const Icon(Icons.dining_outlined, color: Colors.teal, size: 50),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
