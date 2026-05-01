import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tourist_guide/screens/home_screen.dart';

void main() {
  testWidgets('Home screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('Smart Tourism Guide 🇱🇰'), findsOneWidget);
  });
}
