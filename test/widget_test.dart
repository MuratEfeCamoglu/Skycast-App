import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deneme1/main.dart';

void main() {
  testWidgets('Uygulama açılır ve sekmeler arasında gezinilebilir', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // Testlerde ağ istekleri başarısız olur; uygulama örnek veriye düşmeli.
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Bugün'), findsWidgets);

    for (final label in ['Tahmin', 'Konumlar', 'Detaylar']) {
      await tester.tap(find.text(label).last);
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    }

    // flutter_animate gecikme zamanlayıcılarının tamamlanmasını bekle.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
}
