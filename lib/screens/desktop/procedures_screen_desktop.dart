import 'dart:io';

import 'package:advancedcleaning/app_router.dart';
import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/procedure_controller.dart';
import 'package:advancedcleaning/data_tables/procedure_management.dart';
import 'package:advancedcleaning/models/chemical_model.dart';
import 'package:advancedcleaning/models/procedure_model.dart';
import 'package:advancedcleaning/shared_widgets/app_drawer.dart';
import 'package:advancedcleaning/shared_widgets/chemical_multi_text_field.dart';
import 'package:advancedcleaning/shared_widgets/general_date_field.dart';
import 'package:advancedcleaning/shared_widgets/general_multi_dropdown_field.dart';
import 'package:advancedcleaning/shared_widgets/general_multi_text_field.dart';
import 'package:advancedcleaning/shared_widgets/general_submit_button.dart';
import 'package:advancedcleaning/shared_widgets/general_text_field.dart';
import 'package:advancedcleaning/shared_widgets/management_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProceduresScreenDesktop extends GetView<ProcedureController> {
  const ProceduresScreenDesktop({super.key});

  Widget procedureViewTile(String title, String value) {
    return Row(children: [
      Container(
        width: Get.width * 0.2,
        padding: EdgeInsets.symmetric(horizontal: Get.width * 0.01),
        decoration: BoxDecoration(
          border: Border.all(color: appPrimaryColor),
          color: appAccentColor,
        ),
        child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      Container(
        width: Get.width * 0.2,
        padding: EdgeInsets.symmetric(horizontal: Get.width * 0.01),
        decoration: BoxDecoration(
          border: Border.all(color: appPrimaryColor),
        ),
        child: Text(value),
      ),
    ]);
  }

  Widget procedureViewBlock(String title, List<String> values,
      {bool numbered = false}) {
    return Row(
      children: [
        Column(children: [
          Container(
            width: Get.width * 0.4,
            padding: EdgeInsets.symmetric(horizontal: Get.width * 0.01),
            decoration: BoxDecoration(
              border: Border.all(color: appPrimaryColor),
              color: appAccentColor,
            ),
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          for (int index = 0;
              index < values.length;
              index++) // Add index variable
            Container(
              width: Get.width * 0.4,
              padding: EdgeInsets.symmetric(horizontal: Get.width * 0.01),
              decoration: BoxDecoration(
                border: Border.all(color: appPrimaryColor),
              ),
              child: numbered
                  ? Text('${index + 1}. ${values[index]}') // Use index here
                  : Text(values[index]), // Use values[index] instead of value
            ),
        ]),
      ],
    );
  }

  void viewProcedure(Procedure procedure) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    Get.dialog(
      Obx(
        () => ManagementDialog(
            formKey: formKey,
            dialogTitle: 'Viewing: ${procedure.title}',
            //submissionLabel: 'Export',
            submissionLabel: null,
            onSubmission: null,
            isLoading: controller.isLoading.value,
            // onSubmission: () async {
            //   if (formKey.currentState!.validate()) {
            //     print('exporting...');
            //   }
            // },
            formFields: [
              Container(
                padding: EdgeInsets.all(Get.width * 0.01),
                child: Column(
                  children: [
                    procedureViewTile('Procedure Title', procedure.title),
                    procedureViewTile(
                        'Effective Date', procedure.effectiveDate.toString()),
                    procedureViewTile(
                        'Document Number', procedure.documentNumber),
                    procedureViewTile(
                        'Amendment Number', procedure.amendmentNumber),
                    procedureViewTile('Area Title', procedure.areaTitle),
                    procedureViewTile(
                        'Cleaning Record', procedure.cleaningRecord),
                    procedureViewTile('Maintenance Assistance',
                        procedure.maintenanceAssistance),
                    procedureViewTile('Inspected By', procedure.inspectedBy),
                    procedureViewTile(
                        'Frequency', procedure.frequencies.join(', ')),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: Get.width * 0.4,
                              padding: EdgeInsets.symmetric(
                                  horizontal: Get.width * 0.01),
                              decoration: BoxDecoration(
                                border: Border.all(color: appPrimaryColor),
                                color: appAccentColor,
                              ),
                              child: Text('Chemicals',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            for (Chemical chemical in procedure.chemicals)
                              Container(
                                width: Get.width * 0.4,
                                padding: EdgeInsets.symmetric(
                                    horizontal: Get.width * 0.01),
                                decoration: BoxDecoration(
                                  border: Border.all(color: appPrimaryColor),
                                ),
                                child: Text(chemical.title),
                              ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: Get.width * 0.4,
                              padding: EdgeInsets.symmetric(
                                  horizontal: Get.width * 0.01),
                              decoration: BoxDecoration(
                                border: Border.all(color: appPrimaryColor),
                                color: appAccentColor,
                              ),
                              child: Text('PPE & Safety Requirements',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Container(
                              width: Get.width * 0.4,
                              padding: EdgeInsets.symmetric(
                                  horizontal: Get.width * 0.01),
                              decoration: BoxDecoration(
                                border: Border.all(color: appPrimaryColor),
                              ),
                              child: Wrap(
                                children: [
                                  for (String requirement
                                      in procedure.safetyRequirements)
                                    Container(
                                      width: Get.width * 0.05,
                                      height: Get.width * 0.05,
                                      padding:
                                          EdgeInsets.all(Get.width * 0.005),
                                      child: Image.asset(
                                          'assets/images/ppeIcons/$requirement.png'),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    procedureViewBlock('Colour Codes', procedure.colourCodes),
                    procedureViewBlock('Equipment / Cleaning Materials',
                        procedure.equipmentRequired),
                    if (procedure.dailyInstructions.isNotEmpty)
                      procedureViewBlock(
                          'Daily Instructions', procedure.dailyInstructions,
                          numbered: true),
                    if (procedure.weeklyInstructions.isNotEmpty)
                      procedureViewBlock(
                          'Weekly Instructions', procedure.weeklyInstructions,
                          numbered: true),
                    if (procedure.monthlyInstructions.isNotEmpty)
                      procedureViewBlock(
                          'Monthly Instructions', procedure.monthlyInstructions,
                          numbered: true),
                    if (procedure.quarterlyInstructions.isNotEmpty)
                      procedureViewBlock('Quarterly Instructions',
                          procedure.quarterlyInstructions,
                          numbered: true),
                    if (procedure.yearlyInstructions.isNotEmpty)
                      procedureViewBlock(
                          'Yearly Instructions', procedure.yearlyInstructions,
                          numbered: true),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: Get.width * 0.6,
                      ),
                      child: Column(
                        children: [
                          ...procedure.imageUrls.map(
                            (url) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: FadeInImage.assetNetwork(
                                    placeholder:
                                        'assets/images/placeholder.png', // Add a placeholder image
                                    image: url,
                                    fit: BoxFit.contain,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ]),
      ),
    );
  }

  void deleteProcedure(Procedure procedure) {
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Obx(
        () => ManagementDialog(
          formKey: formKey,
          dialogTitle: 'Delete ${procedure.title}',
          submissionLabel: 'Delete',
          isLoading: controller.isLoading.value,
          onSubmission: () async {
            if (formKey.currentState!.validate()) {
              await controller.deleteProcedure(procedure);
            }
          },
          formFields: const [
            Text(
              'Are you sure you want to delete this procedure? It cannot be undone.',
            ),
          ],
        ),
      ),
    );
  }

  void createEditProcedure(Procedure? procedure) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    controller.titleController.text = procedure?.title ?? '';
    controller.effectiveDateController.text =
        procedure?.effectiveDate.toString() ?? '';
    controller.documentNumberController.text = procedure?.documentNumber ?? '';
    controller.amendmentNumberController.text =
        procedure?.amendmentNumber ?? '';
    controller.areaTitleController.text = procedure?.areaTitle ?? '';
    controller.cleaningRecordController.text = procedure?.cleaningRecord ?? '';
    controller.maintenanceAssistanceController.text =
        procedure?.maintenanceAssistance ?? '';
    controller.inspectedByController.text = procedure?.inspectedBy ?? '';
    controller.chemicals.value = procedure?.chemicals ?? [];
    controller.safetyRequirements.value = procedure?.safetyRequirements ?? [];
    controller.colourCodes.value = procedure?.colourCodes ?? [];
    controller.equipmentRequired.value = procedure?.equipmentRequired ?? [];
    controller.dailyInstructions.value = procedure?.dailyInstructions ?? [];
    controller.weeklyInstructions.value = procedure?.weeklyInstructions ?? [];
    controller.monthlyInstructions.value = procedure?.monthlyInstructions ?? [];
    controller.quarterlyInstructions.value =
        procedure?.quarterlyInstructions ?? [];
    controller.yearlyInstructions.value = procedure?.yearlyInstructions ?? [];

    TextEditingController colourCodesController = TextEditingController();
    TextEditingController equipmentController = TextEditingController();
    TextEditingController dailyInstructionsController = TextEditingController();
    TextEditingController weeklyInstructionsController =
        TextEditingController();
    TextEditingController monthlyInstructionsController =
        TextEditingController();
    TextEditingController quarterlyInstructionsController =
        TextEditingController();
    TextEditingController yearlyInstructionsController =
        TextEditingController();

    TextEditingController checmicalTitleController = TextEditingController();
    TextEditingController dilutionRangeController = TextEditingController();

    Get.dialog(
      Obx(
        () => ManagementDialog(
            formKey: formKey,
            dialogTitle:
                procedure == null ? 'Create A Procedure' : 'Edit Procedure',
            submissionLabel:
                procedure == null ? 'Create Procedure' : 'Edit Procedure',
            isLoading: controller.isLoading.value,
            onSubmission: () async {
              if (formKey.currentState!.validate()) {
                if (procedure == null) {
                  await controller.createProcedure();
                } else {
                  await controller.updateProcedure(procedure);
                }
              }
            },
            formFields: [
              GeneralTextFormField(
                  controller: controller.titleController,
                  label: 'Procedure Title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GeneralDateField(
                      controller: controller.effectiveDateController,
                      label: 'Effective Date',
                      width: Get.width * 0.3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      }),
                  GeneralTextFormField(
                      controller: controller.documentNumberController,
                      label: 'Document Number',
                      width: Get.width * 0.3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GeneralTextFormField(
                      controller: controller.amendmentNumberController,
                      label: 'Amendment Number',
                      width: Get.width * 0.3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      }),
                  GeneralTextFormField(
                      controller: controller.areaTitleController,
                      label: 'Area Title',
                      width: Get.width * 0.3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GeneralTextFormField(
                      controller: controller.cleaningRecordController,
                      label: 'Cleaning Record',
                      width: Get.width * 0.3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      }),
                  GeneralTextFormField(
                      controller: controller.maintenanceAssistanceController,
                      label: 'Maintenance Assistance',
                      width: Get.width * 0.3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
                        return null;
                      }),
                ],
              ),
              GeneralTextFormField(
                  controller: controller.inspectedByController,
                  label: 'Inspected By',
                  width: Get.width * 0.3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }),
              GeneralMultiSelectDropdownFormField(
                label: 'PPE Required',
                options: ppe.entries
                    .map((entry) => {'id': entry.key, 'title': entry.value})
                    .toList(),
                initialSelections: controller.safetyRequirements,
                onSelect: (value) {
                  controller.safetyRequirements.value = value ?? [];
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
              ChemicalMultiTextField(
                items: controller.chemicals,
                title: 'Chemicals',
                label: 'Chemicals',
                titleController: checmicalTitleController,
                dilutionRangeController: dilutionRangeController,
                onItemAdded: (value) {
                  controller.chemicals.add(value);
                },
                onItemDeleted: (value) {
                  controller.chemicals.remove(value);
                },
              ),
              GeneralMultiTextField(
                items: controller.colourCodes,
                title: 'Colour Codes',
                label: 'Codes',
                controller: colourCodesController,
                onItemAdded: (value) {
                  controller.colourCodes.add(value);
                },
                onItemDeleted: (value) {
                  controller.colourCodes.remove(value);
                },
              ),
              GeneralMultiTextField(
                title: 'Equipment Required',
                label: 'Equipment',
                controller: equipmentController,
                items: controller.equipmentRequired,
                onItemAdded: (value) {
                  controller.equipmentRequired.add(value);
                },
                onItemDeleted: (value) {
                  controller.equipmentRequired.remove(value);
                },
              ),
              GeneralMultiTextField(
                title: 'Daily Instructions',
                label: 'Instructions',
                controller: dailyInstructionsController,
                items: controller.dailyInstructions,
                onItemAdded: (value) {
                  controller.dailyInstructions.add(value);
                },
                onItemDeleted: (value) {
                  controller.dailyInstructions.remove(value);
                },
              ),
              GeneralMultiTextField(
                title: 'Weekly Instructions',
                label: 'Instructions',
                controller: weeklyInstructionsController,
                items: controller.weeklyInstructions,
                onItemAdded: (value) {
                  controller.weeklyInstructions.add(value);
                },
                onItemDeleted: (value) {
                  controller.weeklyInstructions.remove(value);
                },
              ),
              GeneralMultiTextField(
                title: 'Monthly Instructions',
                label: 'Instructions',
                controller: monthlyInstructionsController,
                items: controller.monthlyInstructions,
                onItemAdded: (value) {
                  controller.monthlyInstructions.add(value);
                },
                onItemDeleted: (value) {
                  controller.monthlyInstructions.remove(value);
                },
              ),
              GeneralMultiTextField(
                title: 'Quarterly Instructions',
                label: 'Instructions',
                controller: quarterlyInstructionsController,
                items: controller.quarterlyInstructions,
                onItemAdded: (value) {
                  controller.quarterlyInstructions.add(value);
                },
                onItemDeleted: (value) {
                  controller.quarterlyInstructions.remove(value);
                },
              ),
              GeneralMultiTextField(
                title: 'Yearly Instructions',
                label: 'Instructions',
                controller: yearlyInstructionsController,
                items: controller.yearlyInstructions,
                onItemAdded: (value) {
                  controller.yearlyInstructions.add(value);
                },
                onItemDeleted: (value) {
                  controller.yearlyInstructions.remove(value);
                },
              ),
              // Add image upload section
              procedureImages(procedure)
            ]),
      ),
    );
  }

  Widget accountFilter() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Account Filter',
          style: TextStyle(fontSize: Get.textScaleFactor * 14),
        ),
        SizedBox(
          width: Get.width * 0.005,
        ),
        DropdownMenu<AccountMenuItem>(
          width: Get.width * 0.2,
          enableSearch: true,
          hintText: 'Select Account',
          requestFocusOnTap: true,
          enableFilter: true,
          initialSelection: controller.accountMenuItems.firstWhereOrNull(
              (element) => element.id == controller.selectedAccountId.value),
          onSelected: (value) {
            if (value != null) {
              controller.selectedAccountId.value = value.id;
              controller.selectedAccountTitle.value = value.title;
              controller.resetProcedures();
            }
          },
          dropdownMenuEntries: controller.accountMenuItems
              .map<DropdownMenuEntry<AccountMenuItem>>((AccountMenuItem menu) {
            return DropdownMenuEntry<AccountMenuItem>(
              value: menu,
              label: menu.title,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget procedureImages(Procedure? procedure) {
    RxList<String> existingImages = RxList.from(procedure?.imageUrls ?? []);

    return Container(
      margin: EdgeInsets.symmetric(
          vertical: Get.height * 0.01, horizontal: Get.width * 0.01),
      padding: EdgeInsets.all(Get.width * 0.01),
      decoration: BoxDecoration(
        border: Border.all(color: appPrimaryColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Images',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => controller.pickImages(),
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Images'),
              ),
              const SizedBox(width: 16),
              Obx(() =>
                  Text('${controller.selectedImages.length} images selected')),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...controller.selectedImages.map((file) => Stack(
                        children: [
                          Image.file(
                            File(file.path!),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                controller.selectedImages.remove(file);
                              },
                            ),
                          ),
                        ],
                      )),
                  if (procedure != null)
                    ...existingImages.map((url) => Stack(
                          children: [
                            Image.network(
                              url,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  // Remove from existing URLs
                                  existingImages.remove(url);
                                  controller.deleteImages.add(url);
                                  procedure.imageUrls.remove(url);
                                },
                              ),
                            ),
                          ],
                        )),
                ],
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: appPrimaryColor,
              foregroundColor: Colors.white,
              title: const Text(
                'Procedures',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            drawer: AppDrawer(
              activePage: Routes.PROCEDURE_MANAGEMENT,
            ),
            body: Padding(
              padding: EdgeInsets.all(Get.width * 0.02),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (controller.allAccounts.isEmpty) {
                    return const Center(child: Text('No accounts available'));
                  } else {
                    if (controller.selectedAccountId.value.isEmpty) {
                      return Column(
                        children: [
                          accountFilter(),
                          const Expanded(
                              child: Center(
                                  child:
                                      Text('Please select an account first'))),
                        ],
                      );
                    } else {
                      if (controller.procedures.isEmpty) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            accountFilter(),
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('No data yet'),
                                    SizedBox(height: Get.height * 0.01),
                                    GeneralSubmitButton(
                                        onPress: () {
                                          createEditProcedure(null);
                                        },
                                        label: 'New Procedure'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            accountFilter(),
                            SizedBox(
                              width: double.infinity,
                              height: Get.height * 0.8,
                              child: SingleChildScrollView(
                                child: PaginatedDataTable(
                                  header: const Text('Procedures'),
                                  actions: [
                                    TextButton.icon(
                                      onPressed: () {
                                        createEditProcedure(null);
                                      },
                                      label: const Text('New Procedure'),
                                      icon: const Icon(Icons.add),
                                    )
                                  ],
                                  initialFirstRowIndex:
                                      controller.lastIndex.value,
                                  onPageChanged: (index) {
                                    if (controller.procedures.length <
                                        controller.totalProcedures.value) {
                                      controller.lastIndex.value =
                                          controller.procedures.length;
                                      controller.fetchProcedures(
                                          nextPage: true);
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
                                    'areaTitle'
                                  ].indexOf(controller.sortColumn.value),
                                  sortAscending: controller.sortAscending.value,
                                  columns: [
                                    DataColumn(
                                      label: const Text('Created At'),
                                      onSort: (columnIndex, ascending) =>
                                          controller.sort(
                                              'createdAt', ascending),
                                    ),
                                    DataColumn(
                                      label: const Text('Updated At'),
                                      onSort: (columnIndex, ascending) =>
                                          controller.sort(
                                              'updateddAt', ascending),
                                    ),
                                    DataColumn(
                                      label: const Text('Title'),
                                      onSort: (columnIndex, ascending) =>
                                          controller.sort('title', ascending),
                                    ),
                                    DataColumn(
                                      label: const Text('Area Title'),
                                      onSort: (columnIndex, ascending) =>
                                          controller.sort(
                                              'areaTitle', ascending),
                                    ),
                                    const DataColumn(
                                      label: Text('Actions'),
                                    ),
                                  ],
                                  source: ProcedureManagementDataSource(
                                    procedures: controller.procedures,
                                    rowTotalCount:
                                        controller.totalProcedures.value,
                                    onView: (procedure) =>
                                        viewProcedure(procedure),
                                    onEdit: (procedure) =>
                                        createEditProcedure(procedure),
                                    onDelete: (procedure) =>
                                        deleteProcedure(procedure),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    }
                  }
                }
              }),
            )));
  }
}
