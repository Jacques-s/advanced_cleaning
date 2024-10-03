import 'dart:math';

import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GeneralLineChart extends StatelessWidget {
  GeneralLineChart({super.key});

  // Generate some dummy data for the cahrt
  // This will be used to draw the red line
  final List<FlSpot> dummyData1 = List.generate(8, (index) {
    return FlSpot(index.toDouble(), index * Random().nextDouble());
  });

  // This will be used to draw the orange line
  final List<FlSpot> dummyData2 = List.generate(8, (index) {
    return FlSpot(index.toDouble(), index * Random().nextDouble());
  });

  // This will be used to draw the blue line
  final List<FlSpot> dummyData3 = List.generate(8, (index) {
    return FlSpot(index.toDouble(), index * Random().nextDouble());
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: appAccentColor,
      child: Padding(
        padding: EdgeInsets.all(Get.width * 0.01),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: Get.width * 0.01),
              child: const Center(
                child: Text(
                  'Chart Title',
                  style: TextStyle(
                      color: appChartHeaderColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: appChartHeaderColor),
                ),
              ),
            ),
            AspectRatio(
              aspectRatio: 2 / 1,
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // The red line
                    LineChartBarData(
                      spots: dummyData1,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.indigo,
                    ),
                    // The orange line
                    LineChartBarData(
                      spots: dummyData2,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.red,
                    ),
                    // The blue line
                    LineChartBarData(
                      spots: dummyData3,
                      isCurved: false,
                      barWidth: 3,
                      color: Colors.blue,
                    )
                  ],
                ),
                duration: const Duration(milliseconds: 250),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
