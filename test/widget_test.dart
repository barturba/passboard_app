// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class PasswordBoardApp extends StatelessWidget {
  const PasswordBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Password Board',
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(title: Text('Password Board')),
        ),
        body: Center(child: Text('Welcome to Password Board')),
        floatingActionButton: FloatingActionButton(onPressed: null, child: const Icon(Icons.add)),
      ),
    );
  }
}

void main() {
  testWidgets('Password Board app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PasswordBoardApp());

    // Verify that our app shows the dashboard
    expect(find.text('Password Board'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
