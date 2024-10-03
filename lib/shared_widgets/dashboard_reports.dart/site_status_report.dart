import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/models/question_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SiteStatusReport extends StatelessWidget {
  const SiteStatusReport({super.key, required this.answers});

  final Map<String, List<InspectionQuestion>> answers;

  List<TableRow> areaRows() {
    List<TableRow> rows = [];

    answers.forEach((areaTitle, values) {
      rows.add(TableRow(
        decoration: const BoxDecoration(color: appPrimaryColor),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              areaTitle,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
        ],
      ));

      for (var question in values) {
        rows.add(itemRow(
            question.title,
            question.frequency.name,
            question.nextInspectionDate == null
                ? '-'
                : DateFormat('yyyy-MM-dd').format(question.nextInspectionDate!),
            question.lastInspectionResult?.name ?? '-'));
      }
    });

    return rows;
  }

  TableRow itemRow(String questionTitle, String frequency, String dueDate,
          String result) =>
      TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              questionTitle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              frequency,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              dueDate,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: result == 'pass'
                ? const Icon(
                    Icons.check,
                    color: appSuccessColor,
                    size: 14,
                  )
                : result == 'fail'
                    ? const Icon(
                        Icons.close,
                        color: appDangerColor,
                        size: 14,
                      )
                    : const Text(
                        '-',
                      ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Get.width * 0.01),
      decoration: BoxDecoration(
          border: Border.all(color: appAccentColor),
          borderRadius: BorderRadius.circular(5)),
      child: Column(
        children: [
          Text(
            'Overdue / Missed Items',
            style: TextStyle(
                color: appPrimaryColor,
                fontSize: Get.textScaleFactor * 20,
                fontWeight: FontWeight.bold),
          ),
          Table(
            border: TableBorder.all(color: Colors.black),
            children: [
              const TableRow(
                decoration: BoxDecoration(color: appAccentColor),
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Item Description',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Frequency',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Due Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Last Result',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              ...areaRows()
            ],
          ),
        ],
      ),
    );
  }
}
