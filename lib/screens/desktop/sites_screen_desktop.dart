import 'package:advancedcleaning/app_router.dart';
import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/site_controller.dart';
import 'package:advancedcleaning/data_tables/site_management.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:advancedcleaning/models/site_model.dart';
import 'package:advancedcleaning/shared_widgets/app_drawer.dart';
import 'package:advancedcleaning/shared_widgets/general_dropdown_field.dart';
import 'package:advancedcleaning/shared_widgets/general_submit_button.dart';
import 'package:advancedcleaning/shared_widgets/general_text_field.dart';
import 'package:advancedcleaning/shared_widgets/management_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SitesScreenDesktop extends GetView<SiteController> {
  const SitesScreenDesktop({super.key});

  void viewAreas(Site site) {
    controller.authController.setCurrentSite = site;
    Get.toNamed(Routes.AREA_MANAGEMENT);
  }

  void editSite(Site site) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    controller.titleController.text = site.title;
    controller.addressController.text = site.address ?? '';
    controller.statusController.text = site.status.name;

    Get.dialog(
      Obx(
        () => ManagementDialog(
            formKey: formKey,
            dialogTitle: 'Editing: ${site.title}',
            submissionLabel: 'Edit Site',
            isLoading: controller.isLoading.value,
            onSubmission: () async {
              if (formKey.currentState!.validate()) {
                await controller.updateSite(site);
              }
            },
            formFields: [
              GeneralTextFormField(
                  controller: controller.titleController,
                  label: 'Site Title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }),
              GeneralTextFormField(
                  controller: controller.addressController,
                  label: 'Site Address',
                  validator: null),
              GeneralDropdownFormField(
                  label: 'Status',
                  options: Status.values
                      .map((status) =>
                          {'id': status.name, 'title': status.name.capitalize!})
                      .toList(),
                  initialSelection: site.status.name,
                  onSelect: (value) {
                    print(value);
                    controller.statusController.text = value ?? '';
                  },
                  validator: null)
            ]),
      ),
    );
  }

  void deleteSite(Site site) {
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Obx(
        () => ManagementDialog(
          formKey: formKey,
          dialogTitle: 'Delete ${site.title}',
          submissionLabel: 'Delete',
          isLoading: controller.isLoading.value,
          onSubmission: () async {
            if (formKey.currentState!.validate()) {
              await controller.deleteSite(site);
            }
          },
          formFields: const [
            Text(
              'Are you sure you want to delete this site? It cannot be undone.',
            ),
          ],
        ),
      ),
    );
  }

  void createSite() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    controller.titleController.text = '';
    controller.addressController.text = '';
    controller.statusController.text = Status.active.name;

    Get.dialog(
      Obx(
        () => ManagementDialog(
            formKey: formKey,
            dialogTitle: 'Create An Site',
            submissionLabel: 'Create Site',
            isLoading: controller.isLoading.value,
            onSubmission: () async {
              if (formKey.currentState!.validate()) {
                await controller.createSite();
              }
            },
            formFields: [
              GeneralTextFormField(
                  controller: controller.titleController,
                  label: 'Site Title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }),
              GeneralTextFormField(
                controller: controller.addressController,
                label: 'Site Address',
                validator: null,
              ),
            ]),
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
                'Sites',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            drawer: AppDrawer(
              activePage: "/sites",
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
                              Text("Back To Accounts"),
                            ],
                          )),
                    ],
                  ),
                  Obx(
                    () {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (controller.sites.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('No data yet'),
                              SizedBox(height: Get.height * 0.01),
                              GeneralSubmitButton(
                                  onPress: () {
                                    createSite();
                                  },
                                  label: 'New Site'),
                            ],
                          ),
                        );
                      } else {
                        return SingleChildScrollView(
                          child: SizedBox(
                            width: double.infinity,
                            child: PaginatedDataTable(
                              header: Text(controller
                                          .authController.currentAccount !=
                                      null
                                  ? 'Sites for ${controller.authController.currentAccount!.title}'
                                  : 'Sites'),
                              actions: [
                                TextButton.icon(
                                  onPressed: () {
                                    createSite();
                                  },
                                  label: const Text('New Site'),
                                  icon: const Icon(Icons.add),
                                )
                              ],
                              initialFirstRowIndex: controller.lastIndex.value,
                              onPageChanged: (index) {
                                if (controller.sites.length <
                                    controller.totalSites.value) {
                                  controller.lastIndex.value =
                                      controller.sites.length;
                                  controller.fetchSites(nextPage: true);
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
                              source: SiteManagementDataSource(
                                sites: controller.sites,
                                rowTotalCount: controller.totalSites.value,
                                onView: (site) => viewAreas(site),
                                onEdit: (site) => editSite(site),
                                onDelete: (site) => deleteSite(site),
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
