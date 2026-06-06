import 'package:flutter/material.dart';

class ProfilePicSetupScreen extends StatefulWidget {
  const ProfilePicSetupScreen({super.key});

  @override
  State<ProfilePicSetupScreen> createState() => _ProfilePicSetupScreenState();
}

class _ProfilePicSetupScreenState extends State<ProfilePicSetupScreen> {
  // Mock profile picture state - can be updated when they click an option
  bool _hasCustomImage = false;

  // Method to show the Bottom Sheet
  void _showImagePickerBottomSheet(BuildContext context) {
    const Color textDark = Color(0xFF1E293B);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top drag handle
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                    margin: const EdgeInsets.only(top: 10, bottom: 20),
                  ),
                ),
                // Title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Pilih Foto Profil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Option: Ambil Foto
                _buildBottomSheetItem(
                  context: context,
                  icon: Icons.camera_alt_outlined,
                  title: 'Ambil Foto',
                  onTap: () {
                    Navigator.pop(context);
                    _showActionSnackbar(context, 'Membuka Kamera (Simulasi)');
                  },
                ),
                // Option: Pilih dari Galeri
                _buildBottomSheetItem(
                  context: context,
                  icon: Icons.image_outlined,
                  title: 'Pilih dari Galeri',
                  onTap: () {
                    Navigator.pop(context);
                    _showActionSnackbar(context, 'Membuka Galeri (Simulasi)');
                  },
                ),
                // Option: Pilih Avatar
                _buildBottomSheetItem(
                  context: context,
                  icon: Icons.face_outlined,
                  title: 'Pilih Avatar',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _hasCustomImage = true; // Simulating selecting an avatar
                    });
                    _showActionSnackbar(context, 'Avatar Terpilih (Simulasi)');
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: Color(0xFFE2E8F0), thickness: 1, indent: 24, endIndent: 24),
                ),
                // Cancel Button
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 48),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF14B8A6), size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF095D40),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Method to navigate to Step 2
  void _navigateToNextStep() {
    Navigator.pushNamed(context, '/personal-data-setup');
  }

  @override
  Widget build(BuildContext context) {
    const Color textDark = Color(0xFF1E293B);
    const Color textMuted = Color(0xFF64748B);
    const Color accentTeal = Color(0xFF14B8A6);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF095D40)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Langkah 1 dari 3',
          style: TextStyle(
            color: Color(0xFF095D40), // Green title matching Step 2 style
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false, // Left-aligned step title
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Left aligned title & subtitle
            children: [
              const SizedBox(height: 20),
              // Left-aligned Title
              const Text(
                'Tambahkan Foto Profil',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              // Left-aligned Subtitle
              const Text(
                'Tambahkan foto profil atau lewati untuk sekarang.',
                style: TextStyle(
                  fontSize: 15,
                  color: textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),

              // Avatar Stack with Camera Overlay Button
              Center(
                child: Stack(
                  children: [
                    // Profile Picture container with Shadow & White Border
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _hasCustomImage
                            ? Container(
                                color: const Color(0xFFCCFBF1), // Simulated Avatar background
                                child: const Icon(
                                  Icons.face_outlined,
                                  size: 100,
                                  color: Color(0xFF095D40),
                                ),
                              )
                            : Container(
                                color: const Color(0xFFF1F5F9), // Placeholder background
                                child: const Icon(
                                  Icons.person,
                                  size: 110,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                      ),
                    ),
                    // Floating Camera Action Button
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _showImagePickerBottomSheet(context),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: accentTeal,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: accentTeal.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Skip for Now link
              Center(
                child: GestureDetector(
                  onTap: _navigateToNextStep,
                  child: const Text(
                    'Lewati untuk Sekarang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textMuted,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // Continue Button
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
                    onPressed: _navigateToNextStep,
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
                      'Lanjutkan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
