import 'package:advancedcleaning/controllers/account_controller.dart';
import 'package:advancedcleaning/controllers/area_controller.dart';
import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:advancedcleaning/controllers/dashboard_controller.dart';
import 'package:advancedcleaning/controllers/mobile_controllers/ncr_update_controller.dart';
import 'package:advancedcleaning/controllers/mobile_controllers/dashboard_mobile_controller.dart';
import 'package:advancedcleaning/controllers/inspection_controller.dart';
import 'package:advancedcleaning/controllers/mobile_controllers/inspection_mobile_controller.dart';
import 'package:advancedcleaning/controllers/login_controller.dart';
import 'package:advancedcleaning/controllers/mobile_controllers/chemical_controller.dart';
import 'package:advancedcleaning/controllers/notification_controller.dart';
import 'package:advancedcleaning/controllers/procedure_controller.dart';
import 'package:advancedcleaning/controllers/mobile_controllers/procedure_mobile_controller.dart';
import 'package:advancedcleaning/controllers/question_controller.dart';
import 'package:advancedcleaning/controllers/site_controller.dart';
import 'package:advancedcleaning/controllers/user_controller.dart';
import 'package:advancedcleaning/screens/desktop/accounts_screen_desktop.dart';
import 'package:advancedcleaning/screens/desktop/areas_screen_desktop.dart';
import 'package:advancedcleaning/screens/desktop/dashboard_screen_desktop.dart';
import 'package:advancedcleaning/screens/desktop/inpsections_screen_desktop.dart';
import 'package:advancedcleaning/screens/desktop/inspection_view_screen.dart';
import 'package:advancedcleaning/screens/desktop/login_screen_desktop.dart';
import 'package:advancedcleaning/screens/desktop/procedures_screen_desktop.dart';
import 'package:advancedcleaning/screens/desktop/questions_screen_desktop.dart';
import 'package:advancedcleaning/screens/desktop/sites_screen_desktop.dart';
import 'package:advancedcleaning/screens/desktop/users_screen_desktop.dart';
import 'package:advancedcleaning/screens/mobile/chemical_screens/chemical_menu_screen_mobile.dart';
import 'package:advancedcleaning/screens/mobile/ncr_screens/ncr_menu_screen_mobile.dart';
import 'package:advancedcleaning/screens/mobile/ncr_screens/nrc_view_screen.dart';
import 'package:advancedcleaning/screens/mobile/general_screens/dashboard_screen_mobile.dart';
import 'package:advancedcleaning/screens/mobile/inspection_screen_mobile.dart';
import 'package:advancedcleaning/screens/mobile/general_screens/login_screen_mobile.dart';
import 'package:advancedcleaning/screens/mobile/general_screens/notification_mobile_screen.dart';
import 'package:advancedcleaning/screens/mobile/procedure_screens/procedures_screen_mobile.dart';
import 'package:advancedcleaning/screens/mobile/general_screens/settings_screen_mobile.dart';
import 'package:advancedcleaning/screens/mobile/general_screens/site_selection_screen_mobile.dart';
import 'package:advancedcleaning/screens/mobile/ncr_screens/create_ncr_screen_mobile.dart';
import 'package:advancedcleaning/controllers/mobile_controllers/ncr_create_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class Routes {
  static const LOGIN = '/login';
  static const DASHBOARD = '/dashboard';
  static const USER_MANAGEMENT = '/user-management';
  static const ACCOUNT_MANAGEMENT = '/account-management';
  static const SITE_MANAGEMENT = '/site-management';
  static const AREA_MANAGEMENT = '/area-management';
  static const QUESTION_MANAGEMENT = '/question-management';
  static const INSPECTION = '/inspection';
  static const INSPECTIONVIEW = '/inspection-view';
  static const SETTINGS = '/settings';
  static const SITESELECTION = '/site-selection';
  static const PROCEDURE_MANAGEMENT = '/procedure-management';
  static const CHEMICAL_MENU = '/chemical-menu';
  static const NOTIFICATIONS = '/notifications';
  static const CREATE_NCR = '/create-ncr';
  static const NCR_MENU = '/ncr-menu';
  static const NCR_VIEW = '/ncr-view';
}

class AppPages {
  static final webRoutes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginScreenDesktop(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => DashboardScreenDesktop(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.USER_MANAGEMENT,
      page: () => const UsersScreenDesktop(),
      binding: UserManagementBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.INSPECTION,
      page: () => const InpsectionsScreenDesktop(),
      binding: InspectionManagementBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.INSPECTIONVIEW,
      page: () => const InspectionViewScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.ACCOUNT_MANAGEMENT,
      page: () => const AccountsScreenDesktop(),
      binding: AccountManagementBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.SITE_MANAGEMENT,
      page: () => const SitesScreenDesktop(),
      binding: SiteManagementBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.AREA_MANAGEMENT,
      page: () => const AreasScreenDesktop(),
      binding: AreaManagementBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.QUESTION_MANAGEMENT,
      page: () => const QuestionsScreenDesktop(),
      binding: QuestionManagementBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.PROCEDURE_MANAGEMENT,
      page: () => const ProceduresScreenDesktop(),
      binding: ProcedureControllerBinding(),
      middlewares: [AuthMiddleware()],
    )
  ];

  static final mobileRoutes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginScreenMobile(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.SITESELECTION,
      page: () => const SiteSelectionScreenMobile(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardScreenMobile(),
      binding: DashboardMobileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.INSPECTION,
      page: () => const InspectionScreenMobile(),
      binding: InspectionMobileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.PROCEDURE_MANAGEMENT,
      page: () => const ProceduresScreenMobile(),
      binding: ProcedureMobileControllerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.CHEMICAL_MENU,
      page: () => const ChemicalMenuScreenMobile(),
      binding: ChemicalMobileControllerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.CREATE_NCR,
      page: () => const CreateNcrScreenMobile(),
      binding: NcrCreateControllerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.NCR_MENU,
      page: () => const NcrMenuScreenMobile(),
      binding: NcrUpdateControllerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.NCR_VIEW,
      page: () => const NrcViewScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: () => const MobileNotificationScreen(),
      binding: AppNotificationControllerBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsScreenMobile(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    return authController.firebaseUser == null
        ? const RouteSettings(name: Routes.LOGIN)
        : null;
  }
}
