// main.dart
import 'dart:io';

import 'package:advancedcleaning/app_router.dart';
import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:advancedcleaning/controllers/mobile_sync_controller.dart';
import 'package:advancedcleaning/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: appThemeData,
      initialRoute: Routes.LOGIN,
      getPages: kIsWeb || Platform.isMacOS
          ? AppPages.webRoutes
          : AppPages.mobileRoutes,
      initialBinding: BindingsBuilder(
        () {
          if (!kIsWeb && !Platform.isMacOS) {
            if (Platform.isAndroid || Platform.isIOS) {
              Get.put(MobileSyncController.instance);
            }
          }
        },
      ),
    );
  }
}
