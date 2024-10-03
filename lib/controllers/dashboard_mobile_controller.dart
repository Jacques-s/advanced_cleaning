import 'package:advancedcleaning/controllers/mobile_sync_controller.dart';
import 'package:advancedcleaning/models/site_model.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class DashboardMobileController extends GetxController {
  final AuthController authController = Get.find();
  final MobileSyncController syncController = Get.find();

  RxBool isLoading = false.obs;
  Rx<Site?> userSite = Rx<Site?>(null);
  RxList<Map> inspections = <Map>[].obs;

  @override
  void onInit() async {
    super.onInit();
    try {
      isLoading.value = true;
      await syncController.checkIfOutdated();
      await fetchInspections();
      final userSiteId = authController.currentUserSiteId;
      if (userSiteId != null) {
        userSite.value = await syncController.getSite(userSiteId);
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchInspections() async {
    try {
      inspections.value = await syncController.dashboardInspections();
    } catch (e) {
      print("Error getting inspections from local db, $e");
    }
  }
}

class DashboardMobileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardMobileController>(() => DashboardMobileController());
  }
}
