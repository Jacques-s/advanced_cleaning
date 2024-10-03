import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/inspection_mobile_controller.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:advancedcleaning/models/question_answer_model.dart';
import 'package:advancedcleaning/shared_widgets/general_submit_button.dart';
import 'package:advancedcleaning/shared_widgets/general_text_field.dart';
import 'package:advancedcleaning/shared_widgets/inspection_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';

class InspectionScreenMobile extends GetView<InspectionMobileController> {
  const InspectionScreenMobile({super.key});

  showFailDialog(QuestionAnswer question) {
    final GlobalKey<FormState> failFormKey = GlobalKey<FormState>();
    TextEditingController failReasonController = TextEditingController();
    TextEditingController failActionController = TextEditingController();

    failReasonController.text = question.failureReason ?? '';
    failActionController.text = question.correctiveAction ?? '';

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)), //this right here
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.all(Get.width * 0.04),
          child: Form(
            key: failFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  question.title,
                  style: TextStyle(
                      color: appPrimaryColor,
                      fontSize: Get.textScaleFactor * 16,
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(height: Get.height * 0.02),
                GeneralTextFormField(
                    width: Get.width * 0.8,
                    controller: failReasonController,
                    label: "Reason for failure",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'A reason is required';
                      }
                      return null;
                    }),
                GeneralTextFormField(
                    width: Get.width * 0.8,
                    controller: failActionController,
                    label: "Corrective action",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'A action is required';
                      }
                      return null;
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GeneralSubmitButton(
                      onPress: () => {Navigator.of(Get.overlayContext!).pop()},
                      label: 'Cancel',
                      backgroundColor: appDangerColor,
                    ),
                    GeneralSubmitButton(
                        onPress: () async {
                          await controller.updateAnswer(
                              question.frequency,
                              question.questionId,
                              InspectionResult.fail,
                              failReasonController.text,
                              failActionController.text);
                          Navigator.of(Get.overlayContext!).pop();
                        },
                        label: 'Submit'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showBarcodeScanner() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);

      if (barcodeScanRes.isNotEmpty && barcodeScanRes != '-1') {
        controller.currentAreaBarcode.value = barcodeScanRes;
        controller.fetchQuestions();
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
  }

  showConfirmExit() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)), //this right here
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.all(Get.width * 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure?',
                style: TextStyle(
                    fontSize: Get.textScaleFactor * 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: Get.height * 0.02,
              ),
              const Text(
                  'All your current progress will be lost if you close out of this inspection!'),
              SizedBox(
                height: Get.height * 0.01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GeneralSubmitButton(
                    onPress: () => {Get.back(closeOverlays: true)},
                    label: 'Cancel',
                    backgroundColor: appDangerColor,
                  ),
                  GeneralSubmitButton(
                      onPress: () {
                        controller.discardInspection();
                      },
                      label: 'Continue'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget submissionWidget() {
    final val = controller.hasOutstandingAreas();
    if (val == -1) {
      return const Center(
        child: Text('No areas for the current site'),
      );
    } else if (val == 0) {
      return Center(
          child: GeneralSubmitButton(
              label: 'Scan Area',
              onPress: () {
                showBarcodeScanner();
              }));
    } else {
      return Center(
        child: GeneralSubmitButton(
            label: 'Submit Inspection',
            onPress: () {
              controller.submitInspection();
            }),
      );
    }
  }

  int dataCount() =>
      controller.selectedFrequency.value == InspectionFrequency.daily.name
          ? controller.questions.length
          : controller.deepCleanQuestions.length;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appPrimaryColor,
          foregroundColor: Colors.white,
          title: const Text(
            'Inspection',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.exit_to_app_outlined),
            onPressed: () {
              showConfirmExit();
            },
          ),
          actions: [
            Obx(() {
              if (controller.currentAreaBarcode.value != null) {
                return IconButton(
                    onPressed: () {
                      controller.saveAreaQuestions();
                    },
                    icon: const Icon(Icons.save_outlined));
              } else {
                return const SizedBox();
              }
            })
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.isTrue) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (controller.currentAreaBarcode.value == null) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: Get.height * 0.01,
                  ),
                  submissionWidget(),
                  SizedBox(
                    height: Get.height * 0.01,
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: controller.outstandingAreas.length,
                        itemBuilder: (_, index) {
                          final item = controller.outstandingAreas[index];

                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: Get.width * 0.02,
                                vertical: Get.height * 0.006),
                            child: ListTile(
                              onTap: () {
                                //This is only for testing, you should comment it out!
                                controller.currentAreaBarcode.value =
                                    item['areaBarcode'];
                                controller.fetchQuestions();
                              },
                              title: Text(
                                item['areaTitle'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              leading: item['isCompleded'] != null
                                  ? const Icon(
                                      Icons.check,
                                      color: appSuccessColor,
                                    )
                                  : const Icon(
                                      Icons.close,
                                      color: appDangerColor,
                                    ),
                              tileColor: appAccentColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }),
                  )
                ],
              );
            } else {
              return Column(
                children: [
                  Container(
                    color: appPrimaryColor,
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(bottom: Get.width * 0.04),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: Get.width * 0.02),
                      child: Text(
                        controller.currentArea.value == null
                            ? ''
                            : controller.currentArea.value!.title,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: Get.textScaleFactor * 16,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () =>
                              controller.selectedFrequency.value = 'daily',
                          child: Column(
                            children: [
                              const Text(
                                'Daily',
                              ),
                              Container(
                                width: Get.width * 0.4,
                                height: 5,
                                color: controller.selectedFrequency.value ==
                                        'daily'
                                    ? appPrimaryColor
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              controller.selectedFrequency.value = '',
                          child: Column(
                            children: [
                              const Text(
                                'Deep Clean',
                              ),
                              Container(
                                width: Get.width * 0.4,
                                height: 5,
                                color: controller.selectedFrequency.value !=
                                        'daily'
                                    ? appPrimaryColor
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ]),
                  Expanded(
                    child: dataCount() == 0
                        ? const Center(child: Text('No questions'))
                        : ListView.builder(
                            itemCount: controller.selectedFrequency.value ==
                                    InspectionFrequency.daily.name
                                ? controller.questions.length
                                : controller.deepCleanQuestions.length,
                            itemBuilder: (context, index) {
                              QuestionAnswer question =
                                  controller.selectedFrequency.value ==
                                          InspectionFrequency.daily.name
                                      ? controller.questions[index]
                                      : controller.deepCleanQuestions[index];

                              return InspectionItem(
                                itemKey: ValueKey<String>(question.questionId),
                                label: question.title,
                                status: question.passStatus.name,
                                overdueStatus: question.overdueStatus(),
                                wasInspected:
                                    question.lastInspectionDate != null,
                                lastInspectedDate: question.lastInspectionDate,
                                nextInspectedDate: question.nextInspectionDate,
                                frequency: question.frequency,
                                lastInspectedResult:
                                    question.lastInspectionResult == null
                                        ? 'Not inspected yet'
                                        : question.lastInspectionResult!.name
                                                .capitalizeFirst ??
                                            '',
                                onDismissed: (direction) async {
                                  if (direction ==
                                      DismissDirection.startToEnd) {
                                    //pass
                                    question.passStatus = InspectionResult.pass;
                                    controller.updateAnswer(
                                        question.frequency,
                                        question.questionId,
                                        InspectionResult.pass,
                                        null,
                                        null);
                                  } else {
                                    //fail
                                    showFailDialog(question);
                                  }

                                  return Future.value(false);
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            }
          }
        }),
      ),
    );
  }
}
