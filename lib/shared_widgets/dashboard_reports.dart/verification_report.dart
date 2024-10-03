import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/models/question_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VerificationReport extends StatelessWidget {
  const VerificationReport({super.key, required this.answers});

  final Map<String, Map<String, List<InspectionQuestion>>> answers;

  List<TableRow> areaRows() {
    List<TableRow> rows = [];
    answers.forEach((formatedDate, areas) {
      rows.add(TableRow(
        decoration: const BoxDecoration(color: appSecondaryColor),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              formatedDate,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
        ],
      ));
      areas.forEach((areaTitle, values) {
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
                  : DateFormat('yyyy-MM-dd')
                      .format(question.lastInspectionDate!),
              question.lastInspectionResult?.name ?? '-'));
        }
      });
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
                  )
                : result == 'fail'
                    ? const Icon(
                        Icons.close,
                        color: appDangerColor,
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
            'Verification Report',
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
          )
        ],
      ),
    );
  }
}
