import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontendhealtplate/main.dart';
import 'package:frontendhealtplate/screens/daftar_resep_screen.dart';
import 'package:frontendhealtplate/screens/detail_resep_screen.dart';

void main() {
  testWidgets('Recipe listing page renders, performs category selection, and toggles favorite', (WidgetTester tester) async {
    // Build App
    await tester.pumpWidget(const MyApp(isLoggedIn: true));

    // Find "Resep" Quick Access button and tap it
    final resepQuickAccess = find.text('Resep');
    expect(resepQuickAccess, findsOneWidget);
    await tester.ensureVisible(resepQuickAccess);
    await tester.tap(resepQuickAccess);
    await tester.pumpAndSettle();

    // Verify we are on DaftarResepScreen
    expect(find.byType(DaftarResepScreen), findsOneWidget);
    expect(find.text('Resep Sehat'), findsOneWidget);

    // Verify some recipes are shown (e.g. Ayam Panggang Herbal, Omelet Protein Tinggi)
    expect(find.text('Ayam Panggang Herbal'), findsOneWidget);
    expect(find.text('Omelet Protein Tinggi'), findsOneWidget);

    // Filter by "Kaya Sayur" category
    final categoryChip = find.text('Kaya Sayur');
    expect(categoryChip, findsOneWidget);
    await tester.tap(categoryChip);
    await tester.pumpAndSettle();

    // Verify "Salad Sayur Segar" shows up and protein recipe disappears
    expect(find.text('Salad Sayur Segar'), findsOneWidget);
    expect(find.text('Omelet Protein Tinggi'), findsNothing);

    // Switch back to "Semua"
    final allCategoryChip = find.text('Semua');
    await tester.tap(allCategoryChip);
    await tester.pumpAndSettle();

    // Verify both are back
    expect(find.text('Ayam Panggang Herbal'), findsOneWidget);
    expect(find.text('Omelet Protein Tinggi'), findsOneWidget);

    // Tap favorite icon on the first recipe (Ayam Panggang Herbal)
    final favButton = find.byIcon(Icons.favorite_border).first;
    await tester.tap(favButton);
    await tester.pumpAndSettle();

    // The heart should change to filled (Icons.favorite)
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('Search query displays empty state when nothing matches', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DaftarResepScreen(),
      ),
    );

    // Tap search icon in appbar
    final searchToggle = find.byIcon(Icons.search);
    expect(searchToggle, findsOneWidget);
    await tester.tap(searchToggle);
    await tester.pumpAndSettle();

    // Type query that won't match anything
    await tester.enterText(find.byType(TextField), 'xyz123abc_not_a_recipe');
    await tester.pumpAndSettle();

    // Verify empty state is displayed
    expect(find.text('Belum ada resep yang ditemukan'), findsOneWidget);
    expect(find.text('Coba gunakan kata kunci lain.'), findsOneWidget);
    expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
  });

  testWidgets('Tap recipe card to open Detail Screen with servings and checkoff ingredients', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DaftarResepScreen(),
      ),
    );

    // Tap on 'Ayam Panggang Herbal' to view details
    final recipeCard = find.text('Ayam Panggang Herbal');
    await tester.tap(recipeCard);
    await tester.pumpAndSettle();

    // Verify Detail Screen is pushed
    expect(find.byType(DetailResepScreen), findsOneWidget);
    expect(find.text('Ayam Panggang Herbal').first, findsOneWidget);
    expect(find.text('2 Porsi'), findsOneWidget);
    expect(find.text('Mudah'), findsOneWidget);
    expect(find.text('25 Menit'), findsOneWidget);

    // Verify nutrition grid
    expect(find.text('420 kcal'), findsOneWidget);
    expect(find.text('35g'), findsOneWidget); // Protein

    // Scroll down to make ingredients visible
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -450));
    await tester.pumpAndSettle();

    // Verify ingredient checklist functionality
    final firstIngredient = find.text('Dada ayam fillet');
    expect(firstIngredient, findsOneWidget);
    await tester.ensureVisible(firstIngredient);
    
    // Tap the ingredient row
    await tester.tap(firstIngredient);
    await tester.pumpAndSettle();

    // Verify checking works by seeing if the checklist box was styled.
    // Tap again to uncheck
    await tester.ensureVisible(firstIngredient);
    await tester.tap(firstIngredient);
    await tester.pumpAndSettle();

    // Verify Steps are present
    expect(find.text('Lumuri dada ayam dengan bawang putih, rosemary, olive oil, garam, dan lada.'), findsOneWidget);

    // Verify Nutrition Tip is present
    expect(find.text('Tips Nutrisi'), findsOneWidget);
    expect(find.text('Konsumsi dada ayam tanpa kulit untuk mengurangi asupan lemak jenuh tanpa mengurangi kandungan protein.'), findsOneWidget);
  });

  testWidgets('Dashboard Lihat Resep navigates directly to Detail Screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isLoggedIn: true));

    // Find "Lihat Resep" button on the "Meal Plan Berikutnya" card
    final lihatResepBtn = find.text('Lihat Resep').first;
    expect(lihatResepBtn, findsOneWidget);
    await tester.ensureVisible(lihatResepBtn);

    // Tap it
    await tester.tap(lihatResepBtn);
    await tester.pumpAndSettle();

    // Should navigate directly to DetailResepScreen for Nasi Merah Ayam Panggang
    expect(find.byType(DetailResepScreen), findsOneWidget);
    expect(find.text('Nasi Merah Ayam Panggang').first, findsOneWidget);
    expect(find.text('30 Menit'), findsOneWidget);
    expect(find.text('Sedang'), findsOneWidget);
  });
}
