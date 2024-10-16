import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/models/chemical_model.dart';
import 'package:advancedcleaning/shared_widgets/general_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChemicalMultiTextField extends StatelessWidget {
  const ChemicalMultiTextField(
      {super.key,
      required this.items,
      required this.title,
      required this.label,
      required this.titleController,
      required this.dilutionRangeController,
      required this.onItemAdded,
      required this.onItemDeleted});

  final List<Chemical> items;
  final String title;
  final String label;
  final TextEditingController titleController;
  final TextEditingController dilutionRangeController;
  final Function(Chemical) onItemAdded;
  final Function(Chemical) onItemDeleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: Get.height * 0.01, horizontal: Get.width * 0.01),
      padding: EdgeInsets.all(Get.width * 0.01),
      decoration: BoxDecoration(
        border: Border.all(color: appPrimaryColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            child: Text(title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
          ),
          SizedBox(height: Get.height * 0.01),
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (items.isEmpty) Text('No items added yet'),
                  if (items.isNotEmpty)
                    ...items.asMap().entries.map((entry) {
                      int index = entry.key;
                      Chemical value = entry.value;

                      String chipText = '${index + 1}. ${value.title}';
                      if (value.dilutionRange.isNotEmpty) {
                        chipText += ' (${value.dilutionRange})';
                      }

                      return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: Get.width * 0.5,
                          ),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: Get.width * 0.01),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: appPrimaryColor, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    chipText,
                                    style: TextStyle(fontSize: 16),
                                    maxLines: null,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, size: 18),
                                  color: Colors.red,
                                  onPressed: () {
                                    onItemDeleted(value);
                                  },
                                ),
                              ],
                            ),
                          ));
                    }),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GeneralTextFormField(
                        controller: titleController,
                        width: Get.width * 0.25,
                        label: label,
                        validator: null,
                      ),
                      SizedBox(width: Get.width * 0.001),
                      GeneralTextFormField(
                        controller: dilutionRangeController,
                        width: Get.width * 0.25,
                        label: 'Dilution Range',
                        validator: null,
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle),
                        color: Colors.green,
                        onPressed: () {
                          String text = titleController.text;
                          String dilutionRange = dilutionRangeController.text;
                          if (text.isNotEmpty) {
                            onItemAdded(Chemical(
                              id: '',
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                              title: text,
                              dilutionRange: dilutionRange,
                            ));
                            titleController.clear();
                            dilutionRangeController.clear();
                          }
                        },
                      ),
                    ],
                  )
                ],
              )),
        ],
      ),
    );
  }
}
