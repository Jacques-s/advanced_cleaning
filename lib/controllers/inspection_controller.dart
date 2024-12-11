import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:advancedcleaning/controllers/site_controller.dart';
import 'package:advancedcleaning/models/inspection_models/answer_model.dart';
import 'package:advancedcleaning/models/area_model.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:advancedcleaning/models/inspection_models/inspection_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InpsectionsController extends GetxController {
  final AuthController authController = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;

  RxList<Inspection> inspections = <Inspection>[].obs;
  Rx<Inspection?> currentInspection = Rx<Inspection?>(null);
  RxInt totalInspections = 0.obs;
  RxInt lastIndex = 0.obs;
  final int pageSize = 10;
  RxString sortColumn = 'createdAt'.obs;
  RxBool sortAscending = false.obs;
  DocumentSnapshot? lastDocument;
  Rx<Map?> currentInspectionDetails = Rx<Map?>(null);

  Map? get areaDetails => currentInspectionDetails.value!['areas'];

  @override
  void onInit() {
    super.onInit();
    getTotalInspectionCount();
    fetchInspections();
  }

  void resetInspections() async {
    inspections.clear();
    totalInspections.value = 0;
    lastIndex.value = 0;
    lastDocument = null;
    currentInspectionDetails.value = null;
    await getTotalInspectionCount();
    await fetchInspections();
  }

  Future<void> fetchInspections({bool nextPage = false}) async {
    isLoading.value = true;

    try {
      Query query;
      if (authController.currentUser!.role == UserRole.manager) {
        List<String> userSites = authController.currentUser?.siteIds ?? [];
        if (userSites.isEmpty) {
          Get.snackbar('No Sites', 'You have no site slinked to your profile',
              duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
          isLoading.value = false;
          return;
        }

        query = _firestore
            .collection(inspectionPath)
            .where('accountId', isEqualTo: authController.currentAccountId)
            .where('siteId', whereIn: userSites)
            .orderBy(sortColumn.value, descending: !sortAscending.value)
            .limit(pageSize);
      } else {
        query = _firestore
            .collection(inspectionPath)
            .orderBy(sortColumn.value, descending: !sortAscending.value)
            .limit(pageSize);
      }

      if (nextPage && lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      } else {
        // Reset pagination when it's not next page
        lastDocument = null;
      }

      QuerySnapshot querySnapshot = await query.get();

      if (nextPage) {
        inspections.addAll(
            querySnapshot.docs.map((doc) => Inspection.fromFirestore(doc)));
      } else {
        inspections.value = querySnapshot.docs
            .map((doc) => Inspection.fromFirestore(doc))
            .toList();
      }

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
      }
    } catch (e) {
      Get.snackbar('Error', 'Error loading inspections: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTotalInspectionCount() async {
    try {
      AggregateQuery query;
      if (authController.currentUser!.role == UserRole.manager) {
        List<String> userSites = authController.currentUser?.siteIds ?? [];
        if (userSites.isEmpty) {
          Get.snackbar('No Sites', 'You have no site slinked to your profile',
              duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
          isLoading.value = false;
          return;
        }

        query = _firestore
            .collection(inspectionPath)
            .where('accountId', isEqualTo: authController.currentAccountId)
            .where('siteId', whereIn: userSites)
            .count();
      } else {
        query = _firestore.collection(inspectionPath).count();
      }

      AggregateQuerySnapshot snapshot = await query.get();
      totalInspections.value = snapshot.count ?? 0;
    } catch (e) {
      print('Error getting total inspection count: $e');
    }
  }

  void sort(String column, bool ascending) {
    sortColumn.value = column;
    sortAscending.value = ascending;
    fetchInspections();
  }

  // Delete an inspection
  Future<void> deleteInspection(Inspection inspection) async {
    try {
      isLoading.value = true;

      await _firestore.collection(inspectionPath).doc(inspection.id).delete();
      await SiteController().updateAppChanges(inspection.siteId);

      Navigator.of(Get.overlayContext!).pop();
      resetInspections();
      Get.snackbar('Inspection Deleted', 'Inspection deleted successfully',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('Inspection Error', 'Error deleting inspection: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchInspectionDetails() async {
    isLoading.value = true;

    try {
      if (currentInspection.value == null) {
        throw ('Could not set the current inspection');
      }

      final passes = (currentInspection.value!.pass ?? 0).toInt();
      final fails = (currentInspection.value!.fail ?? 0).toInt();
      final total = passes + fails;

      Map<String, dynamic> inspectionDetails = {
        'conductedDate': currentInspection.value!.conductedDate,
        'siteTitle': currentInspection.value!.siteTitle,
        'conductedBy': currentInspection.value!.userFullName,
        'overallScore': currentInspection.value!.score,
        'failRate': '$fails / $total'
      };

      QuerySnapshot areaSnapshot = await _firestore
          .collection(areaPath)
          .where('siteId', isEqualTo: currentInspection.value!.siteId)
          .get();

      if (areaSnapshot.docs.isNotEmpty) {
        Map<String, dynamic>? areaScores = currentInspection.value!.areaScores;

        Map<String, dynamic> areas = {};
        for (var rawArea in areaSnapshot.docs) {
          InspectionArea area = InspectionArea.fromFirestore(rawArea);
          areas.addAll({
            area.id: {
              'areaTitle': area.title,
              'areaScores': areaScores?[area.id],
            }
          });
        }

        if (areas.isNotEmpty) {
          QuerySnapshot answerSnapshot = await _firestore
              .collection(inspectionAnswerPath)
              .where('inspectionId', isEqualTo: currentInspection.value!.id)
              .get();

          if (answerSnapshot.docs.isNotEmpty) {
            for (var rawAnswers in answerSnapshot.docs) {
              InspectionAnswer answer =
                  InspectionAnswer.fromFirestore(rawAnswers);

              if (areas.containsKey(answer.areaId)) {
                if (!areas[answer.areaId].containsKey('answers')) {
                  areas[answer.areaId].addAll({
                    'answers': [
                      {
                        'questionTitle': answer.questionTitle,
                        'correctiveAction': answer.correctiveAction,
                        'failureReason': answer.failureReason
                      }
                    ]
                  });
                } else {
                  areas[answer.areaId]['answers'].add({
                    'questionTitle': answer.questionTitle,
                    'correctiveAction': answer.correctiveAction,
                    'failureReason': answer.failureReason
                  });
                }
              }
            }

            inspectionDetails['areas'] = areas;
          }
        }
      }
      currentInspectionDetails.value = inspectionDetails;
    } catch (e) {
      currentInspectionDetails.value = null;
      Get.snackbar('Error', 'Error loading inspections: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}

class InspectionManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InpsectionsController>(() => InpsectionsController());
  }
}
