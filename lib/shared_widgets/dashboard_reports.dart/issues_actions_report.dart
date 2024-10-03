import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/models/corrective_action_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class IssueActionsReport extends StatelessWidget {
  const IssueActionsReport({super.key, required this.answers});

  final Map<String, List<CorrectiveAction>> answers;

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

      for (CorrectiveAction action in values) {
        rows.add(itemRow(action));
      }
    });

    return rows;
  }

  TableRow itemRow(CorrectiveAction action) => TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(action.questionTitle),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${action.failureCount}'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(DateFormat('yyyy-MM-dd').format(action.updatedAt)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(action.action),
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
            'Issue Actions',
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
                      'Failure Count',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Last Updated',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Action',
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
