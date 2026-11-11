import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blood_donor_finder/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'session_email': 'test@example.com',
    });
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BloodDonorFinderApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('Blood group filter shows only matching donors', (WidgetTester tester) async {
    await pumpApp(tester);

    expect(find.text('Ahmed Khan'), findsOneWidget);
    expect(find.text('Sara Ali'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'O+'));
    await tester.pumpAndSettle();

    expect(find.text('Ahmed Khan'), findsOneWidget);
    expect(find.text('Hassan Raza'), findsOneWidget);
    expect(find.text('Maria Joseph'), findsOneWidget);
    expect(find.text('Sara Ali'), findsNothing);
  });

  testWidgets('Search matches donor name and city instantly', (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'All'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Karachi');
    await tester.pumpAndSettle();

    expect(find.text('Ahmed Khan'), findsOneWidget);
    expect(find.text('Ayesha Malik'), findsOneWidget);
    expect(find.text('Omar Farooq'), findsOneWidget);
    expect(find.text('Sara Ali'), findsNothing);

    await tester.enterText(find.byType(TextField), 'nonexistent');
    await tester.pumpAndSettle();

    expect(find.text('No donors match your search'), findsOneWidget);
  });

  testWidgets('Combined search and blood group filter', (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(FilterChip, 'O+'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Karachi');
    await tester.pumpAndSettle();

    expect(find.text('Ahmed Khan'), findsOneWidget);
    expect(find.text('Hassan Raza'), findsNothing);
    expect(find.text('Maria Joseph'), findsNothing);
  });
}