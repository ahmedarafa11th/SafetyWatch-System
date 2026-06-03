import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:safteywatch/main.dart';

void main() {
  testWidgets('SafetyWatch app loads correctly', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(SafetyWatchApp());

    // تأكد إن عنوان التطبيق موجود
    expect(find.text('SafetyWatch'), findsWidgets);

    // تأكد إن شاشة اللوجين ظهرت (لو فيها text ده)
    expect(find.byType(TextField), findsWidgets);
  });
}
