import '../services/profile_service.dart';
import '../services/session_manager.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  // Static flag to enable mock data for widget/integration testing without making real HTTP calls
  static bool useMockDataForTests = false;

  final ProfileService _profileService;
  final SessionManager _sessionManager;

  ProfileRepository({
    ProfileService? profileService,
    SessionManager? sessionManager,
  })  : _profileService = profileService ?? ProfileService(),
        _sessionManager = sessionManager ?? SessionManager();

  Future<UserProfile> getProfile() async {
    if (useMockDataForTests) {
      return UserProfile(
        id: 'mock-id',
        name: 'Ridho Rizky',
        email: 'ridho@email.com',
        gender: 'Male',
        birthDate: '1998-06-01',
        heightCm: 175,
        weightKg: 70,
        avatarUrl: null,
        caloriesKcal: 2000,
        proteinG: 75,
        carbohydrateG: 250,
        fatG: 60,
        sugarG: 30,
      );
    }

    final token = await _sessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesi telah berakhir. Silakan masuk kembali.');
    }
    return _profileService.fetchProfile(token);
  }

  Future<UserProfile> updateProfile(Map<String, dynamic> data) async {
    if (useMockDataForTests) {
      return UserProfile(
        id: 'mock-id',
        name: data['name'] ?? 'Ridho Rizky',
        email: 'ridho@email.com',
        gender: data['gender'] ?? 'Male',
        birthDate: data['birth_date'] ?? '1998-06-01',
        heightCm: data['height_cm'] ?? 175,
        weightKg: data['weight_kg'] ?? 70,
        avatarUrl: null,
        caloriesKcal: data['calories_kcal'] ?? 2000,
        proteinG: data['protein_g'] ?? 75,
        carbohydrateG: data['carbohydrate_g'] ?? 250,
        fatG: data['fat_g'] ?? 60,
        sugarG: data['sugar_g'] ?? 30,
      );
    }

    final token = await _sessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesi telah berakhir. Silakan masuk kembali.');
    }
    return _profileService.updateProfile(token, data);
  }

  Future<String> uploadAvatar(List<int> imageBytes, String filename) async {
    if (useMockDataForTests) {
      return 'https://supabase.co/mock-avatar.jpg';
    }

    final token = await _sessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesi telah berakhir. Silakan masuk kembali.');
    }
    return _profileService.uploadAvatar(token, imageBytes, filename);
  }
}
