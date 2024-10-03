import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GeneralBarChart extends StatelessWidget {
  const GeneralBarChart({super.key});

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
              aspectRatio: 1.6 / 1,
              child: BarChart(BarChartData(
                  borderData: FlBorderData(
                      border: const Border(
                    top: BorderSide.none,
                    right: BorderSide.none,
                    left: BorderSide(width: 1),
                    bottom: BorderSide(width: 1),
                  )),
                  groupsSpace: 10,
                  barGroups: [
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(
                          fromY: 0, toY: 10, width: 15, color: appPrimaryColor),
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(
                          fromY: 0, toY: 10, width: 15, color: appPrimaryColor),
                    ]),
                    BarChartGroupData(x: 3, barRods: [
                      BarChartRodData(
                          fromY: 0, toY: 15, width: 15, color: appPrimaryColor),
                    ]),
                    BarChartGroupData(x: 4, barRods: [
                      BarChartRodData(
                          fromY: 0, toY: 10, width: 15, color: appPrimaryColor),
                    ]),
                    BarChartGroupData(x: 5, barRods: [
                      BarChartRodData(
                          fromY: 0, toY: 11, width: 15, color: appPrimaryColor),
                    ]),
                    BarChartGroupData(x: 6, barRods: [
                      BarChartRodData(
                          fromY: 0, toY: 10, width: 15, color: appPrimaryColor),
                    ]),
                    BarChartGroupData(x: 7, barRods: [
                      BarChartRodData(
                          fromY: 0, toY: 10, width: 15, color: appPrimaryColor),
                    ]),
                    BarChartGroupData(x: 8, barRods: [
                      BarChartRodData(
                          fromY: 0, toY: 10, width: 15, color: appPrimaryColor),
                    ]),
                  ])),
            ),
          ],
        ),
      ),
    );
  }
}
