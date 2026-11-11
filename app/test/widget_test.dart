import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeetyeet/main.dart';

void main() {
  testWidgets('first-run screen invites the user to connect an account', (
    tester,
  ) async {
    await tester.pumpWidget(const SkeetYeetApp());

    expect(find.text('Connect a Bluesky account'), findsOneWidget);
    expect(find.textContaining('not affiliated with Bluesky'), findsOneWidget);

    await tester.tap(find.text('Connect a Bluesky account'));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
