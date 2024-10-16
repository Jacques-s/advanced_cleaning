import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/shared_widgets/general_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GeneralMultiTextField extends StatelessWidget {
  const GeneralMultiTextField(
      {super.key,
      required this.items,
      required this.title,
      required this.label,
      required this.controller,
      required this.onItemAdded,
      required this.onItemDeleted});

  final RxList<String> items;
  final String title;
  final String label;
  final TextEditingController controller;
  final Function(String) onItemAdded;
  final Function(String) onItemDeleted;

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
                      String value = entry.value;

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
                                    '${index + 1}. $value',
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
                        controller: controller,
                        width: Get.width * 0.5,
                        isMultiline: true,
                        label: label,
                        validator: null,
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle),
                        color: Colors.green,
                        onPressed: () {
                          String text = controller.text;
                          if (text.isNotEmpty) {
                            onItemAdded(text);
                            controller.clear();
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
