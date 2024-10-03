import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:advancedcleaning/models/user_model.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserManagementController extends GetxController {
  final AuthController authController = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxBool isLoading = false.obs;

  RxList<AppUser> users = <AppUser>[].obs;
  RxInt totalUsers = 0.obs;
  RxInt lastIndex = 0.obs;
  final int pageSize = 10;
  RxString sortColumn = 'createdAt'.obs;
  RxBool sortAscending = false.obs;
  DocumentSnapshot? lastDocument;

  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _cellNumberController = TextEditingController();
  final _statusController = TextEditingController();

  final selectedRole = ''.obs;
  final selectedAccountId = ''.obs;
  RxList<String> selectedSiteIds = <String>[].obs;

  TextEditingController get firstNameController => _firstNameController;
  TextEditingController get surnameController => _surnameController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController =>
      _confirmPasswordController;
  TextEditingController get emailController => _emailController;
  TextEditingController get cellNumebrController => _cellNumberController;
  TextEditingController get statusController => _statusController;

  String get firstName => _firstNameController.text;
  String get surname => _surnameController.text;
  String get email => _emailController.text;
  String get cellNumber => _cellNumberController.text;
  String get status => _statusController.text;

  String get password => _passwordController.text;
  String get confirmPassword => _confirmPasswordController.text;

  @override
  void onInit() {
    super.onInit();
    getTotalUserCount();
    fetchUsers();
  }

  @override
  void onClose() {
    _firstNameController.dispose();
    _surnameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _cellNumberController.dispose();
    _statusController.dispose();

    super.onClose();
  }

  void resetUsers() async {
    users.clear();
    totalUsers.value = 0;
    lastIndex.value = 0;
    lastDocument = null;
    await getTotalUserCount();
    await fetchUsers();
  }

  Future<void> fetchUsers({bool nextPage = false}) async {
    isLoading.value = true;

    try {
      Query query = _firestore
          .collection(userPath)
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
        users.addAll(
            querySnapshot.docs.map((doc) => AppUser.fromFirestore(doc)));
      } else {
        users.value = querySnapshot.docs
            .map((doc) => AppUser.fromFirestore(doc))
            .toList();
      }

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
      }
    } catch (e) {
      Get.snackbar('Error', 'Error loading users: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTotalUserCount() async {
    try {
      AggregateQuerySnapshot snapshot =
          await _firestore.collection(userPath).count().get();
      totalUsers.value = snapshot.count ?? 0;
    } catch (e) {
      print('Error getting total user count: $e');
    }
  }

  void sort(String column, bool ascending) {
    sortColumn.value = column;
    sortAscending.value = ascending;
    fetchUsers();
  }

  // Create a new user
  Future<void> createUser() async {
    try {
      isLoading.value = true;

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        UserRole convertedRole = UserRole.values
            .firstWhere((e) => e.toString() == 'UserRole.$selectedRole');
        AppUser newUser = AppUser(
            id: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            firstName: firstName,
            surname: surname,
            email: email,
            role: convertedRole,
            status: Status.active,
            accountId: selectedAccountId.value.isNotEmpty
                ? selectedAccountId.value
                : null,
            siteIds: selectedSiteIds);

        await _firestore
            .collection(userPath)
            .doc(userCredential.user!.uid)
            .set(newUser.toFirestore());

        Navigator.of(Get.overlayContext!).pop();
        resetUsers();
        Get.snackbar('User Created', 'User created',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      } else {
        throw ('Could not create credentials');
      }
    } catch (e) {
      Get.snackbar('User Error', 'Error creating user: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Update an user
  Future<void> updateUser(AppUser user) async {
    try {
      isLoading.value = true;

      Map<String, dynamic> newData = {
        'updatedAt': Timestamp.now(),
        'firstName': firstName,
        'surname': surname,
        'email': email,
        'cellNumber': cellNumber,
        'role': selectedRole.value,
        'status': Status.active.name,
      };

      if (selectedRole.value != UserRole.admin.name) {
        newData.addAll({
          'accountId': selectedAccountId.value.isNotEmpty
              ? selectedAccountId.value
              : null,
          'siteIds': selectedSiteIds,
        });
      }

      await _firestore.collection(userPath).doc(user.id).update(newData);

      Navigator.of(Get.overlayContext!).pop();
      resetUsers();
      Get.snackbar('User Updated', 'User updated successfully',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('User Error', 'Error updating user: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  // Delete an user
  Future<void> deleteUser(AppUser user) async {
    try {
      isLoading.value = true;

      await _firestore.collection(userPath).doc(user.id).delete();
      Navigator.of(Get.overlayContext!).pop();
      resetUsers();
      Get.snackbar('User Deleted', 'User deleted successfully',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('User Error', 'Error deleting user: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }
}

class UserManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserManagementController>(() => UserManagementController());
  }
}
