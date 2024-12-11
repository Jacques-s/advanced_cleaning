import 'package:advancedcleaning/app_router.dart';
import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/mobile_controllers/checmical_log_controller.dart';
import 'package:advancedcleaning/controllers/mobile_controllers/chemical_controller.dart';
import 'package:advancedcleaning/models/chemical_models/chemical_model.dart';
import 'package:advancedcleaning/screens/mobile/chemical_screens/chemical_view_screen_mobile.dart';
import 'package:advancedcleaning/shared_widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChemicalMenuScreenMobile extends GetView<ChemicalController> {
  const ChemicalMenuScreenMobile({super.key});

  Widget chemicalItem(Chemical chemical) {
    return InkWell(
      onTap: () {
        Get.to(() => ChemicalViewScreenMobile(chemical: chemical),
            binding: ChemicalLogControllerBinding());
      },
      child: Container(
        padding: EdgeInsets.all(Get.width * 0.02),
        decoration: BoxDecoration(
            border: Border.all(color: appAccentColor),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(chemical.title,
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
                      "Dilution Range",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: appPrimaryColor),
                    ),
                    Text(chemical.dilutionRange)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Description",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: appPrimaryColor),
                    ),
                    Text(chemical.description ?? '')
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
            'Chemicals',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        drawer: AppDrawer(
          activePage: Routes.CHEMICAL_MENU,
        ),
        body: Obx(() => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : controller.chemicals.isEmpty
                ? const Center(child: Text('No chemicals'))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: controller.searchController,
                          decoration: InputDecoration(
                            hintText: 'Search',
                          ),
                          onChanged: (value) {
                            controller.searchChemicals();
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: controller.filteredChemicals.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                chemicalItem(
                                    controller.filteredChemicals[index]),
                                SizedBox(
                                  height: Get.height * 0.02,
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  )),
      ),
    );
  }
}
