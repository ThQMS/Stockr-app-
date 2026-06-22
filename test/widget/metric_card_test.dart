import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockr_app/features/reports/presentation/widgets/metric_card.dart';

void main() {
  testWidgets('MetricCard renders its label, value and icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetricCard(
            label: 'Total products',
            value: '128',
            icon: Icons.inventory_2_outlined,
          ),
        ),
      ),
    );

    expect(find.text('Total products'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
    expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
  });
}
