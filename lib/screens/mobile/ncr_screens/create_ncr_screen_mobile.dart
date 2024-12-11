import 'dart:io';

import 'package:advancedcleaning/app_router.dart';
import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/mobile_controllers/ncr_create_controller.dart';
import 'package:advancedcleaning/shared_widgets/general_submit_button.dart';
import 'package:advancedcleaning/shared_widgets/general_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class CreateNcrScreenMobile extends GetView<NcrCreateController> {
  const CreateNcrScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appPrimaryColor,
          foregroundColor: Colors.white,
          title: const Text(
            'Create NCR',
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
              if (controller.currentArea.value != null) {
                return IconButton(
                    onPressed: () {
                      controller.saveNcr();
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
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: Get.width * 0.02),
              child: SingleChildScrollView(child: _AreaWidget()),
            );
          }
        }),
      ),
    );
  }

  showConfirmExit() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              const Text('All your current progress will be lost!'),
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
                        Get.back(closeOverlays: true);
                        Get.offAllNamed(Routes.DASHBOARD);
                        controller.resetData();
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
}

class _AreaWidget extends GetView<NcrCreateController> {
  const _AreaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          if (controller.currentArea.value != null)
            Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: Get.height * 0.01),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: Get.width * 0.02),
                  decoration: BoxDecoration(
                      border: Border.all(color: appAccentColor),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Area: ${controller.currentArea.value!.title}'),
                      IconButton(
                          onPressed: () {
                            controller.resetData();
                          },
                          icon: const Icon(Icons.close))
                    ],
                  ),
                ),
                SizedBox(height: Get.height * 0.01),
                _NCRFormWidget(),
              ],
            ),
          if (controller.currentArea.value == null)
            Column(
              children: [
                SizedBox(height: Get.height * 0.01),
                Text('Scan the area to create an NCR'),
                SizedBox(height: Get.height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GeneralSubmitButton(
                      label: 'Scan Area',
                      onPress: () async {
                        // var barcodeScanRes = await SimpleBarcodeScanner.scanBarcode(
                        //     Get.context!,
                        //     lineColor: '#ff6666',
                        //     cancelButtonText: 'Cancel',
                        //     isShowFlashIcon: true,
                        //     scanType: ScanType.barcode);

                        // if (barcodeScanRes != null &&
                        //     barcodeScanRes.isNotEmpty &&
                        //     barcodeScanRes != '-1') {
                        //   controller.getAreaByBarcode(barcodeScanRes);
                        // }
                        controller.getAreaByBarcode('12345');
                      },
                    ),
                  ],
                ),
              ],
            ),
        ],
      );
    });
  }
}

class _NCRFormWidget extends GetView<NcrCreateController> {
  const _NCRFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'State the deviation as detailed as possible',
        ),
        SizedBox(height: Get.height * 0.01),
        GeneralTextFormField(
            controller: controller.deviationController,
            label: 'Deviation',
            isMultiline: true,
            width: double.infinity,
            validator: (value) {
              return null;
            }),
        GeneralTextFormField(
            controller: controller.commentController,
            label: 'General Comment',
            isMultiline: true,
            width: double.infinity,
            validator: (value) {
              return null;
            }),
        SizedBox(height: Get.height * 0.01),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: appPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              controller.takeImage();
            },
            child: const Icon(Icons.camera_alt_outlined)),
        SizedBox(height: Get.height * 0.01),
        Obx(() {
          if (controller.selectedImages.isNotEmpty) {
            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.selectedImages.length,
                itemBuilder: (context, index) {
                  final image = controller.selectedImages[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        Image.file(
                          File(image.path),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              controller.selectedImages.removeAt(index);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
