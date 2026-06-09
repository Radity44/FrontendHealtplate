import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';
import '../models/auth_response.dart';

class AuthRepository {
  final AuthService _authService;
  final SessionManager _sessionManager;

  AuthRepository({
    AuthService? authService,
    SessionManager? sessionManager,
  })  : _authService = authService ?? AuthService(),
        _sessionManager = sessionManager ?? SessionManager();

  Future<AuthResponse> register({
    required String email,
    required String password,
  }) async {
    final response = await _authService.register(
      email: email,
      password: password,
      name: 'HealthPlate User',
    );

    if (response.success && response.data?.session?.accessToken != null) {
      final token = response.data!.session!.accessToken;
      await _sessionManager.saveToken(token);
      await _sessionManager.setOnboardingCompleted(false);

      // Save email temporarily for setup screens
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('temp_email', email);
    }

    return response;
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _authService.login(
      email: email,
      password: password,
    );

    if (response.success && response.data?.session?.accessToken != null) {
      final token = response.data!.session!.accessToken;
      await _sessionManager.saveToken(token);
      await _sessionManager.setOnboardingCompleted(true);

      // Save email for profile display fallback
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_email', email);
    }

    return response;
  }

  Future<void> logout() async {
    final token = await _sessionManager.getToken();
    try {
      if (token != null && token.isNotEmpty) {
        await _authService.logout(token: token);
      }
    } finally {
      // Local session is always cleared even if API request fails (hybrid/safe logout)
      await _sessionManager.clearToken();
    }
  }

  Future<bool> hasSession() async {
    return _sessionManager.hasToken();
  }

  Future<String?> getAccessToken() async {
    return _sessionManager.getToken();
  }

  Future<bool> isOnboardingCompleted() async {
    return _sessionManager.isOnboardingCompleted();
  }
}
