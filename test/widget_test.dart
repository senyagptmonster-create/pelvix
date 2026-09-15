import 'package:flutter_test/flutter_test.dart';
import 'package:pelvix/pelvix_app.dart';

void main() {
  testWidgets('PelvixCoreApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PelvixCoreApp());
    expect(find.byType(PelvixCoreApp), findsOneWidget);
  });
}