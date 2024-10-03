import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GeneralSubmitButton extends StatelessWidget {
  GeneralSubmitButton(
      {required this.onPress,
      required this.label,
      this.backgroundColor = appPrimaryColor,
      this.textColor = Colors.white,
      this.isLoading = false,
      super.key});
  final VoidCallback? onPress;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize = !kIsWeb ? 16 : Get.textScaleFactor * 14;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPress,
      style: ElevatedButton.styleFrom(backgroundColor: backgroundColor),
      child: isLoading
          ? SizedBox(
              height: fontSize,
              width: fontSize,
              child: const CircularProgressIndicator())
          : Text(
              label,
              style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize),
            ),
    );
  }
}
