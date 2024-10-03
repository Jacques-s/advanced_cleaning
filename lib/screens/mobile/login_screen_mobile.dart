import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/login_controller.dart';
import 'package:advancedcleaning/shared_widgets/general_submit_button.dart';
import 'package:advancedcleaning/shared_widgets/general_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

class LoginScreenMobile extends GetView<LoginController> {
  LoginScreenMobile({super.key});

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  Form loginForm() {
    // controller.emailController.text = 'test@test.com';
    // controller.passwordController.text = '12345678';
    return Form(
      key: _loginFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: Get.height * 0.02,
          ),
          Text(
            'Login',
            style: TextStyle(
                color: appPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: Get.textScaleFactor * 20),
          ),
          SizedBox(
            height: Get.height * 0.04,
          ),
          formMessage(),
          GeneralTextFormField(
              width: Get.width * 0.8,
              controller: controller.emailController,
              label: "Email",
              validator: (value) {
                final regex = RegExp(emailPattern);
                if (value == null || value.isEmpty || !regex.hasMatch(value)) {
                  return 'Valid email required';
                }
                return null;
              }),
          SizedBox(
            height: Get.height * 0.02,
          ),
          GeneralTextFormField(
              width: Get.width * 0.8,
              controller: controller.passwordController,
              label: "Passowrd",
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Valid password required';
                }
                return null;
              }),
          SizedBox(
            height: Get.height * 0.04,
          ),
          Obx(
            () => GeneralSubmitButton(
              onPress: () => controller.login(),
              label: 'Log in',
              isLoading: controller.authController.isLoading,
            ),
          ),
          SizedBox(
            height: Get.height * 0.05,
          ),
        ],
      ),
    );
  }

  Widget formMessage() {
    return Obx(() {
      String errorMessage = controller.authController.authErrorMessage;
      if (errorMessage.isNotEmpty) {
        return Text(
          errorMessage,
          style: const TextStyle(fontSize: 16, color: Colors.red),
        );
      } else {
        return const SizedBox();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(builder: (ctx, isKeyboardVisible) {
      return Scaffold(
        backgroundColor: appPrimaryColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: isKeyboardVisible ? 0 : Get.width * 0.5,
                    width: isKeyboardVisible ? 0 : Get.width * 0.5,
                    child: Image.asset('assets/images/ACSLogo.png')),
              ),
            ),
            Container(
              width: 400,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: Padding(
                padding: EdgeInsets.all(Get.width * 0.01),
                child: loginForm(),
              ),
            ),
          ],
        ),
      );
    });
  }
}
