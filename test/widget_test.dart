// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stark_payments/main.dart';

void main() {
  testWidgets('CFO Tracker smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CFOTrackerApp());

    // Verify that the App Bar title "CFO TRACKER" is present.
    expect(find.text('CFO TRACKER'), findsOneWidget);
    
    // Verify that the refresh button is present in the AppBar.
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
  });
}
