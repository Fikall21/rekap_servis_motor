import 'package:flutter_test/flutter_test.dart';
import 'package:rekap_servis_motor/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isLoggedIn: false));
  });
}