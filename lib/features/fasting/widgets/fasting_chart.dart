import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/fasting_record.dart';

class FastingChart extends StatelessWidget {
  final List<FastingRecord> records;

  const FastingChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text("Belum ada data statistik"),
      );
    }

    // Sort records by date
    final sortedRecords = List<FastingRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // Take last 7 days or less
    final data = sortedRecords.length > 7 
        ? sortedRecords.sublist(sortedRecords.length - 7)
        : sortedRecords;

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 18,
          left: 12,
          top: 24,
          bottom: 12,
        ),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(
              show: true,
              drawVerticalLine: true,
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < data.length) {
                      final date = data[index].date;
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          "${date.day}/${date.month}",
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 42,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color(0xff37434d)),
            ),
            minX: 0,
            maxX: (data.length - 1).toDouble(),
            minY: 0,
            maxY: 24,
            lineBarsData: [
              LineChartBarData(
                spots: data.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value.fastingHours.toDouble());
                }).toList(),
                isCurved: true,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF23b6e6),
                    Color(0xFF02d39a),
                  ],
                ),
                barWidth: 5,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF23b6e6).withValues(alpha: 0.3),
                      const Color(0xFF02d39a).withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
