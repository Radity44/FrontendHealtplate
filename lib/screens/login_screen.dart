import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../utils/app_snackbar.dart';
import '../utils/auth_exception.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  /// Inline auth error — displayed below the password field.
  /// Cleared automatically whenever the user edits email or password.
  String? _authError;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-clear inline error as soon as the user starts correcting input.
    _emailController.addListener(_clearAuthError);
    _passwordController.addListener(_clearAuthError);
  }

  void _clearAuthError() {
    if (_authError != null) {
      setState(() => _authError = null);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // ── Form validation (inline error) ───────────────────────────────────────
    if (email.isEmpty) {
      setState(() => _authError = 'Email tidak boleh kosong.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _authError = 'Format email tidak valid.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _authError = 'Kata sandi tidak boleh kosong.');
      return;
    }

    setState(() {
      _isLoading = true;
      _authError = null;
    });

    try {
      final authRepository = AuthRepository();
      final response = await authRepository.login(
        email: email,
        password: password,
      );

      if (response.success) {
        if (mounted) {
          AppSnackbar.showSuccess(context, response.message);
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } else {
        // Unlikely — service should throw on !success, but handle defensively.
        if (mounted) {
          setState(() => _authError = response.message);
        }
      }
    } on AuthException catch (e) {
      // API-level auth error → show inline below the form.
      if (mounted) {
        setState(() => _authError = e.message);
      }
    } catch (e) {
      // Network/timeout/server error → show snackbar (global error).
      if (mounted) {
        final msg = e.toString()
            .replaceAll('HttpException: ', '')
            .replaceAll('Exception: ', '');
        AppSnackbar.showError(context, msg);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title ────────────────────────────────────────────────────
                const Text(
                  'Selamat Datang Kembali',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Masuk untuk melanjutkan perjalanan hidup sehat Anda',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Illustration ─────────────────────────────────────────────
                Center(
                  child: Image.asset(
                    'assets/images/image_splash_screen.png',
                    height: 240,
                    width: 240,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Email ─────────────────────────────────────────────────────
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'nama@email.com',
                    hintStyle:
                        const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                    prefixIcon:
                        const Icon(Icons.mail_outline, color: Color(0xFF94A3B8)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                          color: Color(0xFF14B8A6), width: 2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Password ──────────────────────────────────────────────────
                const Text(
                  'Kata Sandi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: '· · · · · · · ·',
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Color(0xFF94A3B8)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF94A3B8),
                      ),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    // Turn border red when there is an inline auth error.
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _authError != null
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFE2E8F0),
                        width: _authError != null ? 1.5 : 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _authError != null
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF14B8A6),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),

                // ── Inline auth error ─────────────────────────────────────────
                if (_authError != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFEF4444),
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _authError!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFFEF4444),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // ── Lupa Kata Sandi ───────────────────────────────────────────
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _isLoading ? null : () {},
                    child: const Text(
                      'Lupa Kata Sandi?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF095D40),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Masuk button ──────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF14B8A6).withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14B8A6),
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
                          : const Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Footer ────────────────────────────────────────────────────
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum memiliki akun? ',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                      ),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () => Navigator.pushNamed(context, '/register'),
                        child: const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF095D40),
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
