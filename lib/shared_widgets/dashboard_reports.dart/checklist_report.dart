import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChecklistReport extends StatelessWidget {
  const ChecklistReport(
      {super.key, required this.reportMonth, required this.answers});

  final DateTime reportMonth;
  final Map<String, dynamic> answers;

  List<String> getDaysOfMonth() {
    DateTime date = DateTime(reportMonth.year, reportMonth.month + 1,
        0); // The zero day of the next month is the last day of the current month
    int numOfDays = date.day;
    List<String> daysOfMonth = [];
    for (var i = 1; i <= numOfDays; i++) {
      daysOfMonth.add(DateFormat('dd')
          .format(DateTime(reportMonth.year, reportMonth.month, i)));
    }

    return daysOfMonth;
  }

  List<Widget> areaRows() {
    List<Widget> rows = [];

    answers.forEach((areaId, data) {
      String areaTitle = data['areaTitle'] ?? '-';
      Map<dynamic, dynamic> questions = data['questions'] ?? {};

      //Area row
      rows.add(
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 0.5),
                  color: appPrimaryColor,
                ),
                padding: const EdgeInsets.all(4.0),
                height: 35,
                child: Text(
                  areaTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
      //////////////////////

      questions.forEach((questionId, question) {
        String questionTitle = question['questionTitle'] ?? '-';
        Map<dynamic, dynamic> days = question['days'] ?? {};

        rows.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 0.5),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  width: Get.width * 0.2,
                  child: Text(
                    questionTitle,
                    style: TextStyle(fontSize: Get.textScaleFactor * 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Row(
                      children: days.values
                          .map((answer) => Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 0.5),
                                  ),
                                  padding: const EdgeInsets.all(4.0),
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: answer == 'pass'
                                        ? const Icon(
                                            Icons.check,
                                            color: appSuccessColor,
                                            size: 8,
                                          )
                                        : answer == 'fail'
                                            ? const Icon(
                                                Icons.close,
                                                color: appDangerColor,
                                                size: 8,
                                              )
                                            : const Text(
                                                '-',
                                              ),
                                  ),
                                ),
                              ))
                          .toList() // Convert to List<Widget>
                      ),
                )
              ],
            ),
          ),
        );
      });
    });

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: Get.height * 0.8,
      padding: EdgeInsets.all(Get.width * 0.01),
      decoration: BoxDecoration(
          border: Border.all(color: appAccentColor),
          borderRadius: BorderRadius.circular(5)),
      child: Column(
        children: [
          Text(
            'Checklist Report',
            style: TextStyle(
                color: appPrimaryColor,
                fontSize: Get.textScaleFactor * 20,
                fontWeight: FontWeight.bold),
          ),
          Text(
            DateFormat('MMMM yyyy').format(reportMonth),
            style: TextStyle(
                color: appPrimaryColor,
                fontSize: Get.textScaleFactor * 16,
                fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 0.5),
                  color: appAccentColor,
                ),
                padding: const EdgeInsets.all(8.0),
                width: Get.width * 0.2,
                height: 35,
                child: const Text(
                  'Item Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Row(
                    children: getDaysOfMonth()
                        .map((day) => Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black, width: 0.5),
                                  color: appAccentColor,
                                ),
                                padding: const EdgeInsets.all(8.0),
                                height: 35,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    day,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ))
                        .toList() // Convert to List<Widget>
                    ),
              )
            ],
          ),

          Expanded(
            child: ListView.builder(
              //shrinkWrap: true,
              itemCount: areaRows().length,
              itemBuilder: (context, index) {
                Widget row = areaRows()[index];
                return row;
              },
            ),
          ),

          //...areaRows()
        ],
      ),
    );
  }
}
