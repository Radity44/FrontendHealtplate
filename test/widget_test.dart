import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontendhealtplate/main.dart';
import 'package:frontendhealtplate/screens/welcome_screen.dart';
import 'package:frontendhealtplate/screens/home_screen.dart';
import 'package:frontendhealtplate/screens/profile_pic_setup_screen.dart';
import 'package:frontendhealtplate/screens/personal_data_setup_screen.dart';
import 'package:frontendhealtplate/repositories/profile_repository.dart';

void main() {
  ProfileRepository.useMockDataForTests = true;
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

    // Tap "Buat Meal Plan" to transition to Pilih Fokus Nutrisi screen.
    final makePlanBtn = find.text('Buat Meal Plan');
    await tester.ensureVisible(makePlanBtn);
    await tester.tap(makePlanBtn);
    await tester.pumpAndSettle();

    // Verify we navigated to Pilih Fokus Nutrisi screen.
    expect(find.text('Pilih Fokus Nutrisi'), findsOneWidget);
    expect(find.text('Kaya Protein'), findsOneWidget);

    // Tap "Lanjutkan" button.
    final continueBtn = find.text('Lanjutkan');
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    // Verify we navigated to Pilih Paket Meal Plan screen.
    expect(find.text('Pilih Paket Meal Plan'), findsOneWidget);
    expect(find.text('Kaya Protein Ayam A'), findsOneWidget);

    // Tap "Pilih Paket" on the first package (Kaya Protein Ayam A).
    final choosePackageBtn = find.text('Pilih Paket').first;
    await tester.tap(choosePackageBtn);
    await tester.pumpAndSettle();

    // Verify confirmation dialog shows.
    expect(find.text('Aktifkan Meal Plan?'), findsOneWidget);
    expect(find.text('Gunakan Paket'), findsOneWidget);

    // Tap "Gunakan Paket" in the dialog.
    final usePlanBtn = find.text('Gunakan Paket');
    await tester.tap(usePlanBtn);
    await tester.pumpAndSettle();

    // Verify active plan is displayed.
    expect(find.text('Kaya Protein Ayam A'), findsOneWidget);
    expect(find.text('Jadwal Hari Ini'), findsOneWidget);
    expect(find.text('Telur Rebus + Oatmeal'), findsOneWidget);
  });

  testWidgets('Log Harian navigation, toggle empty state, and bottom sheet manual input works', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isLoggedIn: true));

    // Tap on Log Harian bottom navigation item.
    final logHarianTab = find.text('Log Harian').last;
    await tester.tap(logHarianTab);
    await tester.pumpAndSettle();

    // Verify it is on the Log Harian screen
    expect(find.text('Log Harian').first, findsOneWidget);

    // By default, the simulation is on Filled State (Nasi Goreng Spesial exists).
    expect(find.text('Nasi Goreng Spesial'), findsOneWidget);
    expect(find.text('Teh Manis'), findsOneWidget);

    // Toggle simulation switch to change to Empty State.
    final toggleSwitch = find.byType(Switch);
    expect(toggleSwitch, findsOneWidget);
    await tester.tap(toggleSwitch);
    await tester.pumpAndSettle();

    // Now it should show Empty State ("Belum ada konsumsi tercatat").
    expect(find.text('Belum ada konsumsi tercatat').first, findsOneWidget);

    // Tap "+ Tambah Konsumsi" button.
    final addBtn = find.text('Tambah Konsumsi').first;
    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    // Verify Bottom Sheet is shown.
    expect(find.text('Pilih metode pencatatan konsumsi'), findsOneWidget);
    expect(find.text('Input Manual'), findsOneWidget);
    expect(find.text('Scan Barcode'), findsOneWidget);

    // Tap "Input Manual".
    final manualInput = find.text('Input Manual');
    await tester.tap(manualInput);
    await tester.pumpAndSettle();

    // Verify we are on Tambah Konsumsi Manual Screen.
    expect(find.text('Nama Konsumsi'), findsOneWidget);
    expect(find.text('Simpan ke Log Harian'), findsOneWidget);
  });

  testWidgets('Riwayat tab navigation, period filter switching, and detail view navigation works', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isLoggedIn: true));

    // Tap on Riwayat bottom navigation item.
    final riwayatTab = find.text('Riwayat').last;
    await tester.tap(riwayatTab);
    await tester.pumpAndSettle();

    // Verify it is on the Riwayat screen
    expect(find.text('Riwayat').first, findsOneWidget);
    expect(find.text('Ringkasan Nutrisi'), findsOneWidget);
    expect(find.text('1850 kcal'), findsOneWidget); // 7-day average calories
    expect(find.text('Hari Konsisten'), findsOneWidget);

    // Tap "30 Hari" segmented filter
    final tab30Days = find.text('30 Hari');
    await tester.tap(tab30Days);
    await tester.pumpAndSettle();

    // Verify average calories updated to 30-day average dummy data (1910 kcal)
    expect(find.text('1910 kcal'), findsOneWidget);

    // Tap "7 Hari" filter to go back
    final tab7Days = find.text('7 Hari');
    await tester.tap(tab7Days);
    await tester.pumpAndSettle();

    // Scroll to find "Lihat Detail" button on the daily history list
    final detailBtn = find.text('Lihat Detail').first;
    await tester.ensureVisible(detailBtn);
    await tester.tap(detailBtn);
    await tester.pumpAndSettle();

    // Verify we navigated to DetailRiwayatScreen
    expect(find.text('Detail Riwayat Harian'), findsOneWidget);
    expect(find.text('Total Konsumsi Kalori'), findsOneWidget);
    expect(find.text('Rincian Konsumsi'), findsOneWidget);
    expect(find.text('Oatmeal Pisang'), findsOneWidget);

    // Press back button to return to Riwayat tab
    final backBtn = find.byIcon(Icons.arrow_back);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Back to Riwayat screen
    expect(find.text('Riwayat').first, findsOneWidget);
  });

  testWidgets('Redesigned Profile tab renders correctly, navigates to Edit Profil, and triggers Logout confirmation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isLoggedIn: true));

    // Tap on the Profil tab
    final profilTab = find.text('Profil').last;
    await tester.tap(profilTab);
    await tester.pumpAndSettle();

    // Verify header profile info is shown
    expect(find.text('Ridho Rizky'), findsOneWidget);
    expect(find.text('ridho@email.com'), findsOneWidget);

    // Verify newly added sections are rendered
    expect(find.text('Health Summary'), findsOneWidget);
    expect(find.text('BMI'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('70 kg'), findsAtLeast(1));

    expect(find.text('Target Nutrisi Harian'), findsOneWidget);
    expect(find.text('Progress Bulan Ini'), findsOneWidget);
    expect(find.text('24 Hari'), findsOneWidget);

    // Tap on "Edit Profil" button
    final editProfilBtn = find.text('Edit Profil');
    await tester.tap(editProfilBtn);
    await tester.pumpAndSettle();

    // Verify we are on Edit Profil screen
    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.text('Informasi Dasar'), findsOneWidget);

    // Tap on "Simpan Perubahan"
    final saveBtn = find.text('Simpan Perubahan');
    await tester.ensureVisible(saveBtn);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // Verify we are back on Profile tab (Edit Profil popped)
    expect(find.text('Health Summary'), findsOneWidget);

    // Scroll down to find and tap "Keluar" button
    final logoutBtn = find.text('Keluar');
    await tester.ensureVisible(logoutBtn);
    await tester.tap(logoutBtn);
    await tester.pumpAndSettle();

    // Verify confirmation dialog shows
    expect(find.text('Keluar dari akun?'), findsOneWidget);
    expect(find.text('Apakah Anda yakin ingin keluar dari akun Anda?'), findsOneWidget);

    // Tap "Batalkan"
    final cancelBtn = find.text('Batalkan');
    await tester.tap(cancelBtn);
    await tester.pumpAndSettle();

    // Verify dialog closed and we are still on the profile screen
    expect(find.text('Health Summary'), findsOneWidget);
  });
}
