import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_demo/main.dart';

void main() {
  testWidgets('Home screen shows all demo entries', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Home Screen'), findsOneWidget);
    expect(find.text('1. Dart Demo'), findsOneWidget);
    expect(find.text('2. Widgets and layout'), findsOneWidget);
    expect(find.text('3. State management'), findsOneWidget);
    expect(find.text('4. User login'), findsOneWidget);
    expect(find.text('5. SQLite'), findsOneWidget);
    expect(find.text('6. Networking'), findsOneWidget);
  });
}
