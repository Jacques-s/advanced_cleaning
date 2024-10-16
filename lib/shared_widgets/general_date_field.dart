import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GeneralDateField extends StatelessWidget {
  const GeneralDateField({
    required this.controller,
    required this.label,
    required this.validator,
    this.borderColor = appPrimaryColor,
    this.borderWidth = 2,
    this.width,
    this.height,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final Color borderColor;
  final double borderWidth;
  final double? width;
  final double? height;
  final String? Function(String?)? validator;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Get.width * 0.01),
      width: width ?? Get.width * 0.6,
      height: height ?? Get.height * 0.1,
      child: TextFormField(
        controller: controller,
        validator: validator,
        readOnly: true,
        onTap: () => _selectDate(context),
        decoration: InputDecoration(
          label: Text(
            label,
            style: TextStyle(color: borderColor),
          ),
          alignLabelWithHint: true,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
          suffixIcon: Icon(Icons.calendar_today),
        ),
      ),
    );
  }
}
