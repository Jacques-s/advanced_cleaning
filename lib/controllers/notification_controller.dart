import 'package:advancedcleaning/controllers/mobile_controllers/mobile_sync_controller.dart';
import 'package:advancedcleaning/models/notification_model.dart';
import 'package:get/get.dart';

class AppNotificationController extends GetxController {
  final MobileSyncController _syncController = Get.find<MobileSyncController>();

  final RxBool isLoading = false.obs;
  final RxList<AppNotification> _notifications = RxList.empty();

  List<AppNotification> get notifications => _notifications;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    _notifications.value = await _syncController.getNotifications();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _syncController.markNotificationAsRead(notificationId);
    // Update the local notification state
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final updatedNotification = AppNotification(
        id: _notifications[index].id,
        userId: _notifications[index].userId,
        title: _notifications[index].title,
        message: _notifications[index].message,
        eventId: _notifications[index].eventId,
        createdAt: _notifications[index].createdAt,
        read: true,
        type: _notifications[index].type,
        accountId: _notifications[index].accountId,
        siteId: _notifications[index].siteId,
      );
      _notifications[index] = updatedNotification;
    }
  }
}

class AppNotificationControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppNotificationController>(() => AppNotificationController());
  }
}
