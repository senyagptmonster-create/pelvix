import 'package:flutter_test/flutter_test.dart';
import 'package:pelvix/main.dart';

void main() {
  testWidgets('PelvixApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PelvixApp());
    expect(find.text('PELVIX ISOMETRIC CORE'), findsOneWidget);
    expect(find.text('COMMENCE HOLD'), findsOneWidget);
  });
}
