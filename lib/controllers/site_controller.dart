import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:advancedcleaning/models/account_model.dart';
import 'package:advancedcleaning/models/site_model.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SiteController extends GetxController {
  final AuthController authController = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;

  RxList<Site> sites = <Site>[].obs;
  RxInt totalSites = 0.obs;
  RxInt lastIndex = 0.obs;
  final int pageSize = 10;
  RxString sortColumn = 'createdAt'.obs;
  RxBool sortAscending = true.obs;
  DocumentSnapshot? lastDocument;

  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _statusController = TextEditingController();

  TextEditingController get titleController => _titleController;
  TextEditingController get addressController => _addressController;
  TextEditingController get statusController => _statusController;
  String get title => _titleController.text;
  String get address => _addressController.text;
  String get status => _statusController.text;

  @override
  void onInit() {
    super.onInit();
    getTotalSiteCount();
    fetchSites();
  }

  @override
  void onClose() {
    _titleController.dispose();
    super.onClose();
  }

  void resetSites() async {
    sites.clear();
    totalSites.value = 0;
    lastIndex.value = 0;
    lastDocument = null;
    await getTotalSiteCount();
    await fetchSites();
  }

  Future<void> fetchSites({bool nextPage = false}) async {
    isLoading.value = true;

    Account? account = authController.currentAccount;
    if (account == null) {
      Get.snackbar('Site Error', 'Account has not been set',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      isLoading.value = false;
      return;
    }

    try {
      Query query = _firestore
          .collection(sitePath)
          .where('accountId', isEqualTo: account.id)
          .orderBy(sortColumn.value, descending: !sortAscending.value)
          .limit(pageSize);

      if (nextPage && lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      } else {
        // Reset pagination when it's not next page
        lastDocument = null;
      }

      QuerySnapshot querySnapshot = await query.get();

      if (nextPage) {
        sites.addAll(querySnapshot.docs.map((doc) => Site.fromFirestore(doc)));
      } else {
        sites.value =
            querySnapshot.docs.map((doc) => Site.fromFirestore(doc)).toList();
      }

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
      }
    } catch (e) {
      Get.snackbar('Error', 'Error loading sites: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTotalSiteCount() async {
    Account? account = authController.currentAccount;
    if (account == null) {
      Get.snackbar('Site Error', 'Account has not been set',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      isLoading.value = false;
      return;
    }

    try {
      AggregateQuerySnapshot snapshot = await _firestore
          .collection(sitePath)
          .where('accountId', isEqualTo: account.id)
          .count()
          .get();
      totalSites.value = snapshot.count ?? 0;
    } catch (e) {
      print('Error getting total site count: $e');
    }
  }

  void sort(String column, bool ascending) {
    sortColumn.value = column;
    sortAscending.value = ascending;
    fetchSites();
  }

  Future<List<Map<String, String>>> fetchAllMappedSites(
      {String? accountID}) async {
    isLoading.value = true;
    try {
      Query query =
          _firestore.collection(sitePath).orderBy('title', descending: false);

      if (accountID != null && accountID.isNotEmpty) {
        query = query.where('accountId', isEqualTo: accountID);
      }

      QuerySnapshot querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        Site site = Site.fromFirestore(doc);
        return {
          'id': site.id,
          'title': site.title,
        };
      }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Error loading sites: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }

    return List.empty();
  }

  // Create a new site
  Future<void> createSite() async {
    try {
      isLoading.value = true;

      Account? account = authController.currentAccount;
      if (account == null) {
        Get.snackbar('Site Error', 'Account has not been set',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
        return;
      }

      Site newSite = Site(
          id: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          appChanges: DateTime.now(),
          title: title,
          status: Status.active,
          address: address.isNotEmpty ? address : null,
          accountId: account.id);

      DocumentReference docRef =
          await _firestore.collection(sitePath).add(newSite.toFirestore());

      Navigator.of(Get.overlayContext!).pop();
      resetSites();
      Get.snackbar('Site Created', 'Site created with ID: ${docRef.id}',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('Site Error', 'Error creating site: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  // Update an site
  Future<void> updateSite(Site site) async {
    try {
      isLoading.value = true;

      Map<String, dynamic> newData = {
        'title': title,
        'address': address.isNotEmpty ? address : null,
        'status': status,
        'updatedAt': Timestamp.now(),
        'appChanges': Timestamp.now(),
      };

      await _firestore.collection(sitePath).doc(site.id).update(newData);

      Navigator.of(Get.overlayContext!).pop();
      resetSites();
      Get.snackbar('Site Updated', 'Site updated successfully',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('Site Error', 'Error updating site: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  // Update an site
  Future<void> updateAppChanges(String siteId) async {
    try {
      Map<String, dynamic> newData = {
        'appChanges': Timestamp.now(),
      };

      await _firestore.collection(sitePath).doc(siteId).update(newData);
    } catch (e) {
      Get.snackbar('Site Error', 'Error updating site: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    }
  }

  // Delete an site
  Future<void> deleteSite(Site site) async {
    try {
      isLoading.value = true;

      await _firestore.collection(sitePath).doc(site.id).delete();

      Navigator.of(Get.overlayContext!).pop();
      resetSites();
      Get.snackbar('Site Deleted', 'Site deleted successfully',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('Site Error', 'Error deleting site: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }
}

class SiteManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SiteController>(() => SiteController());
  }
}
