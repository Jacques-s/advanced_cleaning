import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/dashboard_mobile_controller.dart';
import 'package:advancedcleaning/shared_widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DashboardScreenMobile extends GetView<DashboardMobileController> {
  const DashboardScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Obx(
      () => Scaffold(
          appBar: AppBar(
            backgroundColor: appPrimaryColor,
            foregroundColor: Colors.white,
            title: const Text(
              'Dashbaord',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          drawer: controller.isLoading.value == false
              ? AppDrawer(
                  activePage: '/dashboard',
                )
              : null,
          body: Padding(
            padding: EdgeInsets.all(Get.width * 0.02),
            child: controller.isLoading.value == true
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: Get.width * 0.02,
                            horizontal: Get.width * 0.04),
                        decoration: BoxDecoration(
                          color: appAccentColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: controller.userSite.value == null
                            ? const Text('Current Site: Not set')
                            : Text(
                                'Current Site:  ${controller.userSite.value!.title}'),
                      ),
                      SizedBox(
                        height: Get.height * 0.01,
                      ),
                      Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.inspections.length,
                            itemBuilder: (_, index) {
                              final item = controller.inspections[index];
                              return Column(
                                children: [
                                  DashboardInspectionItem(
                                    inspectionId: item['id'],
                                    inspectionDate: item['inspectionDate'],
                                    score: item['score'],
                                    passes: item['pass'],
                                    fails: item['fail'],
                                  ),
                                  SizedBox(
                                    height: Get.height * 0.02,
                                  )
                                ],
                              );
                            }),
                      )
                    ],
                  ),
          )),
    ));
  }
}

class DashboardInspectionItem extends StatelessWidget {
  const DashboardInspectionItem(
      {super.key,
      required this.inspectionId,
      required this.inspectionDate,
      required this.score,
      required this.passes,
      required this.fails});

  final String? inspectionId;
  final String inspectionDate;
  final double? score;
  final double? passes;
  final double? fails;

  String getDate() {
    return 'Inspection: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(inspectionDate))}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Get.width * 0.02),
      decoration: BoxDecoration(
          border: Border.all(color: appAccentColor),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(getDate(),
              style: TextStyle(
                  fontSize: Get.textScaleFactor * 14,
                  fontWeight: FontWeight.bold,
                  color: appPrimaryColor)),
          const Divider(),
          if (inspectionId == null || inspectionId!.isEmpty)
            const Center(
              child: Text(
                "Missing",
                style: TextStyle(color: appDangerColor),
              ),
            )
          else
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Score",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: appPrimaryColor),
                    ),
                    Text('$score %')
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Passed",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: appPrimaryColor),
                    ),
                    Text(passes?.toStringAsFixed(0) ?? '')
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Failed",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: appPrimaryColor),
                    ),
                    Text(fails?.toStringAsFixed(0) ?? '')
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
