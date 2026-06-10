/// Custom exception for authentication and API-level errors.
///
/// Unlike [HttpException] from `dart:io`, [AuthException.toString()] returns
/// only the human-readable [message] — no class-name prefix like
/// "HttpException: " is ever prepended. This keeps the UI layer clean and
/// avoids fragile string-stripping workarounds.
///
/// Usage in service layer:
/// ```dart
/// throw AuthException('Email atau kata sandi yang Anda masukkan salah.');
/// ```
///
/// Usage in UI layer:
/// ```dart
/// } on AuthException catch (e) {
///   setState(() => _authError = e.message);
/// }
/// ```
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  /// Returns the bare [message] with no prefix — safe to display directly in UI.
  @override
  String toString() => message;
}
