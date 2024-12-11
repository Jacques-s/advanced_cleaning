import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:advancedcleaning/models/chemical_models/chemical_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChemicalController extends GetxController {
  final AuthController authController = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;

  RxList<Chemical> chemicals = <Chemical>[].obs;
  RxList<Chemical> filteredChemicals = <Chemical>[].obs;
  final TextEditingController searchController = TextEditingController();

  String get searchText => searchController.text;

  @override
  void onInit() {
    super.onInit();
    fetchChemicals();
  }

  void resetChemicals() async {
    chemicals.clear();
    await fetchChemicals();
  }

  Future<void> fetchChemicals() async {
    isLoading.value = true;

    try {
      if (authController.currentAccountId == null) {
        Get.snackbar('Error', 'No account, please log out and log back in',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
        return;
      }

      Query query = _firestore
          .collection(chemicalPath)
          .where('accountId', isEqualTo: authController.currentAccountId)
          .orderBy('createdAt', descending: false);

      QuerySnapshot querySnapshot = await query.get();

      chemicals.value =
          querySnapshot.docs.map((doc) => Chemical.fromFirestore(doc)).toList();
      filteredChemicals.value = chemicals;
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Error loading procedures: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  void searchChemicals() {
    filteredChemicals.value = chemicals
        .where((chemical) => chemical.title.contains(searchText))
        .toList();
  }
}

class ChemicalMobileControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChemicalController>(() => ChemicalController());
  }
}
