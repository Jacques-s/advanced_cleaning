import 'dart:io';

import 'package:advancedcleaning/app_router.dart';
import 'package:advancedcleaning/models/account_model.dart';
import 'package:advancedcleaning/models/area_model.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:advancedcleaning/models/site_model.dart';
import 'package:advancedcleaning/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _isLoading = false.obs;
  final _isLoggedIn = false.obs;
  final _errorMessage = ''.obs;
  final Rx<User?> _firebaseUser = Rx<User?>(null);

  final _currentUserId = Rx<String?>(null);
  final _currentUser = Rx<AppUser?>(null);

  //Used for navigation
  final Rx<Account?> _currentAccount = Rx<Account?>(null);
  final Rx<Site?> _currentSite = Rx<Site?>(null);
  final Rx<InspectionArea?> _currentArea = Rx<InspectionArea?>(null);

  final Rx<String?> _currentUserSiteId = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    _firebaseUser.bindStream(_auth.authStateChanges());

    //check if there is a logged in user
    if (_currentUser.value == null) {
      if (_auth.currentUser != null) {
        //signOut();
        reauthenticateUser();
      }
    }
  }

  bool get isLoggedIn => _isLoggedIn.value;
  String get authErrorMessage => _errorMessage.value;
  bool get isLoading => _isLoading.value;
  User? get firebaseUser => _firebaseUser.value;

  String? get currentUserId => _currentUserId.value;
  String? get currentAccountId => _currentUser.value?.accountId;

  //The selected site for the current user
  String? get currentUserSiteId => _currentUserSiteId.value;
  void setCurrentUserSiteId(String selectedSite) {
    _currentUserSiteId.value = selectedSite;
  }
  //

  //All the sites linked to the current user
  List<String> get currentSiteIds => _currentUser.value?.siteIds ?? [];
  //

  AppUser? get currentUser => _currentUser.value;

  Account? get currentAccount => _currentAccount.value;
  Site? get currentSite => _currentSite.value;
  InspectionArea? get currentArea => _currentArea.value;

  set setCurrentAccount(Account? account) {
    _currentAccount.value = account;
  }

  set setCurrentSite(Site? site) {
    _currentSite.value = site;
  }

  set setCurrentArea(InspectionArea? area) {
    _currentArea.value = area;
  }

  Future<void> signIn(String email, String password) async {
    _isLoading.value = true;
    try {
      UserCredential credentials = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (credentials.user != null) {
        //get the user collection to set the current user information
        DocumentSnapshot userSnapshot = await _firestore
            .collection(userPath)
            .doc(credentials.user!.uid)
            .get();

        if (userSnapshot.exists) {
          _currentUser.value = AppUser.fromFirestore(userSnapshot);
          _currentUserId.value = credentials.user!.uid;
        } else {
          throw ('NotFound');
        }
      }

      if (kIsWeb &&
          _currentUser.value != null &&
          _currentUser.value!.role == UserRole.siteManager) {
        await signOut();
        _errorMessage.value = 'Your do not have permission';
      }

      _isLoading.value = false;

      if ((!kIsWeb && !Platform.isMacOS) && currentUser != null) {
        List<String> siteIds = _currentUser.value?.siteIds ?? [];

        if (siteIds.isNotEmpty && siteIds.length == 1) {
          _currentUserSiteId.value = siteIds.first;
          Get.offAllNamed(Routes.DASHBOARD);
        } else {
          Get.offAllNamed(Routes.SITESELECTION);
        }
      } else {
        Get.offAllNamed(Routes.DASHBOARD);
      }
    } catch (e) {
      _isLoading.value = false;
      if (e == 'NotFound') {
        _errorMessage.value = 'Your info could not be found';
      } else {
        _errorMessage.value = 'The provided details are incorrect';
      }
      print(e);
    }
  }

  Future<void> signOut() async {
    _isLoading.value = true;
    await _auth.signOut();
    _isLoading.value = false;
    Get.offAllNamed(Routes.LOGIN);
  }

  //only to be used for initial credential setup
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<bool> createUser(String userID) async {
    try {
      AppUser newUser = AppUser(
          id: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          firstName: 'Jacques',
          surname: 'Steyn',
          email: 'jacques.jexware@gmail.com',
          role: UserRole.admin,
          status: Status.active,
          siteIds: []);

      await _firestore
          .collection(userPath)
          .doc(userID)
          .set(newUser.toFirestore());

      print('User Created, User created');
      return true;
    } catch (e) {
      print('User Error, Error creating user: $e');
      return false;
    }
  }

  // this function is mostly for web to readd the logged in user as it clears it
  Future<void> reauthenticateUser() async {
    _isLoading.value = true;
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        //get the user collection to set the current user information
        DocumentSnapshot userSnapshot =
            await _firestore.collection(userPath).doc(user.uid).get();

        if (userSnapshot.exists) {
          _currentUser.value = AppUser.fromFirestore(userSnapshot);
          _currentUserId.value = user.uid;
        } else {
          throw ('NotFound');
        }
      }

      _isLoading.value = false;
      Get.offAllNamed(Routes.DASHBOARD);
    } catch (e) {
      _isLoading.value = false;
      if (e == 'NotFound') {
        Get.offAllNamed(Routes.LOGIN);
        print(e);
      }
    }
  }
}
