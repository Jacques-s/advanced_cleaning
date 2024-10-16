import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/dashboard_controller.dart';
import 'package:advancedcleaning/models/answer_model.dart';
import 'package:advancedcleaning/models/chemical_log_model.dart';
import 'package:advancedcleaning/models/corrective_action_model.dart';
import 'package:advancedcleaning/models/question_model.dart';
import 'package:advancedcleaning/shared_widgets/app_drawer.dart';
import 'package:advancedcleaning/shared_widgets/dashboard_reports.dart/checklist_report.dart';
import 'package:advancedcleaning/shared_widgets/dashboard_reports.dart/chemical_log_report.dart';
import 'package:advancedcleaning/shared_widgets/dashboard_reports.dart/failure_report.dart';
import 'package:advancedcleaning/shared_widgets/dashboard_reports.dart/issues_actions_report.dart';
import 'package:advancedcleaning/shared_widgets/dashboard_reports.dart/site_status_report.dart';
import 'package:advancedcleaning/shared_widgets/dashboard_reports.dart/top_issues_report.dart';
import 'package:advancedcleaning/shared_widgets/dashboard_reports.dart/verification_report.dart';
import 'package:advancedcleaning/shared_widgets/general_submit_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreenDesktop extends GetView<DashboardController> {
  DashboardScreenDesktop({super.key});

  final List<DashboardMenuItem> reportMenuItems = [
    DashboardMenuItem('site_status', 'Site Status'),
    DashboardMenuItem('verification', 'Verification'),
    DashboardMenuItem('checklist', 'Checklist'),
    DashboardMenuItem('failures', 'Failures'),
    DashboardMenuItem('top_issues', 'Top Issues'),
    DashboardMenuItem('issue_actions', 'Issue Actions'),
    DashboardMenuItem('chemical_logs', 'Chemical Logs'),
  ];

  void startDatePicker(BuildContext context) async {
    DateTime firstDate =
        DateTime.now().subtract(const Duration(days: 1825)); //5 years
    DateTime? startDate = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: DateTime.now(),
    );
    if (controller.selectedReport.value == 'checklist' ||
        controller.selectedReport.value == 'top_issues' ||
        controller.selectedReport.value == 'issue_actions') {
      if (startDate != null) {
        controller.startDate.value =
            DateTime(startDate.year, startDate.month, 1);
        DateTime nextMonth = DateTime(startDate.year, startDate.month + 1, 1);
        controller.endDate.value = nextMonth.subtract(const Duration(days: 1));
      }
    } else {
      controller.startDate.value = startDate;
    }
  }

  void endDatePicker(BuildContext context) async {
    if (controller.selectedReport.value != 'checklist' ||
        controller.selectedReport.value != 'top_issues' ||
        controller.selectedReport.value != 'issue_actions') {
      DateTime firstDate =
          DateTime.now().subtract(const Duration(days: 1825)); //5 years
      DateTime? selectedDate = await showDatePicker(
          context: context, firstDate: firstDate, lastDate: DateTime.now());
      if (selectedDate != null) {
        controller.endDate.value = DateTime(selectedDate.year,
            selectedDate.month, selectedDate.day, 23, 59, 59);
      }
    }
  }

  Widget renderReport() {
    switch (controller.selectedReport.value) {
      case 'site_status':
        {
          return FutureBuilder<Map<String, List<InspectionQuestion>>>(
              future: controller.fetchSiteStatusReport(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No items found"),
                  );
                } else {
                  final answers = snapshot.data;
                  return SiteStatusReport(answers: answers!);
                }
              });
        }

      case 'verification':
        {
          return FutureBuilder<
                  Map<String, Map<String, List<InspectionQuestion>>>>(
              future: controller.fetchVerificationReport(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No items found"),
                  );
                } else {
                  final answers = snapshot.data;
                  return VerificationReport(answers: answers!);
                }
              });
        }
      case 'checklist':
        {
          controller.fetchChecklistReport();
          if (controller.startDate.value != null) {
            return FutureBuilder<Map<String, dynamic>>(
                future: controller.fetchChecklistReport(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No items found"),
                    );
                  } else {
                    final answers = snapshot.data;
                    return ChecklistReport(
                        reportMonth: controller.startDate.value!,
                        answers: answers!);
                  }
                });
          }
          return const SizedBox();
        }
      case 'failures':
        {
          return FutureBuilder<
                  Map<String, Map<String, List<InspectionAnswer>>>>(
              future: controller.fetchFailureReport(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No items found"),
                  );
                } else {
                  final answers = snapshot.data;
                  return FailureReport(answers: answers!);
                }
              });
        }
      case 'top_issues':
        {
          return FutureBuilder<Map<String, Map<String, dynamic>>>(
              future: controller.fetchTopIsuesReport(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No items found"),
                  );
                } else {
                  final answers = snapshot.data;
                  return TopIssuesReport(answers: answers!);
                }
              });
        }
      case 'issue_actions':
        {
          return FutureBuilder<Map<String, List<CorrectiveAction>>>(
              future: controller.fetchIssueActionsReport(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No items found"),
                  );
                } else {
                  final answers = snapshot.data;
                  return IssueActionsReport(answers: answers!);
                }
              });
        }
      case 'chemical_logs':
        {
          return FutureBuilder<List<ChemicalLog>>(
              future: controller.fetchChemicalLogsReport(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return ChemicalLogReport(logs: snapshot.data!);
                }
              });
        }
      default:
        return const SizedBox();
    }
  }

  void generateReport() {
    switch (controller.selectedReport.value) {
      case 'site_status':
        {
          break;
        }
      case 'verification':
        {
          controller.generateVerificationPDF();
          break;
        }
      case 'checklist':
        {
          controller.generateChecklistPDF();
          break;
        }
      case 'failures':
        {
          controller.generateFailurePDF();
          break;
        }
      case 'top_issues':
        {
          controller.generateTopIssuesPDF();
          break;
        }
      case 'issue_actions':
        {
          controller.generateIssueActionsPDF();
          break;
        }
      default:
        {
          break;
        }
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
                'Dashbaord',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Text(controller.authController.currentUser != null
                      ? controller.authController.currentUser!.fullName
                      : 'Unknown'),
                ),
              ],
            ),
            drawer: AppDrawer(
              activePage: '/dashboard',
            ),
            body: Padding(
              padding: EdgeInsets.all(Get.width * 0.02),
              child: Obx(
                () => Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                          horizontal: Get.width * 0.01,
                          vertical: Get.height * 0.01),
                      decoration: BoxDecoration(
                        color: appAccentColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        runAlignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Report',
                                style: TextStyle(
                                    fontSize: Get.textScaleFactor * 14),
                              ),
                              SizedBox(
                                width: Get.width * 0.005,
                              ),
                              DropdownMenu<DashboardMenuItem>(
                                enableSearch: false,
                                hintText: 'Report',
                                requestFocusOnTap: true,
                                enableFilter: false,
                                onSelected: (value) {
                                  if (value != null) {
                                    controller.selectedReport.value = value.id;
                                    //Reset the dates when changing the report type
                                    controller.startDate.value = null;
                                    controller.endDate.value = null;
                                  }
                                },
                                dropdownMenuEntries: reportMenuItems
                                    .map<DropdownMenuEntry<DashboardMenuItem>>(
                                        (DashboardMenuItem menu) {
                                  return DropdownMenuEntry<DashboardMenuItem>(
                                    value: menu,
                                    label: menu.title,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Site Filter',
                                style: TextStyle(
                                    fontSize: Get.textScaleFactor * 14),
                              ),
                              SizedBox(
                                width: Get.width * 0.005,
                              ),
                              DropdownMenu<DashboardMenuItem>(
                                enableSearch: true,
                                hintText: 'Site',
                                requestFocusOnTap: true,
                                enableFilter: true,
                                onSelected: (value) {
                                  if (value != null) {
                                    controller.selectedSiteId.value = value.id;
                                    controller.selectedSiteTitle.value =
                                        value.title;

                                    //reset the areas if the site is changed
                                    controller.siteAreas.clear();
                                    controller.siteQuestions.clear();
                                  }
                                },
                                dropdownMenuEntries: controller.siteMenuItems
                                    .map<DropdownMenuEntry<DashboardMenuItem>>(
                                        (DashboardMenuItem menu) {
                                  return DropdownMenuEntry<DashboardMenuItem>(
                                    value: menu,
                                    label: menu.title,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          if (controller.selectedReport.value != 'site_status')
                            Wrap(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Start Date',
                                      style: TextStyle(
                                          fontSize: Get.textScaleFactor * 14),
                                    ),
                                    SizedBox(
                                      width: Get.width * 0.005,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        startDatePicker(context);
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsets.all(Get.width * 0.008),
                                        width: Get.width * 0.10,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black38,
                                                width: 1.2),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child:
                                            Text(controller.formattedStartDate),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: Get.width * 0.005,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'End Date',
                                      style: TextStyle(
                                          fontSize: Get.textScaleFactor * 14),
                                    ),
                                    SizedBox(
                                      width: Get.width * 0.005,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        endDatePicker(context);
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsets.all(Get.width * 0.008),
                                        width: Get.width * 0.10,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black38,
                                                width: 1.2),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child:
                                            Text(controller.formattedEndDate),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          GeneralSubmitButton(
                              onPress: () {
                                bool valid = true;

                                if (controller.selectedReport.value !=
                                    'site_status') {
                                  if (controller.startDate.value == null ||
                                      controller.endDate.value == null) {
                                    valid = false;
                                    Get.snackbar('Missing fields',
                                        'Please make sure that you specify a start and end date',
                                        duration: appSnackBarDuration,
                                        backgroundColor: appSnackBarColor);
                                  } else if (controller.endDate.value!
                                      .isBefore(controller.startDate.value!)) {
                                    valid = false;
                                    Get.snackbar('Invalid fields',
                                        'Please make sure that the end date is less than the start date',
                                        duration: appSnackBarDuration,
                                        backgroundColor: appSnackBarColor);
                                  }
                                }

                                if (controller.selectedSiteId.value == null) {
                                  valid = false;
                                  Get.snackbar('Missing fields',
                                      'Please make sure to select a site',
                                      duration: appSnackBarDuration,
                                      backgroundColor: appSnackBarColor);
                                }

                                if (controller.selectedSiteId.value == null) {
                                  valid = false;
                                  Get.snackbar('Missing fields',
                                      'Please make sure to select a report',
                                      duration: appSnackBarDuration,
                                      backgroundColor: appSnackBarColor);
                                }

                                if (valid == true) {
                                  controller.currentReportWidget.value =
                                      renderReport();
                                }
                              },
                              label: 'Filter'),
                          if (controller.selectedReport.value != null &&
                              controller.selectedReport.value != 'site_status')
                            GeneralSubmitButton(
                              onPress: () {
                                bool valid = true;

                                if (controller.selectedReport.value !=
                                    'site_status') {
                                  if (controller.startDate.value == null ||
                                      controller.endDate.value == null) {
                                    valid = false;
                                    Get.snackbar('Missing fields',
                                        'Please make sure that you specify a start and end date',
                                        duration: appSnackBarDuration,
                                        backgroundColor: appSnackBarColor);
                                  } else if (controller.endDate.value!
                                      .isBefore(controller.startDate.value!)) {
                                    valid = false;
                                    Get.snackbar('Invalid fields',
                                        'Please make sure that the end date is less than the start date',
                                        duration: appSnackBarDuration,
                                        backgroundColor: appSnackBarColor);
                                  }
                                }

                                if (controller.selectedSiteId.value == null) {
                                  valid = false;
                                  Get.snackbar('Missing fields',
                                      'Please make sure to select a site',
                                      duration: appSnackBarDuration,
                                      backgroundColor: appSnackBarColor);
                                }

                                if (controller.selectedSiteId.value == null) {
                                  valid = false;
                                  Get.snackbar('Missing fields',
                                      'Please make sure to select a report',
                                      duration: appSnackBarDuration,
                                      backgroundColor: appSnackBarColor);
                                }

                                if (valid == true) {
                                  generateReport();
                                }
                              },
                              label: 'Download PDF',
                              isLoading: controller.isLoading.value,
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Get.height * 0.01,
                    ),
                    Expanded(
                        child: SingleChildScrollView(
                            child: controller.currentReportWidget.value))
                  ],
                ),
              ),
            )));
  }
}
