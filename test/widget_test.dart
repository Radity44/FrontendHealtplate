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
    expect(find.text('Halo, Ridho'), findsOneWidget);
    expect(find.text('Target Harian'), findsOneWidget);
    expect(find.text('2000 kcal'), findsOneWidget);
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

  testWidgets('Home Screen navigation to Meal Plan tab works and toggles active state', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isLoggedIn: true));

    // Initially, we are on Dashboard (Home).
    expect(find.text('Halo, Ridho'), findsOneWidget);

    // Tap on the Meal Plan bottom navigation item.
    final mealPlanTab = find.text('Meal Plan').last;
    await tester.tap(mealPlanTab);
    await tester.pumpAndSettle();

    // Verify empty state is displayed first.
    expect(find.text('Belum Ada Meal Plan Aktif'), findsOneWidget);

    // Tap "Buat Meal Plan" to transition to active state.
    final makePlanBtn = find.text('Buat Meal Plan');
    await tester.ensureVisible(makePlanBtn);
    await tester.tap(makePlanBtn);
    await tester.pumpAndSettle();

    // Verify active plan is displayed.
    expect(find.text('Kaya Protein Ayam A'), findsOneWidget);
    expect(find.text('Jadwal Hari Ini'), findsOneWidget);
    expect(find.text('Telur Rebus Oatmeal'), findsOneWidget);
  });
}
