import 'package:flutter_test/flutter_test.dart';
import 'package:jobinja_app/main.dart';

void main() {
  testWidgets('App loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const JobinjaApp());
    expect(find.text('ورود به جابینجا'), findsOneWidget);
  });
}
