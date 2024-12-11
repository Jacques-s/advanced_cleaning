import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageHelper {
  static void showSuccessMessage(String message) {
    Get.snackbar('Success', message,
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  static void showErrorMessage(String message) {
    Get.snackbar('Error', message,
        backgroundColor: Colors.red, colorText: Colors.white);
  }

  static void showInfoMessage(String message) {
    Get.snackbar('Info', message,
        backgroundColor: Colors.blue, colorText: Colors.white);
  }
}
