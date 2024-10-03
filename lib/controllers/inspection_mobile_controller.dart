import 'dart:async';
import 'dart:math';

import 'package:advancedcleaning/app_router.dart';
import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:advancedcleaning/controllers/mobile_sync_controller.dart';
import 'package:advancedcleaning/models/answer_model.dart';
import 'package:advancedcleaning/models/area_model.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:advancedcleaning/models/inspection_model.dart';
import 'package:advancedcleaning/models/question_answer_model.dart';
import 'package:advancedcleaning/models/site_model.dart';
import 'package:get/get.dart';

class InspectionMobileController extends GetxController {
  final AuthController authController = Get.find();
  final MobileSyncController syncController = Get.find();

  RxBool isLoading = false.obs;

  RxString selectedFrequency = InspectionFrequency.daily.name.obs;
  Rx<InspectionArea?> currentArea = Rx<InspectionArea?>(null);
  RxList<QuestionAnswer> questions = <QuestionAnswer>[].obs;
  RxList<QuestionAnswer> deepCleanQuestions = <QuestionAnswer>[].obs;
  Rx<String?> currentAreaBarcode = Rx<String?>(null);
  Rx<Inspection?> currentInspection = Rx<Inspection?>(null);
  RxList<Map<String, dynamic>> outstandingAreas = <Map<String, dynamic>>[].obs;

  @override
  void onInit() async {
    super.onInit();
    outstandingAreas.value = await syncController.getMissingSiteAreas(null);
  }

