import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalsSetupScreen extends StatefulWidget {
  const GoalsSetupScreen({super.key});

  @override
  State<GoalsSetupScreen> createState() => _GoalsSetupScreenState();
}

class _GoalsSetupScreenState extends State<GoalsSetupScreen> {
  // Store selected goal keys
  final Set<String> _selectedGoals = {'pola_makan'}; // Default selected as in screenshot

  // List of goals with their corresponding Material Icons
  final List<Map<String, dynamic>> _goals = [
    {
      'key': 'pola_makan',
      'title': 'Menjaga Pola Makan',
      'icon': Icons.flatware, // Premium cutlery icon
    },
    {
      'key': 'turun_bb',
      'title': 'Menurunkan Berat Badan',
      'icon': Icons.trending_down, // Trend down graph
    },
    {
      'key': 'naik_bb',
      'title': 'Menambah Berat Badan',
      'icon': Icons.trending_up, // Trend up graph
    },
    {
      'key': 'gula_darah',
      'title': 'Mengontrol Gula Darah',
      'icon': Icons.water_drop_outlined, // Blood sugar/droplet icon
    },
    {
      'key': 'hidup_sehat',
      'title': 'Hidup Lebih Sehat',
      'icon': Icons.eco_outlined, // Leaf/eco icon
    },
  ];

  // Method to toggle selection
  void _toggleGoal(String key) {
    setState(() {
      if (_selectedGoals.contains(key)) {
        // Prevent empty selection if you want at least one selected,
        // or allow it. Let's allow toggling.
        _selectedGoals.remove(key);
      } else {
        _selectedGoals.add(key);
      }
    });
  }

  // Complete onboarding flow and navigate to Home Screen
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Langkah 3 dari 3', // Changed from Step 2 of 2 to Langkah 3 dari 3 for consistency
          style: TextStyle(
            color: primaryGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Tujuan & Kesehatan',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen, // Colored dark green title as in design
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              // Subtitle
              const Text(
                'Sesuaikan pengalaman HealthPlate dengan kebutuhan Anda.',
                style: TextStyle(
                  fontSize: 15,
                  color: textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Section Header
              const Text(
                'Tujuan Penggunaan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 16),

              // Goals List Card list
              Expanded(
                child: ListView.separated(
                  itemCount: _goals.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
                    final String key = goal['key'];
                    final String title = goal['title'];
                    final IconData icon = goal['icon'];
                    final bool isSelected = _selectedGoals.contains(key);

                    return GestureDetector(
                      onTap: () => _toggleGoal(key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? primaryGreen : borderGray,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Icon circular background
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? accentTeal.withValues(alpha: 0.1) // Teal background when selected
                                    : const Color(0xFFF1F5F9), // Slate background when not selected
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icon,
                                color: isSelected ? primaryGreen : textMuted,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Text Title
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? primaryGreen : textDark,
                                ),
                              ),
                            ),
                            // Checkmark Icon on the right
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: primaryGreen,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // "Mulai Menggunakan HealthPlate" Button (Forest Green)
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
                    onPressed: _completeOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen, // Dark Green
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
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
