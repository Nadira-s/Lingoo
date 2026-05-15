import 'package:business/app/business_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BusinessApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(BusinessApp), findsOneWidget);
  });
}
