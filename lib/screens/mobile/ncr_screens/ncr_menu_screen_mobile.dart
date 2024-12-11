import 'package:advancedcleaning/app_router.dart';
import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/mobile_controllers/ncr_update_controller.dart';
import 'package:advancedcleaning/models/ncr_models/client_ncr_model.dart';
import 'package:advancedcleaning/shared_widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NcrMenuScreenMobile extends GetView<NcrUpdateController> {
  const NcrMenuScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appPrimaryColor,
          foregroundColor: Colors.white,
          title: const Text(
            'NCR\'s',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Get.offAllNamed(Routes.CREATE_NCR);
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        drawer: AppDrawer(
          activePage: Routes.NCR_MENU,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return controller.userClientNcrs.isEmpty
              ? const Center(child: Text('No NCR\'s found'))
              : ListView.builder(
                  itemCount: controller.userClientNcrs.length,
                  itemBuilder: (context, index) {
                    final ncr = controller.userClientNcrs[index];
                    return _NcrCard(
                      ncr: ncr,
                      onTap: () {
                        controller.currentNcr.value = ncr;
                        Get.toNamed(Routes.NCR_VIEW);
                      },
                    );
                  },
                );
        }),
      ),
    );
  }
}

class _NcrCard extends StatelessWidget {
  const _NcrCard({super.key, required this.ncr, required this.onTap});

  final ClientNCR ncr;
  final VoidCallback onTap;
  final String _dateFormat = 'dd/MM/yyyy hh:mm a';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: appAccentColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              'Createdy: ${DateFormat(_dateFormat).format(ncr.createdAt)}',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: appPrimaryColor),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Submitted By",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: appPrimaryColor),
                ),
                Text(ncr.submittedBy ?? '')
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Submitter Role",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: appPrimaryColor),
                ),
                Text(ncr.userRole ?? '')
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Area",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: appPrimaryColor),
                ),
                Text(ncr.areaTitle ?? '')
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Status",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: appPrimaryColor),
                ),
                Text(ncr.status)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
