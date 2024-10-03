import 'package:advancedcleaning/models/area_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AreaManagementDataSource extends DataTableSource {
  final List<InspectionArea> areas;
  final int rowTotalCount;

  final Function(InspectionArea) onView;
  final Function(InspectionArea) onEdit;
  final Function(InspectionArea) onDelete;

  AreaManagementDataSource({
    required this.areas,
    required this.rowTotalCount,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= areas.length) {
      return null;
    }

    final area = areas[index];
    return DataRow(
      cells: [
        DataCell(Text(area.createdAt.toString())),
        DataCell(Text(area.updatedAt.toString())),
        DataCell(Text(area.title)),
        DataCell(Text(area.status.name.capitalize!)),
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
                  onPressed: () => onView(area),
                  tooltip: 'View Areas',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.amber,
                  ),
                  onPressed: () => onEdit(area),
                  tooltip: 'Edit Area',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () => onDelete(area),
                  tooltip: 'Delete Area',
                ),
              ),
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
