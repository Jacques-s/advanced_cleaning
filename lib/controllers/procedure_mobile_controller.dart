import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:advancedcleaning/models/procedure_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ProcedureMobileController extends GetxController {
  final AuthController authController = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;

  RxList<Procedure> procedures = <Procedure>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProcedures();
  }

  void resetProcedures() async {
    procedures.clear();
    await fetchProcedures();
  }

  Future<void> fetchProcedures() async {
    isLoading.value = true;

    try {
      if (authController.currentAccountId == null) {
        Get.snackbar('Error', 'No account, please log out and log back in',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
        return;
      }

      Query query = _firestore
          .collection(procedurePath)
          .where('accountId', isEqualTo: authController.currentAccountId)
          .orderBy('createdAt', descending: true);

      QuerySnapshot querySnapshot = await query.get();

      procedures.value = querySnapshot.docs
          .map((doc) => Procedure.fromFirestore(doc))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Error loading procedures: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }
}

class ProcedureMobileControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProcedureMobileController>(() => ProcedureMobileController());
  }
}
