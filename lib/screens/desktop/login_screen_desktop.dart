import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/login_controller.dart';
import 'package:advancedcleaning/shared_widgets/general_submit_button.dart';
import 'package:advancedcleaning/shared_widgets/general_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreenDesktop extends GetView<LoginController> {
  LoginScreenDesktop({super.key});

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  Form loginForm() {
    controller.emailController.text = 'jacques.jexware@gmail.com';
    controller.passwordController.text = 'Jaun@13101994';

    return Form(
      key: _loginFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
              controller: controller.emailController,
              label: "Email",
              validator: (value) {
                final regex = RegExp(emailPattern);
                if (value == null || value.isEmpty || !regex.hasMatch(value)) {
                  return 'Valid email required';
                }
                return null;
              }),
          GeneralTextFormField(
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
            height: Get.height * 0.04,
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
    return Scaffold(
      backgroundColor: appPrimaryColor,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: Get.height * 0.04,
              width: Get.width * 0.2,
              child: Image.asset('assets/images/icleanLogo_white.png'),
            ),
            SizedBox(
              width: Get.width * 0.2,
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
      ),
    );
  }
}
