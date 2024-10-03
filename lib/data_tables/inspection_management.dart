import 'package:advancedcleaning/models/inspection_model.dart';
import 'package:flutter/material.dart';

class InspectionManagementDataSource extends DataTableSource {
  final List<Inspection> inspections;
  final int rowTotalCount;

  final Function(Inspection) onView;
  final Function(Inspection) onEdit;
  final Function(Inspection) onDelete;

  InspectionManagementDataSource({
    required this.inspections,
    required this.rowTotalCount,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= inspections.length) {
      return null;
    }

    final inspection = inspections[index];
    return DataRow(
      cells: [
        DataCell(Text(inspection.createdAt.toString())),
        DataCell(Text(inspection.updatedAt.toString())),
        DataCell(Text(inspection.siteTitle)),
        DataCell(Text('${inspection.score} %')),
        DataCell(
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.visibility,
                    color: Colors.blue,
                  ),
                  onPressed: () => onView(inspection),
                  tooltip: 'View Inspection',
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 10),
              //   child: IconButton(
              //     icon: const Icon(
              //       Icons.edit,
              //       color: Colors.amber,
              //     ),
              //     onPressed: () => onEdit(inspection),
              //     tooltip: 'Edit Area',
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 10),
              //   child: IconButton(
              //     icon: const Icon(
              //       Icons.delete,
              //       color: Colors.red,
              //     ),
              //     onPressed: () => onDelete(inspection),
              //     tooltip: 'Delete Area',
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => rowTotalCount;

  @override
  int get selectedRowCount => 0;
}
