import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GeneralTextFormField extends StatelessWidget {
  const GeneralTextFormField({
    required this.controller,
    required this.label,
    required this.validator,
    this.obscureText = false,
    this.borderColor = appPrimaryColor,
    this.borderWidth = 2,
    this.width,
    this.height,
    this.isMultiline = false,
    super.key,
    this.readOnly = false,
    this.isNumber = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final Color borderColor;
  final double borderWidth;
  final double? width;
  final double? height;
  final bool isMultiline;
  final String? Function(String?)? validator;
  final bool readOnly;
  final bool isNumber;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Get.width * 0.01),
      width: width ?? Get.width * 0.6,
      height: isMultiline
          ? (height ?? Get.height * 0.15)
          : (height ?? Get.height * 0.1),
      child: TextFormField(
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        readOnly: readOnly,
        maxLines: isMultiline ? null : 1,
        minLines: isMultiline ? 3 : 1,
        keyboardType: isNumber
            ? TextInputType.number
            : isMultiline
                ? TextInputType.multiline
                : TextInputType.text,
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
        ),
        obscureText: obscureText,
      ),
    );
  }
}
