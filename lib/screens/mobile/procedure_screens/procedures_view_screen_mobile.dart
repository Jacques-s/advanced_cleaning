import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/mobile_controllers/checmical_log_controller.dart';
import 'package:advancedcleaning/models/procedure_model.dart';
import 'package:advancedcleaning/screens/mobile/chemical_screens/chemical_view_screen_mobile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProceduresViewScreenMobile extends StatelessWidget {
  const ProceduresViewScreenMobile({super.key, required this.procedure});

  final Procedure procedure;

  Widget rowItem(String title, String value) {
    return Row(
      children: [
        Expanded(
          flex: 35,
          child: Container(
            padding: EdgeInsets.all(Get.width * 0.01),
            child: Text(
              title,
              style: TextStyle(
                fontSize: Get.textScaleFactor * 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 60,
          child: Container(
            padding: EdgeInsets.all(Get.width * 0.01),
            child: Text(
              value,
            ),
          ),
        ),
      ],
    );
  }

  Widget instructions(String title, List<String> instructions) {
    if (instructions.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      children: [
        Center(
          child: Text(
            title,
            style: TextStyle(
                fontSize: Get.textScaleFactor * 16,
                fontWeight: FontWeight.bold),
          ),
        ),
        ...instructions.asMap().entries.map((entry) {
          final index = entry.key;
          final val = entry.value;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${index + 1}. ',
                style: TextStyle(
                    fontSize: Get.textScaleFactor * 14,
                    fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(
                  val,
                  softWrap: true,
                ),
              ),
            ],
          );
        }),
        Divider(),
      ],
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
            'Procedure',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(Get.width * 0.02),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                    child: Text(
                  procedure.title,
                  style: TextStyle(
                      fontSize: Get.textScaleFactor * 16,
                      fontWeight: FontWeight.bold),
                )),
                Divider(),
                rowItem('Area', procedure.areaTitle),
                Divider(),
                rowItem('Frequencies', procedure.frequencies.join(', ')),
                Divider(),
                rowItem(
                    'Cleaning Record',
                    procedure.cleaningRecord.isNotEmpty
                        ? procedure.cleaningRecord
                        : 'Not Assigned'),
                Divider(),
                rowItem(
                    'Maintenance Assistance', procedure.maintenanceAssistance),
                Divider(),
                rowItem(
                    'Responsibility',
                    procedure.responsibility.isNotEmpty
                        ? procedure.responsibility
                        : 'Not Assigned'),
                Divider(),
                rowItem('Inspected By', procedure.inspectedBy),
                Divider(),
                Center(
                  child: Text(
                    'Chemicals',
                    style: TextStyle(
                        fontSize: Get.textScaleFactor * 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                if (procedure.chemicals.isNotEmpty)
                  Column(
                    children: procedure.chemicals.map((chemical) {
                      return Row(
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Get.width * 0.02,
                                  vertical: Get.height * 0.01),
                              backgroundColor: appAccentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onPressed: () {
                              Get.to(
                                  () => ChemicalViewScreenMobile(
                                      chemical: chemical),
                                  binding: ChemicalLogControllerBinding());
                            },
                            child: Text(
                              '${chemical.title} - ${chemical.dilutionRange}',
                              softWrap: true,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                if (procedure.chemicals.isEmpty)
                  Center(
                    child: Text(
                      'No chemicals found',
                      style: TextStyle(fontSize: Get.textScaleFactor * 14),
                    ),
                  ),
                Divider(),
                Center(
                  child: Text(
                    'PPE Requirements & Safety Precautions',
                    style: TextStyle(
                        fontSize: Get.textScaleFactor * 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                if (procedure.safetyRequirements.isNotEmpty)
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: procedure.safetyRequirements.map((val) {
                      return Image.asset(
                        'assets/images/ppeIcons/$val.png',
                        width: 40,
                        height: 40,
                      );
                    }).toList(),
                  ),
                if (procedure.safetyRequirements.isEmpty)
                  Center(
                    child: Text(
                      'No safety requirements found',
                      style: TextStyle(fontSize: Get.textScaleFactor * 14),
                    ),
                  ),
                Divider(),
                Center(
                  child: Text(
                    'Colour Codes',
                    style: TextStyle(
                        fontSize: Get.textScaleFactor * 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                if (procedure.colourCodes.isNotEmpty)
                  Column(
                    children: procedure.colourCodes.map((val) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              val,
                              softWrap: true,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                if (procedure.colourCodes.isEmpty)
                  Center(
                    child: Text(
                      'No colour codes found',
                      style: TextStyle(fontSize: Get.textScaleFactor * 14),
                    ),
                  ),
                Divider(),
                Center(
                  child: Text(
                    'Application Equipment / Cleaning Materials',
                    style: TextStyle(
                        fontSize: Get.textScaleFactor * 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                if (procedure.equipmentRequired.isNotEmpty)
                  Column(
                    children: procedure.equipmentRequired.map((val) {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              val,
                              softWrap: true,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                if (procedure.equipmentRequired.isEmpty)
                  Center(
                    child: Text(
                      'No equipment found',
                      style: TextStyle(fontSize: Get.textScaleFactor * 14),
                    ),
                  ),
                Divider(),
                instructions('Daily Instructions', procedure.dailyInstructions),
                instructions(
                    'Weekly Instructions', procedure.weeklyInstructions),
                instructions(
                    'Monthly Instructions', procedure.monthlyInstructions),
                instructions(
                    'Quarterly Instructions', procedure.quarterlyInstructions),
                instructions(
                    'Yearly Instructions', procedure.yearlyInstructions),
                if (procedure.imageUrls.isNotEmpty)
                  Column(
                    children: procedure.imageUrls.map((val) {
                      return AspectRatio(
                        aspectRatio: 16 / 9,
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/placeholder.png',
                          image: val,
                          fit: BoxFit.contain,
                          fadeInDuration: Duration(milliseconds: 300),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
