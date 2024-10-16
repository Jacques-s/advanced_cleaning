import 'package:advancedcleaning/models/procedure_model.dart';
import 'package:flutter/material.dart';

class ProcedureManagementDataSource extends DataTableSource {
  final List<Procedure> procedures;
  final int rowTotalCount;

  final Function(Procedure) onView;
  final Function(Procedure) onEdit;
  final Function(Procedure) onDelete;

  ProcedureManagementDataSource({
    required this.procedures,
    required this.rowTotalCount,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= procedures.length) {
      return null;
    }

    final procedure = procedures[index];

    return DataRow(
      cells: [
        DataCell(Text(procedure.createdAt.toString())),
        DataCell(Text(procedure.updatedAt.toString())),
        DataCell(Text(procedure.title)),
        DataCell(Text(procedure.areaTitle)),
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
                  onPressed: () => onView(procedure),
                  tooltip: 'View Procedure',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.amber,
                  ),
                  onPressed: () => onEdit(procedure),
                  tooltip: 'Edit Procedure',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () => onDelete(procedure),
                  tooltip: 'Delete Procedure',
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
