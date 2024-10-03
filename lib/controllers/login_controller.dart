import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final AuthController authController = Get.find();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  String get email => _emailController.text;
  String get password => _passwordController.text;

  void login() {
    authController.signIn(emailController.text, passwordController.text);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
