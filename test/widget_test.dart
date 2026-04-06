import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';

void main() {
  testWidgets('Shows login screen on app start', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Đăng nhập'), findsWidgets);
    expect(find.text('Chưa có tài khoản? Đăng ký'), findsOneWidget);
  });
}
