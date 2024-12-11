import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/models/chemical_models/chemical_log_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChemicalLogReport extends StatelessWidget {
  const ChemicalLogReport({super.key, required this.chemicalLogs});

  final Map<String, List<ChemicalLog>> chemicalLogs;

  List<TableRow> itemRows() {
    List<TableRow> rows = [];

    chemicalLogs.forEach((chemicalName, logs) {
      rows.add(TableRow(
        decoration: BoxDecoration(color: appSecondaryColor),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              chemicalName,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
        ],
      ));

      for (var log in logs) {
        rows.add(TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat('yyyy-MM-dd HH:mm').format(log.createdAt),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                log.chemicalAmount,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                log.batchNumber,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                log.expiryDate,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                log.issuedTo,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                log.verification ?? '',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                log.correctiveAction ?? '',
              ),
            ),
          ],
        ));
      }
    });

    return rows;
  }

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
            'Chemical Log Report',
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
                      'Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Amount Of Chemical',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Batch Number',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Expiry Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Issued To',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Verification',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Corrective Action',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              ...itemRows()
            ],
          )
        ],
      ),
    );
  }
}
