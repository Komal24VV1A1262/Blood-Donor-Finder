import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blood_donor_finder/main.dart';

void main() {
  testWidgets('App shows login screen when not authenticated', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(child: BloodDonorFinderApp()));
    await tester.pumpAndSettle();
    expect(find.text('Blood Donor Finder'), findsWidgets);
    expect(find.text('Sign In'), findsOneWidget);
  });
}