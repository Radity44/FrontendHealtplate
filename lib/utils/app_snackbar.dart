import 'package:flutter/material.dart';

/// Centralized SnackBar helper for HealthPlate.
///
/// All auth-related banners (login error, register error, session expired,
/// network error) are routed through this helper to guarantee a consistent,
/// premium floating card appearance across the entire app.
abstract class AppSnackbar {
  // ── Design tokens ────────────────────────────────────────────────────────────
  static const _errorBg = Color(0xFFB91C1C);      // rich red
  static const _successBg = Color(0xFF047857);    // emerald green (on-brand)
  static const _warningBg = Color(0xFFB45309);    // amber-brown
  static const _defaultRadius = 14.0;
  static const _horizontalMargin = 16.0;
  static const _bottomMargin = 28.0;

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Shows a red error banner with a warning icon.
  ///
  /// [message] — primary message (required).
  /// [subtitle] — optional second line (e.g. "Silakan periksa kembali dan coba lagi.").
  static void showError(
    BuildContext context,
    String message, {
    String? subtitle,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      icon: Icons.error_outline_rounded,
      message: message,
      subtitle: subtitle,
      backgroundColor: _errorBg,
      duration: duration,
    );
  }

  /// Shows a green success banner with a checkmark icon.
  static void showSuccess(
    BuildContext context,
    String message, {
    String? subtitle,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      icon: Icons.check_circle_outline_rounded,
      message: message,
      subtitle: subtitle,
      backgroundColor: _successBg,
      duration: duration,
    );
  }

  /// Shows an amber session-expired banner.
  ///
  /// Typically called by [SessionManager.handleSessionExpired].
  static void showSessionExpired(
    BuildContext context, {
    String message = 'Sesi login Anda telah berakhir.',
    String subtitle = 'Silakan masuk kembali.',
  }) {
    _show(
      context,
      icon: Icons.lock_clock_outlined,
      message: message,
      subtitle: subtitle,
      backgroundColor: _warningBg,
      duration: const Duration(seconds: 4),
    );
  }

  // ── Internal builder ─────────────────────────────────────────────────────────

  static void _show(
    BuildContext context, {
    required IconData icon,
    required String message,
    required Color backgroundColor,
    String? subtitle,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Dismiss any currently visible SnackBar first to avoid stacking.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // ── Behaviour ───────────────────────────────────────────────────────
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(
          _horizontalMargin,
          0,
          _horizontalMargin,
          _bottomMargin,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_defaultRadius),
        ),
        // ── Visuals ─────────────────────────────────────────────────────────
        backgroundColor: backgroundColor,
        elevation: 8,
        duration: duration,
        // ── Content ─────────────────────────────────────────────────────────
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
