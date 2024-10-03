import 'dart:io';

import 'package:advancedcleaning/app_router.dart';
import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDrawer extends GetView<AuthController> {
  AppDrawer({required this.activePage, super.key});

  final String activePage;
  final headerFontSize =
      !kIsWeb ? Get.textScaleFactor * 16 : Get.textScaleFactor * 14;

  Widget siteSelector() {
    if ((!kIsWeb && !Platform.isMacOS) &&
        controller.currentSiteIds.length > 1) {
      return ListTile(
        leading: const Icon(Icons.swap_vert_circle),
        title: const Text('Switch Sites'),
        selected: activePage == Routes.SITESELECTION,
        selectedTileColor: appAccentColor,
        enabled: activePage != Routes.SITESELECTION,
        onTap: () {
          Get.offAllNamed(Routes.SITESELECTION);
        },
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: EdgeInsets.all(Get.width * 0.01),
            decoration: const BoxDecoration(
              color: appPrimaryColor,
            ),
            child: Text('Operations',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: headerFontSize)),
          ),
          siteSelector(),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: activePage == '/dashboard',
            selectedTileColor: appAccentColor,
            enabled: activePage != '/dashboard',
            onTap: () {
              Get.offAllNamed(Routes.DASHBOARD);
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add_check_outlined),
            title: const Text('Inspection'),
            selected: activePage == Routes.INSPECTION,
            selectedTileColor: appAccentColor,
            enabled: activePage != Routes.INSPECTION,
            onTap: () {
              Get.offAllNamed(Routes.INSPECTION);
            },
          ),
          if (!kIsWeb && !Platform.isMacOS)
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              selected: activePage == Routes.SETTINGS,
              selectedTileColor: appAccentColor,
              enabled: activePage != Routes.SETTINGS,
              onTap: () {
                Get.offAllNamed(Routes.SETTINGS);
              },
            ),
          // ListTile(
          //   leading: const Icon(Icons.flag_outlined),
          //   title: const Text('Issues'),
          //   selected: activePage == '/issues',
          //   selectedTileColor: appAccentColor,
          //   enabled: activePage != '/issues',
          //   onTap: () {
          //     // Update the state of the app.
          //     // ...
          //   },
          // ),
          if (controller.currentUser != null &&
              controller.currentUser!.role == UserRole.admin)
            Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Users'),
                  selected: activePage == '/users',
                  selectedTileColor: appAccentColor,
                  enabled: activePage != '/users',
                  onTap: () {
                    Get.offAllNamed(Routes.USER_MANAGEMENT);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Accounts'),
                  selected: activePage == '/accounts',
                  selectedTileColor: appAccentColor,
                  enabled: activePage != '/accounts',
                  onTap: () {
                    Get.offAllNamed(Routes.ACCOUNT_MANAGEMENT);
                  },
                ),
              ],
            ),
          const Divider(
            color: appSecondaryColor,
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              controller.signOut();
            },
          ),
        ],
      ),
    );
  }
}
