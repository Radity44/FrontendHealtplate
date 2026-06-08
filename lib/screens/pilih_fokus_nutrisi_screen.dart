import 'package:flutter/material.dart';
import '../models/meal_plan.dart';
import 'pilih_paket_meal_plan_screen.dart';

class PilihFokusNutrisiScreen extends StatefulWidget {
  const PilihFokusNutrisiScreen({super.key});

  @override
  State<PilihFokusNutrisiScreen> createState() => _PilihFokusNutrisiScreenState();
}

class _PilihFokusNutrisiScreenState extends State<PilihFokusNutrisiScreen> {
  // Default selection is 'protein'
  String _selectedFocusId = 'protein';

  @override
  Widget build(BuildContext context) {
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
          'Pilih Fokus Nutrisi',
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
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      const Text(
                        'Pilih kategori meal plan yang sesuai dengan tujuan nutrisi Anda.',
                        style: TextStyle(
                          fontSize: 14,
                          color: textMuted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Focus List
                      Column(
                        children: dummyMealFocuses.map((focus) {
                          final isSelected = _selectedFocusId == focus.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildFocusCard(focus, isSelected, accentTeal, borderGray, textDark, textMuted),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Nourishing Growth info card
                      _buildNourishingGrowthCard(borderGray, textDark, textMuted),
                    ],
                  ),
                ),
              ),
            ),

            // Lanjutkan Button Area
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    // Find the selected focus model
                    final selectedFocus = dummyMealFocuses.firstWhere((f) => f.id == _selectedFocusId);
                    
                    // Navigate to package selector and await result
                    final selectedPackage = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PilihPaketMealPlanScreen(focus: selectedFocus),
                      ),
                    );

                    if (!context.mounted) return;
                    if (selectedPackage != null) {
                      Navigator.pop(context, selectedPackage);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lanjutkan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusCard(
    MealFocus focus,
    bool isSelected,
    Color accentTeal,
    Color borderGray,
    Color textDark,
    Color textMuted,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFocusId = focus.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected ? accentTeal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentTeal : borderGray,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentTeal.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.01),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          children: [
            // Left Emoji circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                focus.icon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(width: 16),

            // Content column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    focus.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    focus.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white.withValues(alpha: 0.9) : textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNourishingGrowthCard(Color borderGray, Color textDark, Color textMuted) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGray, width: 1.2),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Circular Food Plate Image
          ClipOval(
            child: SizedBox(
              width: 100,
              height: 100,
              child: Image.asset(
                'assets/images/meal_focus_placeholder.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.white,
                    child: const Icon(Icons.restaurant, color: Colors.teal, size: 40),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nourishing Growth',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tujuan pilihanmu akan menyesuaikan rekomendasi menu harian secara otomatis agar target kesehatan tercapai lebih cepat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
