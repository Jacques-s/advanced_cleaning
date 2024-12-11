import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/models/inspection_models/answer_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FailureReport extends StatelessWidget {
  const FailureReport({super.key, required this.answers});

  final Map<String, Map<String, List<InspectionAnswer>>> answers;

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
          rows.add(itemRow(question));
        }
      });
    });

    return rows;
  }

  TableRow itemRow(InspectionAnswer answer) => TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              answer.questionTitle ?? '-',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              answer.questionFrequency.name,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              answer.failureReason ?? '-',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              answer.correctiveAction ?? '-',
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
            'Failure Report',
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
                      'Reason For Failure',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Corrections',
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
