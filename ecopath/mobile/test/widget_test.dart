import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecopath/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build a minimal environment around EcoPathRoot.
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const EcoPathRoot(),
      ),
    );

    // Give it one frame to build.
    await tester.pump();

    // If we got here, it built without immediately throwing.
    expect(find.byType(MaterialApp), findsWidgets);
  });
}
