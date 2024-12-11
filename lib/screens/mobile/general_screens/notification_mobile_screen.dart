import 'package:advancedcleaning/controllers/notification_controller.dart';
import 'package:advancedcleaning/shared_widgets/app_drawer.dart';
import 'package:advancedcleaning/shared_widgets/general_submit_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../constants/app_constants.dart';

class MobileNotificationScreen extends GetView<AppNotificationController> {
  const MobileNotificationScreen({super.key});

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appPrimaryColor,
          foregroundColor: Colors.white,
          title: const Text('Notifications'),
          centerTitle: true,
        ),
        drawer: controller.isLoading.value == false
            ? AppDrawer(
                activePage: '/notifications',
              )
            : null,
        body: Column(
          children: [
            // Notifications list
            Expanded(
              child: Obx(() {
                if (controller.notifications.isEmpty) {
                  return const Center(
                    child: Text('No notifications'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: controller.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = controller.notifications[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatDate(notification.createdAt),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.message,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (!notification.read)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GeneralSubmitButton(
                                    onPress: () {
                                      controller.markNotificationAsRead(
                                          notification.id);
                                    },
                                    label: 'Mark as read',
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
