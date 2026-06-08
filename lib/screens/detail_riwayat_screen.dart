import 'package:flutter/material.dart';

class DetailRiwayatScreen extends StatelessWidget {
  final String date;
  final int totalCalories;
  final int protein;
  final int carbs;
  final int fat;
  final int sugar;

  const DetailRiwayatScreen({
    super.key,
    required this.date,
    required this.totalCalories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sugar,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF095D40);
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
          'Detail Riwayat Harian',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Summary Card (Date & Calories)
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$totalCalories kcal',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    const Text(
                      'Total Konsumsi Kalori',
                      style: TextStyle(
                        fontSize: 14,
                        color: textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: borderGray),
                    const SizedBox(height: 16),
                    // Nutrient Breakdown Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNutrientStat('Protein', '$protein g', const Color(0xFF095D40)),
                        _buildNutrientStat('Karbohidrat', '$carbs g', const Color(0xFFF97316)),
                        _buildNutrientStat('Lemak', '$fat g', const Color(0xFF0284C7)),
                        _buildNutrientStat('Gula', '$sugar g', const Color(0xFFDC2626)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Meal Log Sections
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rincian Konsumsi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sarapan
                    _buildMealDetailCard(
                      title: 'Sarapan',
                      foodName: 'Oatmeal Pisang',
                      calories: 450,
                      icon: Icons.wb_sunny_outlined,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(height: 12),

                    // Makan Siang
                    _buildMealDetailCard(
                      title: 'Makan Siang',
                      foodName: 'Ayam Panggang Nasi Merah',
                      calories: 650,
                      icon: Icons.restaurant_menu_outlined,
                      iconBg: const Color(0xFFD1FAE5),
                      iconColor: const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 12),

                    // Makan Malam
                    _buildMealDetailCard(
                      title: 'Makan Malam',
                      foodName: 'Sup Ayam Sayuran',
                      calories: 550,
                      icon: Icons.nightlight_round_outlined,
                      iconBg: const Color(0xFFE0E7FF),
                      iconColor: const Color(0xFF6366F1),
                    ),
                    const SizedBox(height: 12),

                    // Snack
                    _buildMealDetailCard(
                      title: 'Snack',
                      foodName: 'Yogurt Rendah Gula',
                      calories: 150,
                      icon: Icons.cookie_outlined,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildMealDetailCard({
    required String title,
    required String foodName,
    required int calories,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);
    const Color borderGray = Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(16),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
              Text(
                '$calories kcal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF095D40),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.flatware, color: textMuted, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  foodName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
