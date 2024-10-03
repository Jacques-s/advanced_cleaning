import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GeneralDropdownFormField extends StatelessWidget {
  const GeneralDropdownFormField(
      {required this.label,
      required this.options,
      required this.onSelect,
      required this.validator,
      this.initialSelection,
      this.borderColor = appPrimaryColor,
      this.borderWidth = 2,
      this.width,
      super.key});

  final String label;
  final List<Map<String, String>> options;
  final String? initialSelection;
  final Color borderColor;
  final double borderWidth;
  final double? width;
  final Function(String?)? onSelect;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Get.width * 0.01),
      width: width ?? Get.width * 0.6,
      child: SizedBox(
        width: double.infinity,
        child: DropdownButtonFormField<String>(
          validator: validator,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor, width: borderWidth),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor, width: borderWidth),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor, width: borderWidth),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red, width: borderWidth),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red, width: borderWidth),
              ),
              labelText: label,
              labelStyle: TextStyle(color: borderColor)),
          items: options.map((Map<String, String> item) {
            return DropdownMenuItem<String>(
              value: item['id'],
              child: Text(item['title'].toString()),
            );
          }).toList(),
          value: initialSelection,
          onChanged: (value) => onSelect?.call(value),
        ),
      ),
    );
  }
}
