import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MovementChart extends StatelessWidget {
  const MovementChart({
    required this.values,
    super.key,
  });

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: [
            for (final entry in values.indexed)
              BarChartGroupData(
                x: entry.$1,
                barRods: [
                  BarChartRodData(
                    toY: entry.$2,
                    borderRadius: BorderRadius.circular(4),
                    width: 18,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
