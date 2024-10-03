import 'package:advancedcleaning/models/question_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuestionManagementDataSource extends DataTableSource {
  final List<InspectionQuestion> questions;
  final int rowTotalCount;

  final Function(InspectionQuestion) onView;
  final Function(InspectionQuestion) onEdit;
  final Function(InspectionQuestion) onDelete;

  QuestionManagementDataSource({
    required this.questions,
    required this.rowTotalCount,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= questions.length) {
      return null;
    }

    final question = questions[index];
    return DataRow(
      cells: [
        DataCell(Text(question.createdAt.toString())),
        DataCell(Text(question.updatedAt.toString())),
        DataCell(Text(question.title)),
        DataCell(Text(question.status.name.capitalize!)),
        DataCell(
          Row(
            children: [
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 10),
              //   child: IconButton(
              //     icon: const Icon(
              //       Icons.visibility,
              //       color: Colors.blue,
              //     ),
              //     onPressed: () => onView(question),
              //     tooltip: 'View Questions',
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.amber,
                  ),
                  onPressed: () => onEdit(question),
                  tooltip: 'Edit Question',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () => onDelete(question),
                  tooltip: 'Delete Question',
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
