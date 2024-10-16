import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:advancedcleaning/models/chemical_log_model.dart';
import 'package:advancedcleaning/models/chemical_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChemicalMobileController extends GetxController {
  final AuthController authController = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;

  final _amountOfChemicalController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _testKitExpiryDateController = TextEditingController();
  final _amountOfWaterController = TextEditingController();
  final _issuedToController = TextEditingController();
  final _numberOfDropsController = TextEditingController();
  final _factorController = TextEditingController();
  final _verificationController = TextEditingController();
  final _correctiveActionController = TextEditingController();

  TextEditingController get amountOfChemicalController =>
      _amountOfChemicalController;
  String get amountOfChemical => _amountOfChemicalController.text;
  TextEditingController get batchNumberController => _batchNumberController;
  String get batchNumber => _batchNumberController.text;
  TextEditingController get expiryDateController => _expiryDateController;
  String get expiryDate => _expiryDateController.text;
  TextEditingController get testKitExpiryDateController =>
      _testKitExpiryDateController;
  String get testKitExpiryDate => _testKitExpiryDateController.text;
  TextEditingController get amountOfWaterController => _amountOfWaterController;
  String get amountOfWater => _amountOfWaterController.text;
  TextEditingController get issuedToController => _issuedToController;
  String get issuedTo => _issuedToController.text;
  TextEditingController get numberOfDropsController => _numberOfDropsController;
  String get numberOfDrops => _numberOfDropsController.text;
  TextEditingController get factorController => _factorController;
  String get factor => _factorController.text;
  TextEditingController get verificationController => _verificationController;
  String get verification => _verificationController.text;
  TextEditingController get correctiveActionController =>
      _correctiveActionController;
  String get correctiveAction => _correctiveActionController.text;
  @override
  void onClose() {
    _amountOfChemicalController.dispose();
    _batchNumberController.dispose();
    _expiryDateController.dispose();
    _testKitExpiryDateController.dispose();
    _amountOfWaterController.dispose();
    _issuedToController.dispose();
    _numberOfDropsController.dispose();
    _factorController.dispose();
    _verificationController.dispose();
    _correctiveActionController.dispose();
    super.onClose();
  }

  Future<void> createChemicalLog(Chemical chemical) async {
    try {
      isLoading.value = true;

      if (authController.currentAccountId == null) {
        Get.snackbar('Error', 'No account, please log out and log back in',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
        return;
      }

      if (authController.currentUserSiteId == null) {
        Get.snackbar('Error', 'No site, please log out and log back in',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
        return;
      }

      if (authController.currentUser == null) {
        Get.snackbar('Error', 'No user, please log out and log back in',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
        return;
      }

      ChemicalLog chemicalLog = ChemicalLog(
        id: '',
        createdAt: DateTime.now(),
        createdById: authController.currentUser!.id,
        createdName: authController.currentUser!.fullName,
        accountId: authController.currentAccountId!,
        siteId: authController.currentUserSiteId!,
        chemicalId: chemical.chemicalId,
        chemicalName: chemical.title,
        chemicalAmount: amountOfChemical,
        batchNumber: batchNumber,
        expiryDate: expiryDate,
        testKitExpiryDate: testKitExpiryDate,
        waterAmount: amountOfWater,
        issuedTo: issuedTo,
        numberOfDrops: numberOfDrops,
        factor: factor,
        verification: verification,
        correctiveAction: correctiveAction,
      );

      await _firestore
          .collection(chemicalLogPath)
          .add(chemicalLog.toFirestore());

      Get.snackbar('Success', 'Chemical log created successfully',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);

      Navigator.pop(Get.context!);
    } catch (e) {
      Get.snackbar('Error', 'Error creating chemical log: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }
}

class ChemicalMobileControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChemicalMobileController>(() => ChemicalMobileController());
  }
}
