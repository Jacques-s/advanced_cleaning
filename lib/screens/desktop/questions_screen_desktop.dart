import 'dart:io';

import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/question_controller.dart';
import 'package:advancedcleaning/data_tables/question_management.dart';
import 'package:advancedcleaning/models/question_model.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:advancedcleaning/shared_widgets/app_drawer.dart';
import 'package:advancedcleaning/shared_widgets/general_dropdown_field.dart';
import 'package:advancedcleaning/shared_widgets/general_submit_button.dart';
import 'package:advancedcleaning/shared_widgets/general_text_field.dart';
import 'package:advancedcleaning/shared_widgets/management_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuestionsScreenDesktop extends GetView<QuestionController> {
  const QuestionsScreenDesktop({super.key});

  void viewQuestions(InspectionQuestion question) {
    //Get.toNamed(Routes, arguments: question);
  }

  void editQuestion(InspectionQuestion question) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    controller.titleController.text = question.title;
    controller.frequencyController.text = question.frequency.name;
    controller.statusController.text = question.status.name;

    Get.dialog(
      Obx(
        () => ManagementDialog(
            formKey: formKey,
            dialogTitle: 'Editing: ${question.title}',
            submissionLabel: 'Edit Question',
            isLoading: controller.isLoading.value,
            onSubmission: () async {
              if (formKey.currentState!.validate()) {
                await controller.updateQuestion(question);
              }
            },
            formFields: [
              GeneralTextFormField(
                  controller: controller.titleController,
                  label: 'Question Title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }),
              GeneralDropdownFormField(
                  label: 'Frequency',
                  options: InspectionFrequency.values
                      .map((frequency) => {
                            'id': frequency.name,
                            'title': frequency.name.capitalize!
                          })
                      .toList(),
                  initialSelection: question.frequency.name,
                  onSelect: (value) {
                    controller.frequencyController.text = value ?? '';
                  },
                  validator: null),
              GeneralDropdownFormField(
                  label: 'Status',
                  options: Status.values
                      .map((status) =>
                          {'id': status.name, 'title': status.name.capitalize!})
                      .toList(),
                  initialSelection: question.status.name,
                  onSelect: (value) {
                    controller.statusController.text = value ?? '';
                  },
                  validator: null)
            ]),
      ),
    );
  }

  void deleteQuestion(InspectionQuestion question) {
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Obx(
        () => ManagementDialog(
          formKey: formKey,
          dialogTitle: 'Delete ${question.title}',
          submissionLabel: 'Delete',
          isLoading: controller.isLoading.value,
          onSubmission: () async {
            if (formKey.currentState!.validate()) {
              await controller.deleteQuestion(question);
            }
          },
          formFields: const [
            Text(
              'Are you sure you want to delete this question? It cannot be undone.',
            ),
          ],
        ),
      ),
    );
  }

  void createQuestion() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    controller.titleController.text = '';
    controller.frequencyController.text = InspectionFrequency.daily.name;
    controller.statusController.text = Status.active.name;

    Get.dialog(
      Obx(
        () => ManagementDialog(
            formKey: formKey,
            dialogTitle: 'Create An Question',
            submissionLabel: 'Create Question',
            isLoading: controller.isLoading.value,
            onSubmission: () async {
              if (formKey.currentState!.validate()) {
                await controller.createQuestion();
              }
            },
            formFields: [
              GeneralTextFormField(
                  controller: controller.titleController,
                  label: 'Question Title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }),
              GeneralDropdownFormField(
                  label: 'Frequency',
                  options: InspectionFrequency.values
                      .map((frequency) => {
                            'id': frequency.name,
                            'title': frequency.name.capitalize!
                          })
                      .toList(),
                  initialSelection: InspectionFrequency.daily.name,
                  onSelect: (value) {
                    controller.frequencyController.text = value ?? '';
                  },
                  validator: null),
            ]),
      ),
    );
  }

  Future<void> pickAndUploadExcelFile() async {
    // Open file picker
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'], // Allow only Excel files
        withData: true);

    if (result != null) {
      if (kIsWeb) {
        // Web platform
        Uint8List? fileBytes = result.files.single.bytes;
        String fileName = result.files.single.name;

        if (fileBytes != null) {
          print("Web - Selected file name: $fileName");
          print("Web - File size: ${fileBytes.length} bytes");
          await controller.importQuestionData(fileBytes);
        } else {
          print("Web - Failed to load file data");
        }
      } else {
        print(result.files.single.path!);
        // Get the file path
        File file = File(result.files.single.path!);
        var bytes = await file.readAsBytes();
        await controller.importQuestionData(bytes);
      }
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: appPrimaryColor,
              foregroundColor: Colors.white,
              title: const Text(
                'Questions',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: Get.width * 0.01),
                  child: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                          child: ListTile(
                        leading: const Icon(Icons.download),
                        title: const Text('Question Template'),
                        onTap: () {
                          controller.exportTemplateToExcel();
                        },
                      )),
                      PopupMenuItem(
                          child: ListTile(
                        leading: const Icon(Icons.upload),
                        title: const Text('Import Questions'),
                        onTap: () {
                          pickAndUploadExcelFile();
                        },
                      )),
                      PopupMenuItem(
                          child: ListTile(
                        leading: const Icon(Icons.download),
                        title: const Text('Export Questions'),
                        onTap: () {
                          controller.exportDataToExcel();
                        },
                      )),
                    ],
                  ),
                )
              ],
            ),
            drawer: AppDrawer(
              activePage: "/questions",
            ),
            body: Padding(
              padding: EdgeInsets.all(Get.width * 0.02),
              child: Column(
                children: [
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            if (kIsWeb) {
                              Navigator.pop(context);
                            } else {
                              Get.back();
                            }
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.arrow_back),
                              Text("Back To Areas"),
                            ],
                          )),
                    ],
                  ),
                  Obx(
                    () {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (controller.questions.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('No data yet'),
                              SizedBox(height: Get.height * 0.01),
                              GeneralSubmitButton(
                                  onPress: () {
                                    createQuestion();
                                  },
                                  label: 'New Question'),
                            ],
                          ),
                        );
                      } else {
                        return SingleChildScrollView(
                          child: SizedBox(
                            width: double.infinity,
                            child: PaginatedDataTable(
                              header: Text(controller
                                          .authController.currentArea !=
                                      null
                                  ? 'Questions for ${controller.authController.currentArea!.title}'
                                  : 'Questions'),
                              actions: [
                                TextButton.icon(
                                  onPressed: () {
                                    createQuestion();
                                  },
                                  label: const Text('New Question'),
                                  icon: const Icon(Icons.add),
                                )
                              ],
                              initialFirstRowIndex: controller.lastIndex.value,
                              onPageChanged: (index) {
                                if (controller.questions.length <
                                    controller.totalQuestions.value) {
                                  controller.lastIndex.value =
                                      controller.questions.length;
                                  controller.fetchQuestions(nextPage: true);
                                }
                              },
                              rowsPerPage: controller.pageSize,
                              availableRowsPerPage: const [10],
                              onRowsPerPageChanged: (value) {
                                // You might want to handle changing rows per page here
                              },
                              sortColumnIndex: [
                                'createdAt',
                                'updateddAt',
                                'title',
                                'status'
                              ].indexOf(controller.sortColumn.value),
                              sortAscending: controller.sortAscending.value,
                              columns: [
                                DataColumn(
                                  label: const Text('Created At'),
                                  onSort: (columnIndex, ascending) =>
                                      controller.sort('createdAt', ascending),
                                ),
                                const DataColumn(label: Text('Updated At')),
                                DataColumn(
                                  label: const Text('Title'),
                                  onSort: (columnIndex, ascending) =>
                                      controller.sort('title', ascending),
                                ),
                                const DataColumn(label: Text('Status')),
                                const DataColumn(
                                  label: Text('Actions'),
                                ),
                              ],
                              source: QuestionManagementDataSource(
                                questions: controller.questions,
                                rowTotalCount: controller.totalQuestions.value,
                                onView: (question) => viewQuestions(question),
                                onEdit: (question) => editQuestion(question),
                                onDelete: (question) =>
                                    deleteQuestion(question),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            )));
  }
}
