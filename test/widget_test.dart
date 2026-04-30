import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bazil_app/main.dart'; // ← Убедитесь, что путь правильный

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    // ← ИСПРАВЛЕНО: BazilApp → MyApp
    await tester.pumpWidget(const MyApp());
    
    expect(find.text('БАЗИЛЬ КАФЕ'), findsOneWidget);
  });
}