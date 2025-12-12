// ISN App Widget Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:isn_app/app.dart';

void main() {
  testWidgets('ISN App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: IsnApp()));

    // Verify that the app loads with user selection screen
    expect(find.text('ISN Accessible Bridge'), findsOneWidget);

    // Wait for async data to load
    await tester.pumpAndSettle();

    // Verify demo mode content appears
    expect(find.text('Demo Mode'), findsOneWidget);
  });
}
