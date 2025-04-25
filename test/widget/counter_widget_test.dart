import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tp_integration_mpf/main.dart';

void main() {
  testWidgets('Le compteur démarre à 0 et s’incrémente à 1', (WidgetTester tester) async {
    // Démarre l’application
    await tester.pumpWidget(const MyApp());

    // Vérifie que "0" est affiché
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Clique sur le bouton flottant
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    // Vérifie que "1" est maintenant affiché
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
