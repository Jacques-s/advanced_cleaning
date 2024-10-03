import 'dart:io';

import 'package:advancedcleaning/app_router.dart';
import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/area_controller.dart';
import 'package:advancedcleaning/data_tables/area_management.dart';
import 'package:advancedcleaning/models/area_model.dart';
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

class AreasScreenDesktop extends GetView<AreaController> {
  const AreasScreenDesktop({super.key});

  void viewAreas(InspectionArea area) {
    controller.authController.setCurrentArea = area;
    Get.toNamed(Routes.QUESTION_MANAGEMENT);
  }

  void editArea(InspectionArea area) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    controller.titleController.text = area.title;
    controller.barcodeController.text = area.barcode;
    controller.statusController.text = area.status.name;

    Get.dialog(
      Obx(
        () => ManagementDialog(
            formKey: formKey,
            dialogTitle: 'Editing: ${area.title}',
            submissionLabel: 'Edit Area',
            isLoading: controller.isLoading.value,
            onSubmission: () async {
              if (formKey.currentState!.validate()) {
                await controller.updateArea(area);
              }
            },
            formFields: [
              GeneralTextFormField(
                  controller: controller.titleController,
                  label: 'Area Title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }),
              GeneralTextFormField(
                  controller: controller.barcodeController,
                  label: 'Area Barcode',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }),
              GeneralDropdownFormField(
                  label: 'Status',
                  options: Status.values
                      .map((status) =>
                          {'id': status.name, 'title': status.name.capitalize!})
                      .toList(),
                  initialSelection: area.status.name,
                  onSelect: (value) {
                    controller.statusController.text = value ?? '';
                  },
                  validator: null)
            ]),
      ),
    );
  }

  void deleteArea(InspectionArea area) {
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Obx(
        () => ManagementDialog(
          formKey: formKey,
          dialogTitle: 'Delete ${area.title}',
          submissionLabel: 'Delete',
          isLoading: controller.isLoading.value,
          onSubmission: () async {
            if (formKey.currentState!.validate()) {
              await controller.deleteArea(area);
            }
          },
          formFields: const [
            Text(
              'Are you sure you want to delete this area? It cannot be undone.',
            ),
          ],
        ),
      ),
    );
  }

  void createArea() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    controller.titleController.text = '';
    controller.barcodeController.text = '';
    controller.statusController.text = Status.active.name;

    Get.dialog(
      Obx(
        () => ManagementDialog(
            formKey: formKey,
            dialogTitle: 'Create An Area',
            submissionLabel: 'Create Area',
            isLoading: controller.isLoading.value,
            onSubmission: () async {
              if (formKey.currentState!.validate()) {
                await controller.createArea();
              }
            },
            formFields: [
              GeneralTextFormField(
                  controller: controller.titleController,
                  label: 'Area Title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }),
              GeneralTextFormField(
                  controller: controller.barcodeController,
                  label: 'Area Barcode',
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

  Future<void> pickAndUploadExcelFile({bool uploadQuestions = false}) async {
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
          if (uploadQuestions == false) {
            await controller.importAreaData(fileBytes);
          } else {
            await controller.importQuestionData(fileBytes);
          }
        } else {
          print("Web - Failed to load file data");
        }
      } else {
        print(result.files.single.path!);
        // Get the file path
        File file = File(result.files.single.path!);
        var bytes = await file.readAsBytes();
        if (uploadQuestions == false) {
          await controller.importAreaData(bytes);
        } else {
          await controller.importQuestionData(bytes);
        }
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
                'Areas',
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
                        title: const Text('Area Template'),
                        onTap: () {
                          controller.exportTemplateToExcel();
                        },
                      )),
                      PopupMenuItem(
                          child: ListTile(
                        leading: const Icon(Icons.upload),
                        title: const Text('Import Areas'),
                        onTap: () {
                          pickAndUploadExcelFile();
                        },
                      )),
                      PopupMenuItem(
                          child: ListTile(
                        leading: const Icon(Icons.upload),
                        title: const Text('Import Area Questions'),
                        onTap: () {
                          pickAndUploadExcelFile(uploadQuestions: true);
                        },
                      )),
                      PopupMenuItem(
                          child: ListTile(
                        leading: const Icon(Icons.download),
                        title: const Text('Export Areas'),
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
              activePage: "/areas",
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
                              Text("Back To Sites"),
                            ],
                          )),
                    ],
                  ),
                  Obx(
                    () {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (controller.areas.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('No data yet'),
                              SizedBox(height: Get.height * 0.01),
                              GeneralSubmitButton(
                                  onPress: () {
                                    createArea();
                                  },
                                  label: 'New Area'),
                              SizedBox(height: Get.height * 0.02),
                              GeneralSubmitButton(
                                  onPress: () {
                                    pickAndUploadExcelFile();
                                  },
                                  label: 'Import Areas'),
                            ],
                          ),
                        );
                      } else {
                        return SizedBox(
                          width: double.infinity,
                          child: PaginatedDataTable(
                            header: Text(controller
                                        .authController.currentSite !=
                                    null
                                ? 'Areas for ${controller.authController.currentSite!.title}'
                                : 'Areas'),
                            actions: [
                              TextButton.icon(
                                onPressed: () {
                                  createArea();
                                },
                                label: const Text('New Area'),
                                icon: const Icon(Icons.add),
                              )
                            ],
                            initialFirstRowIndex: controller.lastIndex.value,
                            onPageChanged: (index) {
                              if (controller.areas.length <
                                  controller.totalAreas.value) {
                                controller.lastIndex.value =
                                    controller.areas.length;
                                controller.fetchAreas(nextPage: true);
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
                            source: AreaManagementDataSource(
                              areas: controller.areas,
                              rowTotalCount: controller.totalAreas.value,
                              onView: (area) => viewAreas(area),
                              onEdit: (area) => editArea(area),
                              onDelete: (area) => deleteArea(area),
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
