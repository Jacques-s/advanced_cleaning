import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InspectionItem extends StatelessWidget {
  const InspectionItem(
      {required this.itemKey,
      required this.label,
      required this.status,
      required this.wasInspected,
      required this.lastInspectedDate,
      required this.lastInspectedResult,
      required this.nextInspectedDate,
      required this.frequency,
      required this.onDismissed,
      required this.overdueStatus,
      super.key});

  final Key itemKey;
  final String label;
  final String status;
  final String? overdueStatus;
  final DateTime? lastInspectedDate;
  final DateTime? nextInspectedDate;
  final String lastInspectedResult;
  final InspectionFrequency frequency;
  final bool wasInspected;
  final Future<bool?> Function(DismissDirection) onDismissed;

  Color statusColor() {
    switch (status) {
      case 'notSet':
        return appAccentColor;
      case 'fail':
        return appDangerColor;
      case 'pass':
        return appSuccessColor;
      default:
        return appAccentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: itemKey,
      confirmDismiss: onDismissed,
      behavior: HitTestBehavior.translucent,
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20.0),
        child: const Text('Pass',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16)),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Text('Fail',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16)),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: Get.width * 0.02, horizontal: Get.width * 0.02),
        padding: EdgeInsets.symmetric(
            vertical: Get.width * 0.02, horizontal: Get.width * 0.02),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: statusColor(), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.symmetric(
                    vertical: Get.width * 0.02, horizontal: Get.width * 0.02),
                decoration: const BoxDecoration(
                    color: appAccentColor,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(
                      label,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    )),
                    if (wasInspected) const Icon(Icons.check)
                  ],
                )),
            SizedBox(
              height: Get.height * 0.02,
            ),
            if (overdueStatus != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    overdueStatus!,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: appDangerColor,
                        fontSize: Get.textScaleFactor * 16),
                  ),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Last Inspected',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(lastInspectedDate == null
                    ? 'Not inspected yet'
                    : DateFormat.yMMMMd().format(lastInspectedDate!))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Next Inspection',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(lastInspectedDate == null
                    ? 'Not inspected yet'
                    : DateFormat.yMMMMd().format(nextInspectedDate!))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Last Result',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(lastInspectedResult)
              ],
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                    color: appAccentColor,
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(
                    vertical: Get.width * 0.01, horizontal: Get.width * 0.02),
                child: Text(frequency.name.capitalizeFirst!),
              ),
            )
          ],
        ),
      ),
    );
  }
}
