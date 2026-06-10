import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontendhealtplate/models/auth_response.dart';
import 'package:frontendhealtplate/services/auth_service.dart';
import 'package:frontendhealtplate/services/session_manager.dart';
import 'package:frontendhealtplate/repositories/auth_repository.dart';

// Lightweight pure Dart MockClient implementation for test isolation
class MockClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest request) mockHandler;

  MockClient(this.mockHandler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await mockHandler(request);
    final responseBytes = response.bodyBytes;
    return http.StreamedResponse(
      Stream.value(responseBytes),
      response.statusCode,
      contentLength: responseBytes.length,
      headers: response.headers,
      request: request,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthResponse Model Tests', () {
    test('Should parse successful register/login response correctly', () {
      const jsonString = '''
      {
        "success": true,
        "message": "Registrasi berhasil",
        "data": {
          "user": {
            "id": "user-123",
            "email": "user@example.com"
          },
          "session": {
            "access_token": "token-xyz-123",
            "expires_in": 3600
          }
        }
      }
      ''';

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final response = AuthResponse.fromJson(jsonMap);

      expect(response.success, isTrue);
      expect(response.message, equals('Registrasi berhasil'));
      expect(response.data, isNotNull);
      expect(response.data!.user, isNotNull);
      expect(response.data!.user!.id, equals('user-123'));
      expect(response.data!.user!.email, equals('user@example.com'));
      expect(response.data!.session, isNotNull);
      expect(response.data!.session!.accessToken, equals('token-xyz-123'));
      expect(response.data!.session!.expiresIn, equals(3600));
    });

    test('Should parse error response gracefully', () {
      const jsonString = '''
      {
        "success": false,
        "message": "Email sudah terdaftar",
        "data": null
      }
      ''';

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final response = AuthResponse.fromJson(jsonMap);

      expect(response.success, isFalse);
      expect(response.message, equals('Email sudah terdaftar'));
      expect(response.data, isNull);
    });
  });

  group('AuthService API Endpoint Tests', () {
    test('register success returns AuthResponse', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/auth/register'));
        expect(request.method, equals('POST'));
        
        final body = jsonDecode((request as http.Request).body);
        expect(body['email'], equals('register@example.com'));
        expect(body['password'], equals('password123'));
        expect(body['name'], equals('HealthPlate User'));

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Registrasi berhasil',
            'data': {
              'user': {'id': '1', 'email': 'register@example.com'},
              'session': {'access_token': 'test-access-token-123'}
            }
          }),
          200,
        );
      });

      final authService = AuthService(client: mockClient);
      final response = await authService.register(
        email: 'register@example.com',
        password: 'password123',
        name: 'HealthPlate User',
      );

      expect(response.success, isTrue);
      expect(response.data?.session?.accessToken, equals('test-access-token-123'));
    });

    test('login success returns AuthResponse', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/auth/login'));
        expect(request.method, equals('POST'));

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Login berhasil',
            'data': {
              'user': {'id': '2', 'email': 'login@example.com'},
              'session': {'access_token': 'login-access-token-999'}
            }
          }),
          200,
        );
      });

      final authService = AuthService(client: mockClient);
      final response = await authService.login(
        email: 'login@example.com',
        password: 'password123',
      );

      expect(response.success, isTrue);
      expect(response.data?.session?.accessToken, equals('login-access-token-999'));
    });

    test('HTTP 401 error throws friendly exception message', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Email atau password salah'
          }),
          401,
        );
      });

      final authService = AuthService(client: mockClient);
      expect(
        () => authService.login(email: 'wrong@example.com', password: '123'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Email atau password salah'))),
      );
    });

    test('HTTP 422 error throws validation error message', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Email tidak valid'
          }),
          422,
        );
      });

      final authService = AuthService(client: mockClient);
      expect(
        () => authService.register(email: 'invalid-email', password: '123', name: 'Name'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Email tidak valid'))),
      );
    });

    test('HTTP 500 error throws server internal error message', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final authService = AuthService(client: mockClient);
      expect(
        () => authService.login(email: 'test@example.com', password: '123'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Terjadi kesalahan internal pada server (500).'))),
      );
    });
  });

  group('AuthRepository Integration Tests', () {
    late SessionManager sessionManager;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      sessionManager = SessionManager();
    });

    test('register success stores token and sets onboarding as false', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Registrasi berhasil',
            'data': {
              'user': {'id': '1', 'email': 'register@example.com'},
              'session': {'access_token': 'reg-token-abc'}
            }
          }),
          200,
        );
      });

      final authService = AuthService(client: mockClient);
      final repository = AuthRepository(
        authService: authService,
        sessionManager: sessionManager,
      );

      final response = await repository.register(
        email: 'register@example.com',
        password: 'password123',
      );

      expect(response.success, isTrue);
      expect(await sessionManager.getToken(), equals('reg-token-abc'));
      expect(await sessionManager.isOnboardingCompleted(), isFalse);
    });

    test('login success stores token and sets onboarding as true', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Login berhasil',
            'data': {
              'user': {'id': '1', 'email': 'login@example.com'},
              'session': {'access_token': 'login-token-xyz'}
            }
          }),
          200,
        );
      });

      final authService = AuthService(client: mockClient);
      final repository = AuthRepository(
        authService: authService,
        sessionManager: sessionManager,
      );

      final response = await repository.login(
        email: 'login@example.com',
        password: 'password123',
      );

      expect(response.success, isTrue);
      expect(await sessionManager.getToken(), equals('login-token-xyz'));
      expect(await sessionManager.isOnboardingCompleted(), isTrue);
    });

    test('logout clears local token even if API logout fails', () async {
      final mockClient = MockClient((request) async {
        expect(request.headers['Authorization'], equals('Bearer my-active-token'));
        return http.Response('Internal Server Error', 500); // Server fails
      });

      // Seed the session manager with pre-existing token and onboarding status
      await sessionManager.saveToken('my-active-token');
      await sessionManager.setOnboardingCompleted(true);

      final authService = AuthService(client: mockClient);
      final repository = AuthRepository(
        authService: authService,
        sessionManager: sessionManager,
      );

      // Call logout, catching expected throw
      try {
        await repository.logout();
      } catch (_) {}

      // Regardless of failure, token should be cleared locally (safe/hybrid logout)
      expect(await sessionManager.hasToken(), isFalse);
      expect(await sessionManager.isOnboardingCompleted(), isTrue);
    });
  });
}
