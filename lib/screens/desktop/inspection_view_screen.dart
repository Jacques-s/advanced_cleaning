import 'package:advancedcleaning/app_router.dart';
import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/inspection_controller.dart';
import 'package:advancedcleaning/shared_widgets/app_drawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InspectionViewScreen extends GetView<InpsectionsController> {
  const InspectionViewScreen({super.key});

  Widget tableHeader(
          String areaTitle, String fails, String passes, String score) =>
      Column(
        children: [
          Table(
            border: TableBorder.all(color: Colors.black),
            children: [
              TableRow(children: [
                TableCell(
                  child: Container(
                    color: appPrimaryColor,
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      areaTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ]),
            ],
          ),
          Table(
            border: TableBorder.all(color: Colors.black),
            children: [
              TableRow(children: [
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        const Text(
                          "Fails:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: Get.width * 0.01,
                        ),
                        Text(
                          fails.toString(),
                        ),
                      ],
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        const Text(
                          "Passes:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: Get.width * 0.01,
                        ),
                        Text(
                          passes.toString(),
                        ),
                      ],
                    ),
                  ),
                ),
                TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        const Text(
                          "Score:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: Get.width * 0.01,
                        ),
                        Text(
                          '$score %',
                        ),
                      ],
                    ),
                  ),
                ),
              ])
            ],
          ),
        ],
      );

  Widget tableContent(String areaTitle, String fails, String passes,
          String score, List answers) =>
      Column(
        children: [
          tableHeader(areaTitle, fails, passes, score),
          Table(
            border: TableBorder.all(color: Colors.black),
            children: [
              const TableRow(
                decoration: BoxDecoration(color: appAccentColor),
                children: [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        "Item Descriptions",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        "Failure Reason",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        "Corrective Actions",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              for (var answer in answers)
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(answer['questionTitle'] ?? '-'),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          answer['failureReason'] ?? '-',
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          answer['correctiveAction'] ?? '-',
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(
            height: Get.height * 0.01,
          )
        ],
      );

  Widget header() => Container(
        padding: EdgeInsets.all(Get.width * 0.01),
        decoration: BoxDecoration(
            color: appAccentColor, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: Get.width * 0.08,
              height: Get.width * 0.07,
              child: Image.asset('assets/images/icleanLogo_white.png'),
            ),
            SizedBox(
              width: Get.width * 0.02,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "Site:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: Get.width * 0.01,
                    ),
                    Text(controller.currentInspectionDetails.value != null
                        ? controller
                            .currentInspectionDetails.value!['siteTitle']
                        : '-'),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Conducted Date:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: Get.width * 0.01,
                    ),
                    Text(controller.currentInspectionDetails.value != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(controller
                            .currentInspectionDetails.value!['conductedDate'])
                        : '-'),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Conducted By:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: Get.width * 0.01,
                    ),
                    Text(controller.currentInspectionDetails.value != null
                        ? controller
                            .currentInspectionDetails.value!['conductedBy']
                        : '-'),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Inspection Score:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: Get.width * 0.01,
                    ),
                    Text(controller.currentInspectionDetails.value != null
                        ? '${controller.currentInspectionDetails.value!['overallScore']} %'
                        : '-'),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Inspection Fail Rate:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: Get.width * 0.01,
                    ),
                    Text(controller.currentInspectionDetails.value != null
                        ? '${controller.currentInspectionDetails.value!['failRate']}'
                        : '-'),
                  ],
                )
              ],
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appPrimaryColor,
          foregroundColor: Colors.white,
          title: const Text(
            'Inspections',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        drawer: AppDrawer(
          activePage: Routes.INSPECTION,
        ),
        body: Column(
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
                    Text("Back To Inspections"),
                  ],
                )),
            Obx(() {
              if (controller.isLoading.value == true) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                final areaDetails = controller.areaDetails!.entries.toList();

                return Padding(
                    padding: EdgeInsets.all(Get.width * 0.02),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        header(),
                        SizedBox(
                          height: Get.height * 0.02,
                        ),
                        if (controller.areaDetails != null &&
                            controller.areaDetails!.isNotEmpty)
                          SizedBox(
                            height: Get.height * 0.65,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: areaDetails.length,
                              itemBuilder: (context, index) {
                                final entry = areaDetails[index];
                                String areaTitle =
                                    entry.value['areaTitle'] ?? '-';
                                Map areaScores =
                                    entry.value['areaScores'] ?? {};
                                String fail = areaScores.isNotEmpty
                                    ? areaScores['fail'].toString()
                                    : '-';
                                String pass = areaScores.isNotEmpty
                                    ? areaScores['pass'].toString()
                                    : '-';
                                String percentage = areaScores.isNotEmpty
                                    ? areaScores['percentage'].toString()
                                    : '-';
                                List answers = entry.value['answers'] ?? [];
                                if (answers.isNotEmpty) {
                                  return tableContent(areaTitle, fail, pass,
                                      percentage, answers);
                                } else {
                                  return const SizedBox();
                                }
                              },
                            ),
                          ),
                      ],
                    ));
              }
            }),
          ],
        ),
      ),
    );
  }
}
