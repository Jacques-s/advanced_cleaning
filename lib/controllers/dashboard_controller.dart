import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/models/inspection_models/answer_model.dart';
import 'package:advancedcleaning/models/area_model.dart';
import 'package:advancedcleaning/models/chemical_models/chemical_log_model.dart';
import 'package:advancedcleaning/models/corrective_action_model.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:advancedcleaning/models/inspection_models/question_model.dart';
import 'package:advancedcleaning/models/site_model.dart';
import 'package:advancedcleaning/shared_widgets/dashboard_pdfs/checklist_pdf.dart';
import 'package:advancedcleaning/shared_widgets/dashboard_pdfs/chemical_log_pdf.dart';
import 'package:advancedcleaning/shared_widgets/dashboard_pdfs/failure_pdf.dart';
import 'package:advancedcleaning/shared_widgets/dashboard_pdfs/issue_actions_pdf.dart';
import 'package:advancedcleaning/shared_widgets/dashboard_pdfs/top_issues_pdf.dart';
import 'package:advancedcleaning/shared_widgets/dashboard_pdfs/verification_pdf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';

class DashboardController extends GetxController {
  final AuthController authController = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;

  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);

  String get formattedStartDate => startDate.value == null
      ? 'Select Date'
      : DateFormat('yyyy-MM-dd').format(startDate.value!);
  String get formattedEndDate => endDate.value == null
      ? 'Select Date'
      : DateFormat('yyyy-MM-dd').format(endDate.value!);

  Rx<String?> selectedReport = Rx<String?>(null);
  Rx<String?> selectedSiteId = Rx<String?>(null);
  Rx<String?> selectedSiteTitle = Rx<String?>(null);
  RxList<Site> allSites = <Site>[].obs;
  RxList<DashboardMenuItem> siteMenuItems = <DashboardMenuItem>[].obs;
  Rx<Widget?> currentReportWidget = Rx<Widget?>(null);
  RxList<InspectionArea> siteAreas = <InspectionArea>[].obs;
  RxList<InspectionQuestion> siteQuestions = <InspectionQuestion>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserSites();
  }

  Future<void> fetchUserSites() async {
    isLoading.value = true;

    try {
      List<Site> sites = [];
      if (authController.currentUser!.role == UserRole.manager) {
        List<String> userSites = authController.currentUser?.siteIds ?? [];
        if (userSites.isEmpty) {
          Get.snackbar('No Sites', 'You have no site slinked to your profile',
              duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
          isLoading.value = false;
          return;
        }

        final querySnapshot = await getSitesByIds(userSites);
        sites.addAll(querySnapshot.map((doc) => Site.fromFirestore(doc)));
      } else {
        QuerySnapshot querySnapshot = await _firestore
            .collection(sitePath)
            .orderBy('title', descending: false)
            .get();

        sites.addAll(querySnapshot.docs.map((doc) => Site.fromFirestore(doc)));
      }

      List<DashboardMenuItem> siteItems = [];
      siteItems
          .addAll(sites.map((site) => DashboardMenuItem(site.id, site.title)));
      siteMenuItems.value = siteItems;

      allSites.value = sites;
    } catch (e) {
      Get.snackbar('Error', 'Error loading sites: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<QueryDocumentSnapshot>> getSitesByIds(List<String> ids) async {
    List<QueryDocumentSnapshot> allSiteDocuments = [];

    // Split the list into chunks of 10 (Firestore's limit)
    for (var i = 0; i < ids.length; i += 10) {
      var chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(sitePath)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      allSiteDocuments.addAll(querySnapshot.docs);
    }

    return allSiteDocuments;
  }

  Future<Map<String, List<InspectionQuestion>>> fetchSiteStatusReport() async {
    isLoading.value = true;
    try {
      final now = DateTime.now();
      final currentTime = DateTime(now.year, now.month, now.day, 23, 59, 59)
          .subtract(const Duration(days: 1));

      Query query = _firestore
          .collection(questionPath)
          .where('siteId', isEqualTo: selectedSiteId.value)
          .where('nextInspectionDate',
              isLessThan: Timestamp.fromDate(currentTime))
          .orderBy('areaId', descending: false);

      QuerySnapshot querySnapshot = await query.get();

      List<InspectionQuestion> answers = querySnapshot.docs
          .map((doc) => InspectionQuestion.fromFirestore(doc))
          .toList();

      List<InspectionArea> areas = siteAreas;
      if (areas.isEmpty) {
        areas = await fetchSiteAreas();
      }

      Map<String, List<InspectionQuestion>> finalMappedList = {};
      for (var answer in answers) {
        InspectionArea answerArea = areas.firstWhere(
          (area) => area.id == answer.areaId,
          orElse: () => areas.first,
        );
        if (!finalMappedList.containsKey(answerArea.title)) {
          finalMappedList.addAll({answerArea.title: <InspectionQuestion>[]});
        }

        finalMappedList[answerArea.title]!.add(answer);
      }

      return finalMappedList;
    } catch (e) {
      Get.snackbar('Error', 'Error loading sites: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      print(e);
    } finally {
      isLoading.value = false;
    }

    return {};
  }

  Future<List<InspectionArea>> fetchSiteAreas() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(areaPath)
          .where('siteId', isEqualTo: selectedSiteId.value)
          .get();

      List<InspectionArea> areas = querySnapshot.docs
          .map((doc) => InspectionArea.fromFirestore(doc))
          .toList();
      siteAreas.value = areas;
      return areas;
    } catch (e) {
      Get.snackbar('Error', 'Error loading areas: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    }

    siteAreas.value = [];
    return [];
  }

  Future<List<InspectionQuestion>> fetchSiteQuestions() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(questionPath)
          .where('siteId', isEqualTo: selectedSiteId.value)
          .get();

      List<InspectionQuestion> questions = querySnapshot.docs
          .map((doc) => InspectionQuestion.fromFirestore(doc))
          .toList();
      siteQuestions.value = questions;
      return questions;
    } catch (e) {
      Get.snackbar('Error', 'Error loading questions: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    }

    siteQuestions.value = [];
    return [];
  }

  Future<Map<String, Map<String, List<InspectionQuestion>>>>
      fetchVerificationReport() async {
    isLoading.value = true;

    try {
      Query query = _firestore
          .collection(questionPath)
          .where('siteId', isEqualTo: selectedSiteId.value)
          .where('lastInspectionDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate.value!))
          .where('lastInspectionDate',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate.value!))
          .orderBy('areaId', descending: false);

      QuerySnapshot querySnapshot = await query.get();

      List<InspectionQuestion> answers = querySnapshot.docs
          .map((doc) => InspectionQuestion.fromFirestore(doc))
          .toList();

      List<InspectionArea> areas = siteAreas;
      if (areas.isEmpty) {
        areas = await fetchSiteAreas();
      }

      Map<String, Map<String, List<InspectionQuestion>>> finalMappedList = {};

      for (var answer in answers) {
        InspectionArea answerArea = areas.firstWhere(
          (area) => area.id == answer.areaId,
          orElse: () => areas.first,
        );

        String formattedDate = answer.lastInspectionDate != null
            ? DateFormat.yMMMEd().format(answer.lastInspectionDate!)
            : '-';

        if (!finalMappedList.containsKey(formattedDate)) {
          finalMappedList.addAll({
            formattedDate: {answerArea.title: <InspectionQuestion>[]}
          });
        }

        if (!finalMappedList[formattedDate]!.containsKey(answerArea.title)) {
          finalMappedList[formattedDate]!
              .addAll({answerArea.title: <InspectionQuestion>[]});
        }

        finalMappedList[formattedDate]![answerArea.title]!.add(answer);
      }

      return finalMappedList;
    } catch (e) {
      Get.snackbar('Error', 'Error loading sites: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      print(e);
    } finally {
      isLoading.value = false;
    }

    return {};
  }

  Future<Map<String, dynamic>> fetchChecklistReport() async {
    isLoading.value = true;
    try {
      Query query = _firestore
          .collection(inspectionAnswerPath)
          .where('siteId', isEqualTo: selectedSiteId.value)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate.value!))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate.value!))
          .orderBy('areaId', descending: false);

      QuerySnapshot querySnapshot = await query.get();

      List<InspectionAnswer> answers = querySnapshot.docs.map((doc) {
        return InspectionAnswer.fromFirestore(doc);
      }).toList();

      List<InspectionArea> areas = siteAreas;
      if (areas.isEmpty) {
        areas = await fetchSiteAreas();
      }

      List<InspectionQuestion> questions = siteQuestions;
      if (questions.isEmpty) {
        questions = await fetchSiteQuestions();
      }

      List<String> daysOfMonth = getDaysOfMonth(startDate.value!);
      Map<String, dynamic> finalMappedList = {};

      //Add areas to the list
      for (var area in areas) {
        finalMappedList.addAll({
          area.id: {'areaTitle': area.title, 'questions': {}}
        });
      }

      //Add questions to the lsit
      for (var question in questions) {
        if (finalMappedList.containsKey(question.areaId)) {
          Map<String, dynamic> days = {};
          for (var day in daysOfMonth) {
            days.addAll({day: '-'});
          }

          finalMappedList[question.areaId]['questions'].addAll({
            question.id: {'questionTitle': question.title, 'days': days}
          });
        }
      }

      //////////

      for (var answer in answers) {
        if (finalMappedList.containsKey(answer.areaId)) {
          if (finalMappedList[answer.areaId]['questions']
              .containsKey(answer.questionId)) {
            String day = DateFormat('dd').format(answer.createdAt);
            finalMappedList[answer.areaId]['questions'][answer.questionId]
                ['days'][day] = answer.status.name;
          }
        }
      }

      return finalMappedList;
    } catch (e) {
      Get.snackbar('Error', 'Error loading sites: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      print(e);
    } finally {
      isLoading.value = false;
    }

    return {};
  }

  List<String> getDaysOfMonth(DateTime reportMonth) {
    DateTime date = DateTime(reportMonth.year, reportMonth.month + 1,
        0); // The zero day of the next month is the last day of the current month
    int numOfDays = date.day;
    List<String> daysOfMonth = [];
    for (var i = 1; i <= numOfDays; i++) {
      daysOfMonth.add(DateFormat('dd')
          .format(DateTime(reportMonth.year, reportMonth.month, i)));
    }

    return daysOfMonth;
  }

  Future<Map<String, Map<String, List<InspectionAnswer>>>>
      fetchFailureReport() async {
    isLoading.value = true;
    try {
      Query query = _firestore
          .collection(inspectionAnswerPath)
          .where('siteId', isEqualTo: selectedSiteId.value)
          .where('status', isEqualTo: 'fail')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate.value!))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate.value!))
          .orderBy('areaId', descending: false);

      QuerySnapshot querySnapshot = await query.get();

      List<InspectionAnswer> answers = querySnapshot.docs
          .map((doc) => InspectionAnswer.fromFirestore(doc))
          .toList();

      List<InspectionArea> areas = siteAreas;
      if (areas.isEmpty) {
        areas = await fetchSiteAreas();
      }

      Map<String, Map<String, List<InspectionAnswer>>> finalMappedList = {};

      for (var answer in answers) {
        InspectionArea answerArea = areas.firstWhere(
          (area) => area.id == answer.areaId,
          orElse: () => areas.first,
        );

        String formattedDate = DateFormat.yMMMEd().format(answer.createdAt);

        if (!finalMappedList.containsKey(formattedDate)) {
          finalMappedList.addAll({
            formattedDate: {answerArea.title: <InspectionAnswer>[]}
          });
        }

        if (!finalMappedList[formattedDate]!.containsKey(answerArea.title)) {
          finalMappedList[formattedDate]!
              .addAll({answerArea.title: <InspectionAnswer>[]});
        }

        finalMappedList[formattedDate]![answerArea.title]!.add(answer);
      }

      return finalMappedList;
    } catch (e) {
      Get.snackbar('Error', 'Error loading sites: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      print(e);
    } finally {
      isLoading.value = false;
    }

    return {};
  }

  Future<Map<String, Map<String, dynamic>>> fetchTopIsuesReport() async {
    isLoading.value = true;
    try {
      Query query = _firestore
          .collection(inspectionAnswerPath)
          .where('siteId', isEqualTo: selectedSiteId.value)
          .where('status', isEqualTo: 'fail')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate.value!))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate.value!))
          .orderBy('areaId', descending: false);

      QuerySnapshot querySnapshot = await query.get();

      List<InspectionAnswer> answers = querySnapshot.docs
          .map((doc) => InspectionAnswer.fromFirestore(doc))
          .toList();

      List<InspectionQuestion> questions = siteQuestions;
      if (questions.isEmpty) {
        questions = await fetchSiteQuestions();
      }

      List<InspectionArea> areas = siteAreas;
      if (areas.isEmpty) {
        areas = await fetchSiteAreas();
      }

      Map<String, Map<String, dynamic>> finalMappedList = {};

      for (var answer in answers) {
        InspectionArea answerArea = areas.firstWhere(
          (area) => area.id == answer.areaId,
          orElse: () => areas.first,
        );

        if (!finalMappedList.containsKey(answerArea.title)) {
          finalMappedList.addAll({answerArea.title: {}});
        }

        if (!finalMappedList[answerArea.title]!
            .containsKey(answer.questionId)) {
          finalMappedList[answerArea.title]!.addAll({
            answer.questionId: {
              'questionTitle': answer.questionTitle,
              'count': 1,
              'accountId': answerArea.accountId,
              'siteId': answer.siteId,
              'areaId': answer.areaId
            }
          });
        } else {
          var count =
              finalMappedList[answerArea.title]![answer.questionId]!['count'];
          finalMappedList[answerArea.title]![answer.questionId]!['count'] =
              count++;
        }
      }

      return finalMappedList;
    } catch (e) {
      Get.snackbar('Error', 'Error loading sites: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      print(e);
    } finally {
      isLoading.value = false;
    }

    return {};
  }

  Future<void> createCorrectiveAction(CorrectiveAction action) async {
    try {
      isLoading.value = true;

      if (authController.currentUserId == null) {
        throw ('Your profile could not be loaded. Please log out and back in again');
      }

      action.userId = authController.currentUserId!;

      String formattedDate = DateFormat('yyyy_MM').format(action.actionMonth);
      String docKey = '${formattedDate}_${action.questionId}';

      await _firestore
          .collection(correctiveActionPath)
          .doc(docKey)
          .set(action.toFirestore());

      Navigator.of(Get.overlayContext!).pop();

      Get.snackbar(
          'Action Created', 'Corrective action created with ID: $docKey',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('Action Error', 'Error creating corrective action: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, List<CorrectiveAction>>> fetchIssueActionsReport() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(correctiveActionPath)
          .where('siteId', isEqualTo: selectedSiteId.value)
          .where('actionMonth',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate.value!))
          .where('actionMonth',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate.value!))
          .orderBy('areaId', descending: false)
          .get();

      List<CorrectiveAction> actions = querySnapshot.docs
          .map((doc) => CorrectiveAction.fromFirestore(doc))
          .toList();

      List<InspectionArea> areas = siteAreas;
      if (areas.isEmpty) {
        areas = await fetchSiteAreas();
      }

      Map<String, List<CorrectiveAction>> finalMappedList = {};
      for (var action in actions) {
        InspectionArea answerArea = areas.firstWhere(
          (area) => area.id == action.areaId,
          orElse: () => areas.first,
        );

        if (!finalMappedList.containsKey(answerArea.title)) {
          finalMappedList.addAll({answerArea.title: <CorrectiveAction>[]});
        }

        finalMappedList[answerArea.title]!.add(action);
      }

      return finalMappedList;
    } catch (e) {
      Get.snackbar('Error', 'Error loading actions: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    }
    return {};
  }

  Future<Map<String, List<ChemicalLog>>> fetchChemicalLogsReport() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(chemicalLogPath)
          .where('accountId', isEqualTo: authController.currentAccountId)
          .where('siteId', isEqualTo: selectedSiteId.value)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate.value!))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate.value!))
          .orderBy('createdAt', descending: true)
          .get();

      List<ChemicalLog> logs = querySnapshot.docs
          .map((doc) => ChemicalLog.fromFirestore(doc))
          .toList();

      Map<String, List<ChemicalLog>> finalMappedList = {};
      for (var log in logs) {
        if (!finalMappedList.containsKey(log.chemicalName)) {
          finalMappedList[log.chemicalName] = [];
        }
        finalMappedList[log.chemicalName]!.add(log);
      }

      return finalMappedList;
    } catch (e) {
      print('Error loading logs: $e');
      Get.snackbar('Error', 'Error loading actions: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    }
    return {};
  }

  Future<void> generateVerificationPDF() async {
    try {
      isLoading.value = true;
      final verificationData = await fetchVerificationReport();
      final verificationPdf = VerificationPDF(
          answers: verificationData,
          siteTitle: selectedSiteTitle.value ?? '',
          startDate: startDate.value ?? DateTime.now());
      verificationPdf.generateReport();
    } catch (e) {
      print('Error generating report: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateChemicalLogPDF() async {
    try {
      isLoading.value = true;
      final chemicalLogs = await fetchChemicalLogsReport();
      final chemicalLogPdf = ChemicalLogPdf(
          chemicalLogs: chemicalLogs,
          siteTitle: selectedSiteTitle.value ?? '',
          startDate: DateTime.now());
      chemicalLogPdf.generateReport();
    } catch (e) {
      print('Error generating report: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateFailurePDF() async {
    try {
      isLoading.value = true;
      final verificationData = await fetchFailureReport();
      final verificationPdf = FailurePDF(
          answers: verificationData,
          siteTitle: selectedSiteTitle.value ?? '',
          startDate: startDate.value ?? DateTime.now());
      verificationPdf.generateReport();
    } catch (e) {
      print('Error generating report: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateTopIssuesPDF() async {
    try {
      isLoading.value = true;
      final verificationData = await fetchTopIsuesReport();
      final verificationPdf = TopIssuesPdf(
          answers: verificationData,
          siteTitle: selectedSiteTitle.value ?? '',
          startDate: startDate.value ?? DateTime.now());
      verificationPdf.generateReport();
    } catch (e) {
      print('Error generating report: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateIssueActionsPDF() async {
    try {
      isLoading.value = true;
      final verificationData = await fetchIssueActionsReport();
      final verificationPdf = IssueActionsPdf(
          answers: verificationData,
          siteTitle: selectedSiteTitle.value ?? '',
          startDate: startDate.value ?? DateTime.now());
      verificationPdf.generateReport();
    } catch (e) {
      print('Error generating report: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateChecklistPDF() async {
    try {
      isLoading.value = true;
      final verificationData = await fetchChecklistReport();
      final verificationPdf = ChecklistPDF(
          answers: verificationData,
          siteTitle: selectedSiteTitle.value ?? '',
          reportMonth: startDate.value ?? DateTime.now());
      verificationPdf.generateReport();
    } catch (e) {
      print('Error generating report: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}

class DashboardMenuItem {
  final String id;
  final String title;

  DashboardMenuItem(this.id, this.title);
}
