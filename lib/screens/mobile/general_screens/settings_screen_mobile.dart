import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/mobile_controllers/mobile_sync_controller.dart';
import 'package:advancedcleaning/shared_widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SettingsScreenMobile extends GetView<MobileSyncController> {
  const SettingsScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: appPrimaryColor,
              foregroundColor: Colors.white,
              title: const Text(
                'Settings',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            drawer: AppDrawer(
              activePage: '/settings',
            ),
            body: Padding(
              padding: EdgeInsets.all(Get.width * 0.02),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: Get.width * 0.02,
                          horizontal: Get.width * 0.02),
                      padding: EdgeInsets.symmetric(
                          vertical: Get.width * 0.02,
                          horizontal: Get.width * 0.04),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: appAccentColor, width: 2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Logged in as:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(controller.authController.currentUser == null
                                  ? 'Unknown'
                                  : controller
                                      .authController.currentUser!.fullName)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Last synced:',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(controller.authController.currentUser ==
                                          null ||
                                      controller.authController.currentUser!
                                              .lastSynced ==
                                          null
                                  ? 'Unknown'
                                  : DateFormat('y-MM-dd H:s').format(controller
                                      .authController.currentUser!.lastSynced!))
                            ],
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => controller.isLoading.value == true
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Column(
                              children: [
                                SizedBox(
                                  height: Get.height * 0.02,
                                ),
                                TextButton(
                                    onPressed: () async {
                                      await controller.pullSync();
                                    },
                                    child: Container(
                                        width: Get.width * 0.7,
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: Get.width * 0.02,
                                            vertical: Get.width * 0.02),
                                        decoration: BoxDecoration(
                                            color: appAccentColor,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Text(
                                          'Sync From Server',
                                          style: TextStyle(
                                              fontSize:
                                                  Get.textScaleFactor * 18,
                                              color: Colors.black),
                                        ))),
                                TextButton(
                                  onPressed: () async {
                                    await controller.pushAllInspections();
                                  },
                                  child: Container(
                                    width: Get.width * 0.7,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: Get.width * 0.02,
                                        vertical: Get.width * 0.02),
                                    decoration: BoxDecoration(
                                        color: appAccentColor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Text(
                                      'Push To Server',
                                      style: TextStyle(
                                          fontSize: Get.textScaleFactor * 18,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: Get.height * 0.04,
                                ),
                                TextButton(
                                    onPressed: () {
                                      Get.defaultDialog(
                                        title: 'Are you sure',
                                        middleText:
                                            'This will delete the entire local database and can not be undone!',
                                        onCancel: () {
                                          Get.back();
                                        },
                                        onConfirm: () async {
                                          await controller.deleteDatabaseFile();
                                          Navigator.of(Get.overlayContext!)
                                              .pop();
                                        },
                                      );
                                    },
                                    child: Container(
                                        width: Get.width * 0.7,
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: Get.width * 0.02,
                                            vertical: Get.width * 0.02),
                                        decoration: BoxDecoration(
                                            color: appAccentColor,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Text(
                                          'Clear Database',
                                          style: TextStyle(
                                              fontSize:
                                                  Get.textScaleFactor * 18,
                                              color: Colors.black),
                                        ))),
                                TextButton(
                                    onPressed: () async {
                                      await controller.getDbPath();
                                    },
                                    child: Container(
                                        width: Get.width * 0.7,
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: Get.width * 0.02,
                                            vertical: Get.width * 0.02),
                                        decoration: BoxDecoration(
                                            color: appAccentColor,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Text(
                                          'Show Database Path',
                                          style: TextStyle(
                                              fontSize:
                                                  Get.textScaleFactor * 18,
                                              color: Colors.black),
                                        ))),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            )));
  }
}