  Future<void> fetchQuestions() async {
    isLoading.value = true;
    try {
      if (currentAreaBarcode.value != null) {
        //Check if this area has been completed

        if (outstandingAreas.isNotEmpty) {
          for (var element in outstandingAreas) {
            if (element['areaBarcode'] == currentAreaBarcode.value) {
              if (element['isCompleded'] != null) {
                currentAreaBarcode.value = null;
                Get.snackbar(
                    'Area Completed', 'This are has already been completed',
                    duration: appSnackBarDuration,
                    backgroundColor: appSnackBarColor);
                return;
              }
            }
          }
        }
        //

        Map? result =
            await syncController.getAreaQuestions(currentAreaBarcode.value!);

        currentArea.value = result['area'];
        List<QuestionAnswer> allQuestions = result['questions'];
        List<QuestionAnswer> dailyQ = [];
        List<QuestionAnswer> deepQ = [];

        for (var i = 0; i < allQuestions.length; i++) {
          final question = allQuestions[i];
          if (question.frequency.name == InspectionFrequency.daily.name) {
            dailyQ.add(question);
          } else {
            deepQ.add(question);
          }
        }

        questions.value = dailyQ;
        deepCleanQuestions.value = deepQ;
      } else {
        throw ('No area selected');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error loading questions: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAnswer(
      InspectionFrequency frequency,
      String questionId,
      InspectionResult passStatus,
      String? failureReason,
      String? correctiveAction) async {
    if (frequency == InspectionFrequency.daily) {
      int index =
          questions.indexWhere((question) => question.questionId == questionId);
      if (index > -1) {
        QuestionAnswer questionCopy = questions[index];

        questionCopy.passStatus = passStatus;
        questionCopy.correctiveAction = correctiveAction;
        questionCopy.failureReason = failureReason;

        questions[index] = questionCopy;
      }
    } else {
      int index = deepCleanQuestions
          .indexWhere((question) => question.questionId == questionId);
      if (index > -1) {
        QuestionAnswer questionCopy = deepCleanQuestions[index];

        questionCopy.passStatus = passStatus;
        questionCopy.correctiveAction = correctiveAction;
        questionCopy.failureReason = failureReason;

        deepCleanQuestions[index] = questionCopy;
      }
    }
  }

  Future<void> openInspection() async {
    if (authController.currentUser == null) {
      throw ('Could not verify user');
    }

    if (authController.currentUserSiteId == null) {
      throw ('Could not verify user site');
    }

    Site? inspectionSite =
        await syncController.getSite(authController.currentUserSiteId!);
    if (inspectionSite == null) {
      throw ('Could not find user site. Please sync from server');
    }

    Inspection inspection = Inspection(
        id: getUniqueKey(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        conductedDate: DateTime.now(),
        accountId: authController.currentAccountId!,
        siteId: authController.currentUserSiteId!,
        siteTitle: inspectionSite.title,
        userId: authController.currentUserId!,
        userFullName: authController.currentUser!.fullName);

    int id = await syncController.insertInspection(inspection);
    if (id > 0) {
      currentInspection.value = inspection;
    } else {
      throw ('Could not create inspection');
    }
  }

  Future<void> saveAreaQuestions() async {
    isLoading.value = true;

    try {
      //Process daily question to see if all questions have answers
      for (QuestionAnswer question in questions) {
        if (question.passStatus == InspectionResult.notSet) {
          throw ('Not all questions have been answered');
        }
      }

      //Process deep clean question to see if all questions have answers
      for (QuestionAnswer question in deepCleanQuestions) {
        if (question.passStatus == InspectionResult.notSet) {
          if (question.lastInspectionDate == null) {
            if (question.passStatus == InspectionResult.notSet) {
              throw ('Not all questions have been answered under deep clean');
            }
          } else {
            if (question.overdueStatus() == 'Overdue') {
              throw ('You have overdue questions under deep clean');
            }
          }
        }
      }

      //all questions passed validation, save it in the db
      if (currentInspection.value == null) {
        //create the inspection if it does not exist
        await openInspection();
      }

      for (QuestionAnswer question in questions) {
        InspectionAnswer answer = InspectionAnswer(
            id: getUniqueKey(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            status: question.passStatus,
            accountId: question.accountId,
            siteId: question.siteId,
            areaId: question.areaId,
            inspectionId: currentInspection.value!.id,
            questionId: question.questionId,
            questionTitle: question.title,
            questionFrequency: question.frequency,
            correctiveAction: question.correctiveAction,
            failureReason: question.failureReason);

        await syncController.insertAnswer(answer);
      }

      if (deepCleanQuestions.isNotEmpty) {
        for (QuestionAnswer question in deepCleanQuestions) {
          if (question.passStatus != InspectionResult.notSet) {
            InspectionAnswer answer = InspectionAnswer(
                id: getUniqueKey(),
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                status: question.passStatus,
                accountId: question.accountId,
                siteId: question.siteId,
                areaId: question.areaId,
                inspectionId: currentInspection.value!.id,
                questionId: question.questionId,
                questionTitle: question.title,
                questionFrequency: question.frequency,
                correctiveAction: question.correctiveAction,
                failureReason: question.failureReason);

            await syncController.insertAnswer(answer);
          }
        }
      }

      outstandingAreas.value =
          await syncController.getMissingSiteAreas(currentInspection.value!.id);

      resetDefaults();
    } catch (e) {
      Get.snackbar('Error', '$e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      print('Error saving questions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  //This will delete the current instance of the inspection out of the database
  //as well as all the answers for this inspection
  Future<void> discardInspection() async {
    isLoading.value = true;
    if (currentInspection.value != null) {
      await syncController.deleteInspection(currentInspection.value!.id);
    }
    isLoading.value = false;
    Get.offAllNamed(Routes.DASHBOARD);
  }

  //checks to see if all areas has been competed
  //-1: there are no areas for the selcted site
  // 0: there are oustanding sites
  // 1: all areas are complete for the current site
  int hasOutstandingAreas() {
    int hasOutstanding = 1;
    if (outstandingAreas.isNotEmpty) {
      for (var element in outstandingAreas) {
        if (element['isCompleded'] == null) {
          hasOutstanding = 0;
          break;
        }
      }
    } else {
      hasOutstanding = -1;
    }

    return hasOutstanding;
  }

  Future<void> submitInspection() async {
    isLoading.value = true;

    try {
      if (currentInspection.value != null) {
        await syncController.submitInspectionLocal(currentInspection.value!.id);
        currentInspection.value = null;
        Get.offAndToNamed(Routes.DASHBOARD);
        Get.snackbar('Submitted', 'The inspections has been submitted',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      } else {
        throw ("Inspection not set");
      }
    } catch (e) {
      Get.snackbar('Error', '$e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      print('Error saving inspection: $e');
    }

    isLoading.value = false;
  }

  void resetDefaults() {
    selectedFrequency.value = InspectionFrequency.daily.name;
    currentArea.value = null;
    questions.clear();
    deepCleanQuestions.clear();
    currentAreaBarcode.value = null;
  }

  String getUniqueKey() {
    final random = Random();
    return '${DateTime.now().microsecondsSinceEpoch}${random.nextInt(10000)}';
  }
}

class InspectionMobileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InspectionMobileController>(() => InspectionMobileController());
  }
}
