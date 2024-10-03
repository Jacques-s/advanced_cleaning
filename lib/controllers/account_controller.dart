import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:advancedcleaning/models/account_model.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountController extends GetxController {
  final AuthController authController = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;

  RxList<Account> accounts = <Account>[].obs;
  RxInt totalAccounts = 0.obs;
  RxInt lastIndex = 0.obs;
  final int pageSize = 10;
  RxString sortColumn = 'createdAt'.obs;
  RxBool sortAscending = true.obs;
  DocumentSnapshot? lastDocument;

  final _titleController = TextEditingController();
  final _statusController = TextEditingController();

  TextEditingController get titleController => _titleController;
  TextEditingController get statusController => _statusController;
  String get title => _titleController.text;
  String get status => _statusController.text;

  @override
  void onInit() {
    super.onInit();
    getTotalAccountCount();
    fetchAccounts();
  }

  @override
  void onClose() {
    _titleController.dispose();
    super.onClose();
  }

  void resetAccounts() async {
    accounts.clear();
    totalAccounts.value = 0;
    lastIndex.value = 0;
    lastDocument = null;
    await getTotalAccountCount();
    await fetchAccounts();
  }

  Future<void> fetchAccounts({bool nextPage = false}) async {
    isLoading.value = true;

    try {
      Query query = _firestore
          .collection(accountPath)
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
        accounts.addAll(
            querySnapshot.docs.map((doc) => Account.fromFirestore(doc)));
      } else {
        accounts.value = querySnapshot.docs
            .map((doc) => Account.fromFirestore(doc))
            .toList();
      }

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
      }
    } catch (e) {
      Get.snackbar('Error', 'Error loading accounts: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTotalAccountCount() async {
    try {
      AggregateQuerySnapshot snapshot =
          await _firestore.collection(accountPath).count().get();
      totalAccounts.value = snapshot.count ?? 0;
    } catch (e) {
      Get.snackbar('Error', 'Error getting total account count: $e');
    }
  }

  void sort(String column, bool ascending) {
    sortColumn.value = column;
    sortAscending.value = ascending;
    fetchAccounts();
  }

  Future<List<Map<String, String>>> fetchAllMappedAccounts() async {
    isLoading.value = true;

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(accountPath)
          .orderBy('title', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        Account account = Account.fromFirestore(doc);
        return {
          'id': account.id,
          'title': account.title,
        };
      }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Error loading accounts: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }

    return List.empty();
  }

  // Create a new account
  Future<void> createAccount() async {
    try {
      isLoading.value = true;

      DocumentReference docRef = await _firestore.collection(accountPath).add({
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'title': title,
        'status': Status.active.name,
      });

      Navigator.of(Get.overlayContext!).pop();
      resetAccounts();
      Get.snackbar('Account Created', 'Account created with ID: ${docRef.id}',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('Account Error', 'Error creating account: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  // Update an account
  Future<void> updateAccount(Account account) async {
    try {
      isLoading.value = true;

      Map<String, dynamic> newData = {
        'title': title,
        'status': status,
        'updatedAt': Timestamp.now()
      };

      await _firestore.collection(accountPath).doc(account.id).update(newData);

      Navigator.of(Get.overlayContext!).pop();
      resetAccounts();
      Get.snackbar('Account Updated', 'Account updated successfully',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('Account Error', 'Error updating account: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  // Delete an account
  Future<void> deleteAccount(Account account) async {
    try {
      isLoading.value = true;

      await _firestore.collection(accountPath).doc(account.id).delete();
      Navigator.of(Get.overlayContext!).pop();
      resetAccounts();
      Get.snackbar('Account Deleted', 'Account deleted successfully',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('Account Error', 'Error deleting account: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }
}

class AccountManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountController>(() => AccountController());
  }
}
