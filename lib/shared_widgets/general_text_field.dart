import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GeneralTextFormField extends StatelessWidget {
  const GeneralTextFormField(
      {required this.controller,
      required this.label,
      required this.validator,
      this.obscureText = false,
      this.borderColor = appPrimaryColor,
      this.borderWidth = 2,
      this.width,
      super.key});

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final Color borderColor;
  final double borderWidth;
  final double? width;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Get.width * 0.01),
      width: width ?? Get.width * 0.6,
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          label: Text(
            label,
            style: TextStyle(color: borderColor),
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
        ),
        obscureText: obscureText,
      ),
    );
  }
}
