import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontendhealtplate/main.dart';
import 'package:frontendhealtplate/screens/welcome_screen.dart';
import 'package:frontendhealtplate/screens/home_screen.dart';
import 'package:frontendhealtplate/screens/profile_pic_setup_screen.dart';
import 'package:frontendhealtplate/screens/personal_data_setup_screen.dart';

void main() {
  testWidgets('Welcome Screen shows when not logged in', (WidgetTester tester) async {
    // Build our app with isLoggedIn: false.
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Verify that WelcomeScreen is displayed.
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('HealthPlate'), findsOneWidget);
    expect(find.text('Pantau Nutrisi Harian dengan Mudah'), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('Home Screen shows when already logged in', (WidgetTester tester) async {
    // Build our app with isLoggedIn: true.
    await tester.pumpWidget(const MyApp(isLoggedIn: true));

    // Verify that HomeScreen is displayed instead of WelcomeScreen.
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Halo, Pengguna!'), findsOneWidget);
    expect(find.text('HealthPlate'), findsOneWidget);
  });

  testWidgets('Profile Picture Setup Screen renders correctly', (WidgetTester tester) async {
    // Build ProfilePicSetupScreen directly inside a MaterialApp.
    await tester.pumpWidget(
      const MaterialApp(
        home: ProfilePicSetupScreen(),
      ),
    );

    // Verify that main UI elements exist.
    expect(find.text('Langkah 1 dari 3'), findsOneWidget);
    expect(find.text('Tambahkan Foto Profil'), findsOneWidget);
    expect(find.text('Lewati untuk Sekarang'), findsOneWidget);
    expect(find.text('Lanjutkan'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });

  testWidgets('Personal Data Setup Screen renders correctly', (WidgetTester tester) async {
    // Build PersonalDataSetupScreen directly inside a MaterialApp.
    await tester.pumpWidget(
      const MaterialApp(
        home: PersonalDataSetupScreen(),
      ),
    );

    // Verify that main UI elements exist.
    expect(find.text('Langkah 2 dari 3'), findsOneWidget);
    expect(find.text('Lengkapi Data Diri'), findsOneWidget);
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Jenis Kelamin'), findsOneWidget);
    expect(find.text('Tanggal Lahir'), findsOneWidget);
    expect(find.text('Tinggi Badan'), findsOneWidget);
    expect(find.text('Berat Badan'), findsOneWidget);
    expect(find.text('Lanjutkan'), findsOneWidget);
    expect(find.text('Pria'), findsOneWidget);
    expect(find.text('Wanita'), findsOneWidget);
  });
}
