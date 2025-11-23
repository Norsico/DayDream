// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daydream/main.dart';

void main() {
  testWidgets('DayDream app loads with bottom navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('今日'), findsWidgets);
    expect(find.text('往日'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);

    // Switch to 往日 tab
    await tester.tap(find.text('往日'));
    await tester.pumpAndSettle();
    expect(find.text('还没有往日记录'), findsOneWidget);

    // Switch to 设置 tab
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    expect(find.text('关于作者'), findsOneWidget);
  });
}

