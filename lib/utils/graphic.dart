import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphWidget extends StatefulWidget {
  @override
  _GraphWidgetState createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  late List<double> data;

  @override
  void initState() {
    super.initState();
    var r = Random();
    data = List<double>.generate(30, (i) => r.nextDouble() * 1500);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueAccent,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    'Día ${spot.x.toInt() + 1}\nGasto: \$${spot.y.toStringAsFixed(2)}',
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
            touchCallback: (event, response) {
              if (response != null && response.lineBarSpots != null) {
                final spot = response.lineBarSpots!.first;
                print("Día: ${spot.x.toInt() + 1}, Gasto: ${spot.y}");
              }
            },
          ),
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  final day = value.toInt() + 1;
                  if ([1, 5, 10, 15, 20, 25, 30].contains(day)) {
                    return Text(day.toString().padLeft(2, '0'));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 500),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(data.length,
                  (i) => FlSpot(i.toDouble(), data[i])),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
