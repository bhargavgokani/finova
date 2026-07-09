import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finova/core/di/injection_container.dart';
import 'package:finova/main.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await setupLocator();
  });

  tearDown(() => locator.reset());

  testWidgets('Splash shows its content, then navigates to Login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FinovaApp());

    expect(find.text('Finova'), findsOneWidget);
    expect(find.text('Personal Finance Manager'), findsOneWidget);
    expect(find.text('Version 1.0.0'), findsOneWidget);

    // Advance past the fade animation and the 2 second navigation delay.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsWidgets);
  });
}
