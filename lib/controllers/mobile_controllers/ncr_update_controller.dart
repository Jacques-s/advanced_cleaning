import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:advancedcleaning/controllers/mobile_controllers/mobile_sync_controller.dart';
import 'package:advancedcleaning/helpers/message_helper.dart';
import 'package:advancedcleaning/helpers/storage_helper.dart';
import 'package:advancedcleaning/models/ncr_models/ncr_action_model.dart';
import 'package:advancedcleaning/models/ncr_models/client_ncr_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class NcrUpdateController extends GetxController {
  final _authController = Get.find<AuthController>();
  final _syncController = Get.find<MobileSyncController>();
  final StorageService _storageService = StorageService();

  final RxBool isLoading = false.obs;
  final RxList<ClientNCR> userClientNcrs = RxList.empty();
  final RxList<NcrAction> ncrActions = RxList.empty();
  final Rx<ClientNCR?> currentNcr = Rx<ClientNCR?>(null);
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final TextEditingController problemStatementController =
      TextEditingController();
  final TextEditingController whyOneController = TextEditingController();
  final TextEditingController whyTwoController = TextEditingController();
  final TextEditingController whyThreeController = TextEditingController();
  final TextEditingController whyFourController = TextEditingController();
  final TextEditingController whyFiveController = TextEditingController();
  final TextEditingController findingsController = TextEditingController();

  final TextEditingController actionTakenController = TextEditingController();
  final RxBool isValidAction = false.obs;
  final RxBool formValid = false.obs;

  AuthController get authController => _authController;
  String get actionTaken => actionTakenController.text;
  String get problemStatement => problemStatementController.text;
  String get whyOne => whyOneController.text;
  String get whyTwo => whyTwoController.text;
  String get whyThree => whyThreeController.text;
  String get whyFour => whyFourController.text;
  String get whyFive => whyFiveController.text;
  String get findings => findingsController.text;
  @override
  void onInit() {
    super.onInit();
    fetchUserClientNcrs();
  }

  @override
  void onClose() {
    actionTakenController.dispose();
    problemStatementController.dispose();
    whyOneController.dispose();
    whyTwoController.dispose();
    whyThreeController.dispose();
    whyFourController.dispose();
    whyFiveController.dispose();
    findingsController.dispose();
    super.onClose();
  }

  Future<void> fetchUserClientNcrs() async {
    // try {
    //   isLoading.value = true;
    userClientNcrs.clear();
    final List<ClientNCR> ncrs = await _syncController.fetchUserClientNcrs();
    userClientNcrs.value = ncrs;
    // } catch (e) {
    //   Get.snackbar('Error fetching NCRs', e.toString(),
    //       backgroundColor: Colors.red, colorText: Colors.white);
    // } finally {
    //   isLoading.value = false;
    // }
  }

  Future<void> takeImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? response = await picker.pickImage(source: ImageSource.camera);
    if (response != null) {
      selectedImages.add(response);
    }
  }

  Future<List<String>> uploadImages() async {
    final platformFiles = selectedImages
        .map((xFile) => PlatformFile(
              path: xFile.path,
              name: xFile.name,
              size: 0,
            ))
        .toList();

    final folderPath =
        '${currentNcr.value!.accountId}/${currentNcr.value!.siteId}/ActionImages';

    final List<String> uploadedImages = await _storageService.uploadImages(
        'ClientNcr', folderPath, platformFiles);
    return uploadedImages;
  }

  //Add an action to the current NCR
  Future<void> addActionToNcr() async {
    try {
      isLoading.value = true;

      if (currentNcr.value == null) {
        throw ('No NCR selected');
      }

      final currentUser = _authController.currentUser;

      if (currentUser == null) {
        throw ('Please login again');
      }

      final NcrAction action = NcrAction(
        createdAt: DateTime.now(),
        action: actionTaken,
        submittedById: currentUser.id,
        submittedBy: currentUser.fullName,
      );

      ncrActions.add(action);
      MessageHelper.showSuccessMessage('Action added');
      validateForm();
      cancelAction();
    } catch (e) {
      MessageHelper.showErrorMessage(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  //Submit the current NCR
  Future<void> submitNCR() async {
    if (currentNcr.value == null) {
      throw ('No NCR selected');
    }

    try {
      isLoading.value = true;

      final currentUser = _authController.currentUser;
      if (currentUser == null) {
        throw ('Please login again');
      }

      final uploadedImages = await uploadImages();

      currentNcr.value!.ncrActions.addAll(ncrActions);
      currentNcr.value!.actionImages = uploadedImages;
      currentNcr.value!.problemStatement = problemStatement;
      currentNcr.value!.whyOne = whyOne;
      currentNcr.value!.whyTwo = whyTwo;
      currentNcr.value!.whyThree = whyThree;
      currentNcr.value!.whyFour = whyFour;
      currentNcr.value!.whyFive = whyFive;
      currentNcr.value!.findings = findings;
      currentNcr.value!.status = 'completed';

      await _syncController.updateClientNcr(currentNcr.value!);
      resetData();
      Get.back();
      fetchUserClientNcrs();
      MessageHelper.showSuccessMessage('Ncr submitted');
    } catch (e) {
      MessageHelper.showErrorMessage(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetData() async {
    selectedImages.clear();
    actionTakenController.clear();
    problemStatementController.clear();
    whyOneController.clear();
    whyTwoController.clear();
    whyThreeController.clear();
    whyFourController.clear();
    whyFiveController.clear();
    findingsController.clear();
    currentNcr.value = null;
  }

  Future<void> validateForm() async {
    if (currentNcr.value != null) {
      if (currentNcr.value!.userRole == 'client') {
        if (ncrActions.isNotEmpty &&
            problemStatement.isNotEmpty &&
            whyOne.isNotEmpty &&
            whyTwo.isNotEmpty &&
            whyThree.isNotEmpty &&
            whyFour.isNotEmpty &&
            whyFive.isNotEmpty &&
            findings.isNotEmpty) {
          formValid.value = true;
        } else {
          formValid.value = false;
        }
      } else {
        if (ncrActions.isNotEmpty) {
          formValid.value = true;
        } else {
          formValid.value = false;
        }
      }
    } else {
      formValid.value = false;
    }
  }

  Future<void> cancelAction() async {
    actionTakenController.clear();
    isValidAction.value = false;
  }
}

class NcrUpdateControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NcrUpdateController());
  }
}
