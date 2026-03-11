import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

class WeeklyProgressChart extends StatefulWidget {
  const WeeklyProgressChart({super.key});

  @override
  State<WeeklyProgressChart> createState() => _WeeklyProgressChartState();
}

class _WeeklyProgressChartState extends State<WeeklyProgressChart> {
  int _selectedMetricIndex = 0; // 0: Berat Badan, 1: Air Minum, 2: Langkah

  final List<String> _metrics = ["Berat Badan", "Air Minum", "Langkah Kaki"];
  
  // Dummy Data for 7 days
  final List<double> _dummyWeightData = [65.0, 64.8, 64.7, 64.5, 64.5, 64.2, 64.0];
  final List<double> _dummyWaterData = [1500, 2000, 1800, 2500, 2200, 2600, 2400];
  final List<double> _dummyStepsData = [4000, 5200, 4800, 8000, 7500, 10000, 9500];
  
  final List<String> _days = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Progres Mingguan",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedMetricIndex,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryDark, size: 20),
                    style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 13),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedMetricIndex = newValue;
                        });
                      }
                    },
                    items: _metrics.asMap().entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: _buildChart(),
          ),
          _buildSummary(),
        ],
      ),
    );
  }

  Widget _buildChart() {
    List<double> currentData;
    Color chartColor;
    String tooltipSuffix;
    double maxY;
    double minY = 0;

    switch (_selectedMetricIndex) {
      case 0:
        currentData = _dummyWeightData;
        chartColor = Colors.green;
        tooltipSuffix = " kg";
        maxY = 70;
        minY = 60; // Just for visual variance
        break;
      case 1:
        currentData = _dummyWaterData;
        chartColor = Colors.blue;
        tooltipSuffix = " ml";
        maxY = 3000;
        break;
      case 2:
      default:
        currentData = _dummyStepsData;
        chartColor = Colors.orange;
        tooltipSuffix = " langkah";
        maxY = 12000;
        break;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: minY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()}$tooltipSuffix',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < _days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _days[value.toInt()],
                      style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide left titles for clean look
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4 > 0 ? (maxY - minY) / 4 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.1),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          currentData.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: currentData[index],
                color: chartColor,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: chartColor.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    String summary = "";
    IconData icon = Icons.info_outline;
    Color color = Colors.grey;

    switch (_selectedMetricIndex) {
      case 0:
        double diff = _dummyWeightData.last - _dummyWeightData.first;
        if (diff < 0) {
          summary = "🎉 Hebat! Berat badan Anda turun ${diff.abs().toStringAsFixed(1)} kg minggu ini.";
          icon = Icons.trending_down;
          color = Colors.green;
        } else if (diff > 0) {
          summary = "Berat badan Anda naik ${diff.abs().toStringAsFixed(1)} kg minggu ini.";
          icon = Icons.trending_up;
          color = Colors.orange;
        } else {
          summary = "Berat badan Anda stabil minggu ini.";
          icon = Icons.trending_flat;
          color = Colors.blue;
        }
        break;
      case 1:
        double avg = _dummyWaterData.reduce((a, b) => a + b) / _dummyWaterData.length;
        summary = "💧 Rata-rata asupan air Anda adalah ${avg.round()} ml/hari.";
        icon = Icons.water_drop;
        color = Colors.blue;
        break;
      case 2:
      default:
        double total = _dummyStepsData.reduce((a, b) => a + b);
        summary = "👟 Anda telah melangkah sebanyak ${total.toInt()} langkah minggu ini!";
        icon = Icons.directions_walk;
        color = Colors.orange;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              summary,
              style: TextStyle(color: color.withOpacity(0.9), fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

