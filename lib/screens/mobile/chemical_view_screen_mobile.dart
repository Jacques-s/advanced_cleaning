import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/checmical_mobile_controller.dart';
import 'package:advancedcleaning/models/chemical_model.dart';
import 'package:advancedcleaning/shared_widgets/general_date_field.dart';
import 'package:advancedcleaning/shared_widgets/general_submit_button.dart';
import 'package:advancedcleaning/shared_widgets/general_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChemicalViewScreenMobile extends GetView<ChemicalMobileController> {
  const ChemicalViewScreenMobile({
    super.key,
    required this.chemical,
  });

  final Chemical chemical;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appPrimaryColor,
          foregroundColor: Colors.white,
          title: const Text(
            'Verification Form',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(Get.width * 0.02),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(Get.width * 0.02),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: appAccentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 35,
                          child: Container(
                            padding: EdgeInsets.all(Get.width * 0.01),
                            child: Text(
                              'Chemical',
                              style: TextStyle(
                                fontSize: Get.textScaleFactor * 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 60,
                          child: Container(
                            padding: EdgeInsets.all(Get.width * 0.01),
                            child: Text(
                              chemical.title,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 35,
                          child: Container(
                            padding: EdgeInsets.all(Get.width * 0.01),
                            child: Text(
                              'Dilution',
                              style: TextStyle(
                                fontSize: Get.textScaleFactor * 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 60,
                          child: Container(
                            padding: EdgeInsets.all(Get.width * 0.01),
                            child: Text(
                              chemical.dilutionRange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Get.width * 0.02),
              Obx(
                () => Expanded(
                  child: controller.isLoading.value
                      ? Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GeneralTextFormField(
                                  label: 'Amount of Chemical',
                                  width: Get.width * 0.9,
                                  controller:
                                      controller.amountOfChemicalController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Amount of Chemical is required';
                                    }
                                    return null;
                                  },
                                ),
                                GeneralTextFormField(
                                  label: 'Batch Number',
                                  width: Get.width * 0.9,
                                  controller: controller.batchNumberController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Batch Number is required';
                                    }
                                    return null;
                                  },
                                ),
                                GeneralDateField(
                                  label: 'Expiry Date',
                                  width: Get.width * 0.9,
                                  controller: controller.expiryDateController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Expiry Date is required';
                                    }
                                    return null;
                                  },
                                ),
                                GeneralTextFormField(
                                  label: 'Amount of Water',
                                  width: Get.width * 0.9,
                                  controller:
                                      controller.amountOfWaterController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Amount of Water is required';
                                    }
                                    return null;
                                  },
                                ),
                                GeneralDateField(
                                  label: 'Test Kit Expiry Date',
                                  width: Get.width * 0.9,
                                  controller:
                                      controller.testKitExpiryDateController,
                                  validator: null,
                                ),
                                GeneralTextFormField(
                                  label: 'Issued To',
                                  width: Get.width * 0.9,
                                  controller: controller.issuedToController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Issued To is required';
                                    }
                                    return null;
                                  },
                                ),
                                GeneralTextFormField(
                                    label: 'Number of Drops',
                                    width: Get.width * 0.9,
                                    controller:
                                        controller.numberOfDropsController,
                                    isNumber: true,
                                    validator: null),
                                GeneralTextFormField(
                                    label: 'Factor',
                                    width: Get.width * 0.9,
                                    controller: controller.factorController,
                                    validator: null),
                                GeneralTextFormField(
                                  label: 'Verification',
                                  width: Get.width * 0.9,
                                  controller: controller.verificationController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Verification is required';
                                    }
                                    return null;
                                  },
                                ),
                                GeneralTextFormField(
                                  label: 'Corrective Action',
                                  width: Get.width * 0.9,
                                  isMultiline: true,
                                  controller:
                                      controller.correctiveActionController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Corrective Action is required';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: Get.width * 0.02),
                                GeneralSubmitButton(
                                  label: 'Submit',
                                  onPress: () {
                                    if (formKey.currentState!.validate()) {
                                      controller.createChemicalLog(chemical);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
