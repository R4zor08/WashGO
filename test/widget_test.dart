import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:washgo/app.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('Splash screen shows WashGo branding', (WidgetTester tester) async {
    await tester.pumpWidget(const WashGoApp());
    await tester.pump();

    expect(find.text('WashGo'), findsOneWidget);
    expect(find.text('Book. Wash. Go.'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
  });
}
