import 'package:advancedcleaning/app_router.dart';
import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/procedure_mobile_controller.dart';
import 'package:advancedcleaning/models/procedure_model.dart';
import 'package:advancedcleaning/screens/mobile/procedures_view_screen_mobile.dart';
import 'package:advancedcleaning/shared_widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProceduresScreenMobile extends GetView<ProcedureMobileController> {
  const ProceduresScreenMobile({super.key});

  Widget procedureItem(Procedure procedure) {
    return InkWell(
      onTap: () {
        Get.to(() => ProceduresViewScreenMobile(procedure: procedure));
      },
      child: Container(
        padding: EdgeInsets.all(Get.width * 0.02),
        decoration: BoxDecoration(
            border: Border.all(color: appAccentColor),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(procedure.title,
                style: TextStyle(
                    fontSize: Get.textScaleFactor * 14,
                    fontWeight: FontWeight.bold,
                    color: appPrimaryColor)),
            const Divider(),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Area",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: appPrimaryColor),
                    ),
                    Text(procedure.areaTitle)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Frequency",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: appPrimaryColor),
                    ),
                    Text(procedure.frequencies.join(', '))
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: appPrimaryColor,
          foregroundColor: Colors.white,
          title: const Text(
            'Procedures',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        drawer: AppDrawer(
          activePage: Routes.PROCEDURE_MANAGEMENT,
        ),
        body: Obx(() => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: controller.procedures.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        procedureItem(controller.procedures[index]),
                        SizedBox(
                          height: Get.height * 0.02,
                        )
                      ],
                    );
                  },
                ),
              )),
      ),
    );
  }
}
