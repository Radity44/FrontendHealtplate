import 'package:flutter/material.dart';

class ScanBarcodeScreen extends StatefulWidget {
  const ScanBarcodeScreen({super.key});

  @override
  State<ScanBarcodeScreen> createState() => _ScanBarcodeScreenState();
}

class _ScanBarcodeScreenState extends State<ScanBarcodeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 260.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _mulaiScan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Colors.white),
            SizedBox(width: 8),
            Text('Memindai barcode produk... (Simulasi)'),
          ],
        ),
        backgroundColor: Color(0xFF095D40),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color accentTeal = Color(0xFF14B8A6);

    return Scaffold(
      backgroundColor: Colors.black, // Dark cinematic theme for scanning
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan Barcode Produk',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Animated Scanner Box
              Center(
                child: Stack(
                  children: [
                    // Viewfinder Border Outline
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    
                    // Top Left Corner
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: accentTeal, width: 4),
                            left: BorderSide(color: accentTeal, width: 4),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                          ),
                        ),
                      ),
                    ),
                    
                    // Top Right Corner
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: accentTeal, width: 4),
                            right: BorderSide(color: accentTeal, width: 4),
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(24),
                          ),
                        ),
                      ),
                    ),
                    
                    // Bottom Left Corner
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: accentTeal, width: 4),
                            left: BorderSide(color: accentTeal, width: 4),
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                          ),
                        ),
                      ),
                    ),
                    
                    // Bottom Right Corner
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: accentTeal, width: 4),
                            right: BorderSide(color: accentTeal, width: 4),
                          ),
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                      ),
                    ),

                    // Inside Barcode simulation graphic
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.qr_code_2_outlined,
                          size: 140,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                    ),

                    // Animated Laser line
                    AnimatedBuilder(
                      animation: _scanLineAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: 10 + _scanLineAnimation.value,
                          left: 10,
                          right: 10,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: accentTeal,
                              boxShadow: [
                                BoxShadow(
                                  color: accentTeal.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Title Instruction
              const Text(
                'Scan Barcode Produk',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Description Instruction
              const Text(
                'Arahkan kamera ke barcode makanan atau minuman kemasan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              
              const Spacer(),

              // Mulai Scan button
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
                    onPressed: _mulaiScan,
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
                      'Mulai Scan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
