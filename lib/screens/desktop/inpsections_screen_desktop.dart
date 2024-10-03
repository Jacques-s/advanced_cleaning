import 'package:advancedcleaning/app_router.dart';
import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/inspection_controller.dart';
import 'package:advancedcleaning/data_tables/inspection_management.dart';
import 'package:advancedcleaning/models/inspection_model.dart';
import 'package:advancedcleaning/shared_widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InpsectionsScreenDesktop extends GetView<InpsectionsController> {
  const InpsectionsScreenDesktop({super.key});

  void viewInspections(Inspection inspection) {
    controller.currentInspection.value = inspection;
    controller.fetchInspectionDetails();
    Get.toNamed(Routes.INSPECTIONVIEW);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: appPrimaryColor,
              foregroundColor: Colors.white,
              title: const Text(
                'Inspections',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            drawer: AppDrawer(
              activePage: Routes.INSPECTION,
            ),
            body: Padding(
              padding: EdgeInsets.all(Get.width * 0.02),
              child: Obx(
                () {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (controller.inspections.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No data yet'),
                        ],
                      ),
                    );
                  } else {
                    return SizedBox(
                      width: double.infinity,
                      height: Get.height * 0.9,
                      child: SingleChildScrollView(
                        child: PaginatedDataTable(
                          header: const Text('Inspections'),
                          initialFirstRowIndex: controller.lastIndex.value,
                          onPageChanged: (index) {
                            if (controller.inspections.length <
                                controller.totalInspections.value) {
                              controller.lastIndex.value =
                                  controller.inspections.length;
                              controller.fetchInspections(nextPage: true);
                            }
                          },
                          rowsPerPage: controller.pageSize,
                          availableRowsPerPage: const [10],
                          onRowsPerPageChanged: (value) {
                            // You might want to handle changing rows per page here
                          },
                          sortColumnIndex: ['createdAt', 'updateddAt', 'score']
                              .indexOf(controller.sortColumn.value),
                          sortAscending: controller.sortAscending.value,
                          columns: [
                            DataColumn(
                              label: const Text('Created At'),
                              onSort: (columnIndex, ascending) =>
                                  controller.sort('createdAt', ascending),
                            ),
                            const DataColumn(label: Text('Updated At')),
                            const DataColumn(label: Text('Site')),
                            const DataColumn(label: Text('Score')),
                            const DataColumn(
                              label: Text('Actions'),
                            ),
                          ],
                          source: InspectionManagementDataSource(
                            inspections: controller.inspections,
                            rowTotalCount: controller.totalInspections.value,
                            onView: (inspection) => viewInspections(inspection),
                            onEdit: (inspection) {},
                            onDelete: (inspection) {},
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            )));
  }
}
