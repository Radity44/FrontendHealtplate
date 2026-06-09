import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontendhealtplate/models/user_profile.dart';
import 'package:frontendhealtplate/services/profile_service.dart';
import 'package:frontendhealtplate/services/session_manager.dart';
import 'package:frontendhealtplate/repositories/profile_repository.dart';

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

  group('UserProfile Model Tests', () {
    test('Should parse UserProfile from snake_case backend response correctly', () {
      const jsonString = '''
      {
        "user_id": "uuid-12345",
        "name": "Raditya Fansa",
        "email": "raditya@example.com",
        "gender": "Male",
        "birth_date": "2003-05-15",
        "height_cm": 172,
        "weight_kg": 68,
        "avatar_url": "https://supabase.co/storage/v1/avatar.jpg",
        "calories_kcal": 2200,
        "protein_g": 85,
        "carbohydrate_g": 280,
        "fat_g": 75,
        "sugar_g": 45
      }
      ''';

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final profile = UserProfile.fromJson(jsonMap);

      expect(profile.id, equals('uuid-12345'));
      expect(profile.name, equals('Raditya Fansa'));
      expect(profile.email, equals('raditya@example.com'));
      expect(profile.gender, equals('Male'));
      expect(profile.birthDate, equals('2003-05-15'));
      expect(profile.heightCm, equals(172));
      expect(profile.weightKg, equals(68));
      expect(profile.avatarUrl, equals('https://supabase.co/storage/v1/avatar.jpg'));
      expect(profile.caloriesKcal, equals(2200));
      expect(profile.proteinG, equals(85));
      expect(profile.carbohydrateG, equals(280));
      expect(profile.fatG, equals(75));
      expect(profile.sugarG, equals(45));
    });

    test('Should handle null/missing values gracefully', () {
      const jsonString = '{}';
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final profile = UserProfile.fromJson(jsonMap);

      expect(profile.id, isEmpty);
      expect(profile.name, isEmpty);
      expect(profile.avatarUrl, isNull);
      expect(profile.heightCm, equals(0));
    });
  });

  group('ProfileService API Tests', () {
    test('fetchProfile success returns UserProfile', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/auth/me'));
        expect(request.method, equals('GET'));
        expect(request.headers['Authorization'], equals('Bearer my-token-123'));

        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'user_id': 'uuid-123',
              'name': 'Test User',
              'email': 'test@example.com',
              'gender': 'Female',
              'birth_date': '1995-10-10',
              'height_cm': 165,
              'weight_kg': 55,
              'calories_kcal': 1800
            }
          }),
          200,
        );
      });

      final service = ProfileService(client: mockClient);
      final profile = await service.fetchProfile('my-token-123');

      expect(profile.name, equals('Test User'));
      expect(profile.gender, equals('Female'));
      expect(profile.caloriesKcal, equals(1800));
    });

    test('updateProfile success returns UserProfile', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/auth/me'));
        expect(request.method, equals('PUT'));
        
        final payload = jsonDecode((request as http.Request).body);
        expect(payload['weight_kg'], equals(72));

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Profile updated',
            'data': {
              'user_id': 'uuid-123',
              'weight_kg': 72
            }
          }),
          200,
        );
      });

      final service = ProfileService(client: mockClient);
      final profile = await service.updateProfile('my-token-123', {'weight_kg': 72});

      expect(profile.weightKg, equals(72));
    });

    test('uploadAvatar success returns new avatar url', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, endsWith('/upload/avatar'));
        expect(request.method, equals('POST'));
        expect(request.headers['Authorization'], equals('Bearer my-token-123'));

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Avatar uploaded',
            'data': {
              'avatar_url': 'https://supabase.co/avatar-uploaded.jpg'
            }
          }),
          200,
        );
      });

      final service = ProfileService(client: mockClient);
      final avatarUrl = await service.uploadAvatar('my-token-123', [1, 2, 3], 'photo.png');

      expect(avatarUrl, equals('https://supabase.co/avatar-uploaded.jpg'));
    });

    test('HTTP 500 throws friendly server error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = ProfileService(client: mockClient);
      expect(
        () => service.fetchProfile('token'),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Terjadi kesalahan internal pada server (500).'))),
      );
    });
  });

  group('ProfileRepository Integration Tests', () {
    late SessionManager sessionManager;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      sessionManager = SessionManager();
    });

    test('getProfile gets token from session manager and calls service', () async {
      await sessionManager.saveToken('repository-token');

      final mockClient = MockClient((request) async {
        expect(request.headers['Authorization'], equals('Bearer repository-token'));
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {'user_id': 'user-123', 'name': 'Repo User'}
          }),
          200,
        );
      });

      final service = ProfileService(client: mockClient);
      final repo = ProfileRepository(profileService: service, sessionManager: sessionManager);

      final profile = await repo.getProfile();
      expect(profile.name, equals('Repo User'));
    });

    test('getProfile throws exception if token is empty', () async {
      final mockClient = MockClient((request) async {
        return http.Response('', 200);
      });

      final service = ProfileService(client: mockClient);
      final repo = ProfileRepository(profileService: service, sessionManager: sessionManager);

      expect(
        () => repo.getProfile(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Sesi telah berakhir'))),
      );
    });
  });
}
