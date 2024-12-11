import 'package:advancedcleaning/app_router.dart';
import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:advancedcleaning/controllers/mobile_controllers/mobile_sync_controller.dart';
import 'package:advancedcleaning/helpers/storage_helper.dart';
import 'package:advancedcleaning/models/area_model.dart';
import 'package:advancedcleaning/models/ncr_models/client_ncr_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class NcrCreateController extends GetxController {
  final _authController = Get.find<AuthController>();
  final _syncController = Get.find<MobileSyncController>();
  final StorageService _storageService = StorageService();

  final RxBool isLoading = false.obs;
  final Rx<InspectionArea?> currentArea = Rx<InspectionArea?>(null);
  final TextEditingController deviationController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final RxList<XFile> selectedImages = <XFile>[].obs;

  String get deviation => deviationController.text;
  String get comment => commentController.text;

  Future<void> getAreaByBarcode(String areaBarcode) async {
    currentArea.value =
        await _syncController.getLocalAreaByBarcode(areaBarcode);
  }

  Future<void> resetData() async {
    currentArea.value = null;
    deviationController.clear();
    commentController.clear();
    selectedImages.clear();
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
        '${currentArea.value!.accountId}/${currentArea.value!.siteId}/ClientNcrs';

    final List<String> uploadedImages = await _storageService.uploadImages(
        'ClientNcr', folderPath, platformFiles);
    return uploadedImages;
  }

  Future<void> saveNcr() async {
    try {
      isLoading.value = true;

      String? userId = _authController.currentUserId;

      if (deviation.isEmpty) {
        throw ('Please enter a deviation');
      }

      if (currentArea.value == null) {
        throw ('Make sure an area is selected');
      }

      if (userId == null) {
        throw ('Please login again (User)');
      }

      String? accountId = _authController.currentAccountId;
      String? siteId = _authController.currentUserSiteId;

      if (accountId == null) {
        throw ('Please login again (Account)');
      }

      if (siteId == null) {
        throw ('Please login again (Site)');
      }

      final List<String> uploadedImages = await uploadImages();

      final ClientNCR ncr = ClientNCR(
        id: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        areaId: currentArea.value!.id,
        areaTitle: currentArea.value!.title,
        accountId: accountId,
        siteId: siteId,
        submittedById: userId,
        submittedBy: _authController.currentUser!.fullName,
        userRole: _authController.currentUserRole!.name,
        status: 'pending',
        deviation: deviation,
        comment: comment,
        deviationImages: uploadedImages,
      );

      await _syncController.saveClientNcr(ncr);

      await resetData();
      Get.offAllNamed(Routes.DASHBOARD);
      Get.snackbar('NCR saved successfully', 'NCR saved successfully',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      print(e);
      Get.snackbar('Could not save NCR:', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}

class NcrCreateControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NcrCreateController());
  }
}
