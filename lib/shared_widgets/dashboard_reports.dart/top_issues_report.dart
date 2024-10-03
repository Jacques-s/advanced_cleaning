import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/dashboard_controller.dart';
import 'package:advancedcleaning/models/corrective_action_model.dart';
import 'package:advancedcleaning/shared_widgets/general_text_field.dart';
import 'package:advancedcleaning/shared_widgets/management_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TopIssuesReport extends GetView<DashboardController> {
  const TopIssuesReport({super.key, required this.answers});

  final Map<String, Map<String, dynamic>> answers;

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
        ],
      ));

      values.forEach((questionId, question) {
        String questionTitle = question['questionTitle'] ?? '-';
        var count = question['count'] ?? 0;

        CorrectiveAction action = CorrectiveAction(
            id: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            accountId: question['accountId'] ?? '',
            siteId: question['siteId'] ?? '',
            areaId: question['areaId'] ?? '',
            questionId: questionId,
            questionTitle: questionTitle,
            failureCount: count,
            userId: '',
            action: '',
            actionMonth: controller.startDate.value ?? DateTime.now());

        rows.add(itemRow(action));
      });
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
            child: IconButton(
              icon: const Icon(
                Icons.edit,
              ),
              onPressed: () {
                createCorrectiveAction(action);
              },
            ),
          ),
        ],
      );

  void createCorrectiveAction(CorrectiveAction action) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    TextEditingController titleController = TextEditingController();

    Get.dialog(
      Obx(
        () => ManagementDialog(
            formKey: formKey,
            dialogTitle: 'Create An Action',
            submissionLabel: 'Create Action',
            isLoading: controller.isLoading.value,
            onSubmission: () async {
              if (formKey.currentState!.validate()) {
                //Set the action action value in the model
                action.action = titleController.text;
                await controller.createCorrectiveAction(action);
              }
            },
            formFields: [
              GeneralTextFormField(
                  controller: titleController,
                  label: 'Corrective Action',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }),
            ]),
      ),
    );
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
            'Top Issues',
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
