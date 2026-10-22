import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cableTvBook/widgets/app_logo.dart';
import 'package:cableTvBook/theme/app_theme.dart';
import 'package:cableTvBook/theme/responsive.dart';

void main() {
  testWidgets('AppLogo renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLogo(size: 64),
        ),
      ),
    );

    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('ResponsiveContainer constraints maxWidth',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: ResponsiveContainer(
            maxWidth: 500,
            child: Text('Content'),
          ),
        ),
      ),
    );

    expect(find.text('Content'), findsOneWidget);
    final constrainedBox = tester.widget<ConstrainedBox>(
      find.descendant(
        of: find.byType(ResponsiveContainer),
        matching: find.byType(ConstrainedBox),
      ),
    );
    expect(constrainedBox.constraints.maxWidth, 500);
  });
}
