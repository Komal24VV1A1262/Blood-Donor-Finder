import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blood_donor_finder/main.dart';
import 'package:blood_donor_finder/widgets/donor_card.dart';

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

  testWidgets('Creating a profile updates the Donor List instantly', (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('My Profile'));
    await tester.pumpAndSettle();

    expect(find.text('No profile yet'), findsOneWidget);

    await tester.tap(find.text('Create Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Create Profile'), findsWidgets);

    await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
    await tester.enterText(find.widgetWithText(TextFormField, 'City'), 'Karachi');
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone'), '03099999999');

    await tester.tap(find.text('Blood Group'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('B+').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tap to select a date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('B+'), findsWidgets);

    await tester.tap(find.text('Find Donors'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Test User');
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(DonorCard), matching: find.text('Test User')),
      findsOneWidget,
    );
    expect(find.text('Karachi'), findsOneWidget);
  });

  testWidgets('Creating a profile validates required fields', (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('My Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('City is required'), findsOneWidget);
    expect(find.text('Enter a valid phone number (at least 10 digits)'), findsOneWidget);
  });
}