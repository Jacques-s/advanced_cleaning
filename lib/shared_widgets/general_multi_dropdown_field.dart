import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class GeneralMultiSelectDropdownFormField extends StatelessWidget {
  const GeneralMultiSelectDropdownFormField(
      {required this.label,
      required this.options,
      required this.onSelect,
      required this.validator,
      required this.initialSelections,
      this.borderColor = appPrimaryColor,
      this.borderWidth = 2,
      this.width,
      super.key});

  final String label;
  final List<Map<String, String>> options;
  final List<String> initialSelections;
  final Color borderColor;
  final double borderWidth;
  final double? width;
  final Function(List<String>?)? onSelect;
  final String? Function(List<String>?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Get.width * 0.01),
      width: width ?? Get.width * 0.6,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
        ),
        child: MultiSelectDialogField(
          listType: MultiSelectListType.CHIP,
          title: Text(label),
          buttonText: Text(label),
          validator: validator,
          items: options.map((Map<String, String> item) {
            return MultiSelectItem<String>(
                item['id'] ?? '', item['title'] ?? '');
          }).toList(),
          initialValue: initialSelections,
          onConfirm: (value) => onSelect?.call(value),
          buttonIcon: const Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }
}
