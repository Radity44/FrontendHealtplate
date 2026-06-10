import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_snackbar.dart';

class SessionManager {
  static const String _keyToken = 'access_token';
  static const String _keyOnboarding = 'onboarding_completed';

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static bool _isRedirecting = false;

  static Future<void> handleSessionExpired() async {
    if (_isRedirecting) return;
    _isRedirecting = true;

    final context = navigatorKey.currentContext;

    final manager = SessionManager();
    await manager.clearToken();

    Future.delayed(const Duration(seconds: 2), () {
      _isRedirecting = false;
    });

    if (context != null && context.mounted) {
      AppSnackbar.showSessionExpired(context);
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  Future<void> clearOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboarding);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarding) ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarding, completed);
  }
}

