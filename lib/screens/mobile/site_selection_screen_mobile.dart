import 'package:advancedcleaning/app_router.dart';
import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/mobile_sync_controller.dart';
import 'package:advancedcleaning/models/site_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SiteSelectionScreenMobile extends GetView<MobileSyncController> {
  const SiteSelectionScreenMobile({super.key});

  void setSite(Site selectedSite) {
    controller.authController.setCurrentUserSiteId(selectedSite.id);
    Get.offAllNamed(Routes.DASHBOARD);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: appPrimaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          'Site Selection',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
          padding: EdgeInsets.all(Get.width * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(Get.width * 0.02),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: appPrimaryColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  'Please select a site to continue',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: Get.textScaleFactor * 16,
                      fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(
                height: Get.height * 0.02,
              ),
              if (controller.authController.currentSiteIds.isEmpty)
                Center(
                  child: Text(
                    'You do not have any sites linked to your profile. Please ask your administrator to link you to a site.',
                    style: TextStyle(
                      fontSize: Get.textScaleFactor * 14,
                    ),
                  ),
                )
              else
                FutureBuilder<List<Site>>(
                  future: controller.getUserSites(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Column(
                        children: [
                          const Text(
                              "No sites found for you. Speak to your administrator"),
                          TextButton(
                              onPressed: () {
                                Get.offAllNamed(Routes.DASHBOARD);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.arrow_back),
                                  SizedBox(width: Get.width * 0.01),
                                  const Text('Back')
                                ],
                              ))
                        ],
                      );
                    } else {
                      final sites = snapshot.data!;
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: sites.length,
                          itemBuilder: (_, index) {
                            final site = sites[index];
                            return Column(
                              children: [
                                ListTile(
                                  tileColor: appAccentColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  title: Text(
                                    site.title,
                                    textAlign: TextAlign.center,
                                  ),
                                  onTap: () {
                                    setSite(site);
                                  },
                                ),
                                SizedBox(
                                  height: Get.height * 0.01,
                                )
                              ],
                            );
                          });
                    }
                  },
                )
            ],
          )),
    ));
  }
}
