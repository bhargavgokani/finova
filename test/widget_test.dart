import 'package:flutter_test/flutter_test.dart';

import 'package:finova/main.dart';

void main() {
  testWidgets('App launches and shows the splash page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FinovaApp());
    await tester.pumpAndSettle();

    expect(find.text('Splash'), findsWidgets);
  });
}
