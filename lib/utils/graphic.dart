import 'package:aplicacion_gastos_final/utils/constans.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphWidget extends StatelessWidget {
  final List<double> data;

  const GraphWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appBackgroundColor, // Fondo negro para todo el gráfico
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          backgroundColor: appBackgroundColor, // Fondo negro dentro del gráfico
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: appText.withOpacity(0.2),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    'Día ${spot.x.toInt() + 1}\nGasto: \$${spot.y.toStringAsFixed(2)}',
                    const TextStyle(color: appText),
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
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white24,
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (_) => FlLine(
              color: Colors.white24,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 5,
                getTitlesWidget: (value, meta) {
                  final day = value.toInt() + 1;
                  if ([1, 5, 10, 15, 20, 25, 30].contains(day)) {
                    return Text(
                      day.toString().padLeft(2, '0'),
                      style: const TextStyle(color: appText, fontSize: 12),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 500,
                getTitlesWidget: (value, meta) => Text(
                  "\$${value.toInt()}",
                  style: const TextStyle(color: appText, fontSize: 12),
                ),
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white24),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                data.length,
                (i) => FlSpot(i.toDouble(), data[i]),
              ),
              isCurved: true,
              color: appPrimaryColor,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

