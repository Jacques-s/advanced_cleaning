import 'dart:io';

import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/mobile_controllers/ncr_update_controller.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:advancedcleaning/shared_widgets/general_submit_button.dart';
import 'package:advancedcleaning/shared_widgets/general_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NrcViewScreen extends GetView<NcrUpdateController> {
  const NrcViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appPrimaryColor,
          foregroundColor: Colors.white,
          title: const Text('NCR Details'),
          actions: [
            Obx(() {
              if (controller.formValid.value) {
                return IconButton(
                    onPressed: () {
                      controller.submitNCR();
                    },
                    icon: Icon(Icons.save));
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(Get.width * 0.05),
          child: Obx(
            () => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: Get.width * 0.02,
                              vertical: Get.height * 0.01),
                          decoration: BoxDecoration(
                            border: Border.all(color: appAccentColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Description',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: appPrimaryColor)),
                              SizedBox(height: Get.height * 0.01),
                              Text(
                                  controller.currentNcr.value?.deviation ?? ''),
                              SizedBox(height: Get.height * 0.01),
                              Text('Comment',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: appPrimaryColor)),
                              SizedBox(height: Get.height * 0.01),
                              Text(controller.currentNcr.value?.comment ?? ''),
                            ],
                          ),
                        ),
                        _NcrImages(
                            images:
                                controller.currentNcr.value?.deviationImages ??
                                    []),
                        _NcrAdditionals(),
                        _NcrActionForm(),
                        _AdditionalImages(),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _NcrImages extends StatelessWidget {
  const _NcrImages({super.key, required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Get.height * 0.02),
            Text('Provided Images',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: appPrimaryColor)),
            SizedBox(height: Get.height * 0.01),
            Text('No images provided'),
            SizedBox(height: Get.height * 0.02),
          ],
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Get.height * 0.02),
        Text('Provided Images',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: appPrimaryColor)),
        SizedBox(height: Get.height * 0.01),
        SizedBox(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Image.network(
                images[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
            },
          ),
        ),
        SizedBox(height: Get.height * 0.02),
      ],
    );
  }
}

class _NcrAdditionals extends GetView<NcrUpdateController> {
  const _NcrAdditionals({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.currentNcr.value?.userRole == UserRole.client.name) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NcrActionItem(
            title: 'Problem Statement',
            description: 'Clearly define the problem you\'re addressing',
            controller: controller.problemStatementController,
            onChanged: (_) {
              controller.validateForm();
            },
          ),
          SizedBox(height: Get.height * 0.01),
          _NcrActionItem(
            title: 'Why 1',
            description: 'Why did this problem occur?',
            controller: controller.whyOneController,
            onChanged: (_) {
              controller.validateForm();
            },
          ),
          _NcrActionItem(
            title: 'Why 2',
            description: 'Why did the reason in Why 1 occur?',
            controller: controller.whyTwoController,
            onChanged: (_) {
              controller.validateForm();
            },
          ),
          _NcrActionItem(
            title: 'Why 3',
            description: 'Why did the reason in Why 2 occur?',
            controller: controller.whyThreeController,
            onChanged: (_) {
              controller.validateForm();
            },
          ),
          _NcrActionItem(
            title: 'Why 4',
            description: 'Why did the reason in Why 3 occur?',
            controller: controller.whyFourController,
            onChanged: (_) {
              controller.validateForm();
            },
          ),
          _NcrActionItem(
            title: 'Why 5',
            description: 'Why did the reason in Why 4 occur?',
            controller: controller.whyFiveController,
            onChanged: (_) {
              controller.validateForm();
            },
          ),
          _NcrActionItem(
            title: 'Findings',
            description: 'What did you find?',
            controller: controller.findingsController,
            onChanged: (_) {
              controller.validateForm();
            },
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

class _NcrActionForm extends GetView<NcrUpdateController> {
  const _NcrActionForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          controller.ncrActions.isEmpty
              ? const SizedBox.shrink()
              : Container(
                  margin: EdgeInsets.only(bottom: Get.height * 0.02),
                  padding: EdgeInsets.symmetric(
                      horizontal: Get.width * 0.02,
                      vertical: Get.height * 0.01),
                  decoration: BoxDecoration(
                    border: Border.all(color: appAccentColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(children: [
                    Text('Actions Taken',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: appPrimaryColor)),
                    SizedBox(height: Get.height * 0.01),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.ncrActions.length,
                      itemBuilder: (context, index) {
                        return Container(
                            margin: EdgeInsets.only(bottom: Get.height * 0.01),
                            padding: EdgeInsets.symmetric(
                                horizontal: Get.width * 0.02,
                                vertical: Get.height * 0.01),
                            decoration: BoxDecoration(
                                color: appAccentColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(controller.ncrActions[index].action));
                      },
                    ),
                    SizedBox(height: Get.height * 0.01),
                  ]),
                ),
          GeneralTextFormField(
            width: double.infinity,
            controller: controller.actionTakenController,
            onChanged: (value) {
              controller.isValidAction.value = value.isNotEmpty;
            },
            label: 'New Action Taken',
            validator: null,
          ),
          SizedBox(height: Get.height * 0.01),
          Obx(() {
            if (controller.isValidAction.value) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GeneralSubmitButton(
                    onPress: () {
                      controller.cancelAction();
                    },
                    label: 'Clear Action',
                    backgroundColor: appDangerColor,
                  ),
                  GeneralSubmitButton(
                    onPress: () {
                      controller.addActionToNcr();
                    },
                    label: 'Save Action',
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      );
    });
  }
}

class _NcrActionItem extends StatelessWidget {
  const _NcrActionItem(
      {super.key,
      required this.title,
      required this.description,
      required this.controller,
      required this.onChanged});

  final String title;
  final String description;
  final TextEditingController controller;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Get.height * 0.01),
        Text(
          description,
        ),
        SizedBox(height: Get.height * 0.01),
        GeneralTextFormField(
          width: double.infinity,
          controller: controller,
          onChanged: onChanged,
          label: title,
          validator: null,
        ),
      ],
    );
  }
}

class _AdditionalImages extends GetView<NcrUpdateController> {
  const _AdditionalImages({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: appPrimaryColor,
          thickness: 2,
        ),
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
            return Container(
              height: 120,
              margin: EdgeInsets.only(bottom: Get.height * 0.01),
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
