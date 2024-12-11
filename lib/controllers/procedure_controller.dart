import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:advancedcleaning/helpers/storage_helper.dart';
import 'package:advancedcleaning/models/account_model.dart';
import 'package:advancedcleaning/models/chemical_models/chemical_model.dart';
import 'package:advancedcleaning/models/procedure_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProcedureController extends GetxController {
  final AuthController authController = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();
  RxBool isLoading = false.obs;

  RxList<Account> allAccounts = <Account>[].obs;
  RxList<AccountMenuItem> accountMenuItems = <AccountMenuItem>[].obs;
  RxString selectedAccountId = ''.obs;
  RxString selectedAccountTitle = ''.obs;
  RxList<Procedure> procedures = <Procedure>[].obs;
  RxInt totalProcedures = 0.obs;
  RxInt lastIndex = 0.obs;
  final int pageSize = 10;
  RxString sortColumn = 'createdAt'.obs;
  RxBool sortAscending = true.obs;
  DocumentSnapshot? lastDocument;

  final _titleController = TextEditingController();
  final _effectiveDateController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _amendmentNumberController = TextEditingController();
  final _areaTitleController = TextEditingController();
  final _responsibilityController = TextEditingController();
  final _inspectedByController = TextEditingController();
  final _maintenanceAssistanceController = TextEditingController();
  final _cleaningRecordController = TextEditingController();

  RxList<Chemical> chemicals = <Chemical>[].obs;
  RxList<String> equipmentRequired = <String>[].obs;
  RxList<String> colourCodes = <String>[].obs;
  RxList<String> safetyRequirements = <String>[].obs;
  RxList<String> dailyInstructions = <String>[].obs;
  RxList<String> weeklyInstructions = <String>[].obs;
  RxList<String> monthlyInstructions = <String>[].obs;
  RxList<String> quarterlyInstructions = <String>[].obs;
  RxList<String> yearlyInstructions = <String>[].obs;
  RxList<PlatformFile> selectedImages = <PlatformFile>[].obs;
  RxList<String> deleteImages = <String>[].obs;

  TextEditingController get titleController => _titleController;
  String get title => _titleController.text;

  TextEditingController get effectiveDateController => _effectiveDateController;
  String get effectiveDate => _effectiveDateController.text;

  TextEditingController get documentNumberController =>
      _documentNumberController;
  String get documentNumber => _documentNumberController.text;

  TextEditingController get amendmentNumberController =>
      _amendmentNumberController;
  String get amendmentNumber => _amendmentNumberController.text;

  TextEditingController get areaTitleController => _areaTitleController;
  String get areaTitle => _areaTitleController.text;

  TextEditingController get responsibilityController =>
      _responsibilityController;
  String get responsibility => _responsibilityController.text;

  TextEditingController get inspectedByController => _inspectedByController;
  String get inspectedBy => _inspectedByController.text;

  TextEditingController get maintenanceAssistanceController =>
      _maintenanceAssistanceController;
  String get maintenanceAssistance => _maintenanceAssistanceController.text;

  TextEditingController get cleaningRecordController =>
      _cleaningRecordController;
  String get cleaningRecord => _cleaningRecordController.text;

  @override
  void onInit() {
    super.onInit();
    fetchAccounts();
  }

  @override
  void onClose() {
    _titleController.dispose();
    _effectiveDateController.dispose();
    _documentNumberController.dispose();
    _amendmentNumberController.dispose();
    _areaTitleController.dispose();
    _responsibilityController.dispose();
    _inspectedByController.dispose();
    _maintenanceAssistanceController.dispose();
    _cleaningRecordController.dispose();
    super.onClose();
  }

  void resetProcedures() async {
    procedures.clear();
    totalProcedures.value = 0;
    lastIndex.value = 0;
    lastDocument = null;
    await getTotalProcedureCount();
    await fetchProcedures();
  }

  Future<void> fetchAccounts() async {
    isLoading.value = true;

    try {
      List<Account> accounts = [];
      Query query = _firestore
          .collection(accountPath)
          .orderBy(sortColumn.value, descending: !sortAscending.value)
          .limit(pageSize);

      QuerySnapshot querySnapshot = await query.get();
      accounts
          .addAll(querySnapshot.docs.map((doc) => Account.fromFirestore(doc)));

      List<AccountMenuItem> accountItems = [];
      accountItems.addAll(accounts
          .map((account) => AccountMenuItem(account.id, account.title)));
      accountMenuItems.value = accountItems;

      allAccounts.value = accounts;
    } catch (e) {
      Get.snackbar('Error', 'Error loading accounts: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProcedures({bool nextPage = false}) async {
    isLoading.value = true;

    try {
      if (selectedAccountId.value.isEmpty) {
        Get.snackbar('Error', 'No account selected',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
        return;
      }

      Query query = _firestore
          .collection(procedurePath)
          .where('accountId', isEqualTo: selectedAccountId.value)
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
        procedures.addAll(
            querySnapshot.docs.map((doc) => Procedure.fromFirestore(doc)));
      } else {
        procedures.value = querySnapshot.docs
            .map((doc) => Procedure.fromFirestore(doc))
            .toList();
      }

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
      }
    } catch (e) {
      Get.snackbar('Error', 'Error loading procedures: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTotalProcedureCount() async {
    if (selectedAccountId.value.isEmpty) {
      Get.snackbar('Account Error', 'Account has not been set',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      isLoading.value = false;
      return;
    }

    try {
      AggregateQuerySnapshot snapshot = await _firestore
          .collection(procedurePath)
          .where('accountId', isEqualTo: selectedAccountId.value)
          .count()
          .get();
      totalProcedures.value = snapshot.count ?? 0;
    } catch (e) {
      print('Error getting total procedure count: $e');
    }
  }

  void sort(String column, bool ascending) {
    sortColumn.value = column;
    sortAscending.value = ascending;
    fetchProcedures();
  }

  Future<List<Map<String, String>>> fetchAllMappedProcedures() async {
    isLoading.value = true;

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(procedurePath)
          .where('accountId', isEqualTo: selectedAccountId.value)
          .orderBy('title', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        Procedure procedure = Procedure.fromFirestore(doc);
        return {
          'id': procedure.id,
          'title': procedure.title,
        };
      }).toList();
    } catch (e) {
      Get.snackbar('Error', 'Error loading procedures: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }

    return List.empty();
  }

  Future<void> pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        selectedImages.value = result.files;
      }
    } catch (e) {
      Get.snackbar('Error', 'Error picking images: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    }
  }

  Future<List<String>> _uploadImages(String procedureId) async {
    if (selectedImages.isEmpty) return [];
    return await _storageService.uploadImages(
        procedurePath, procedureId, selectedImages);
  }

  // Create a new procedure
  Future<void> createProcedure() async {
    try {
      isLoading.value = true;

      List<String> frequencies = [];
      if (dailyInstructions.isNotEmpty) {
        frequencies.add('Daily');
      }
      if (weeklyInstructions.isNotEmpty) {
        frequencies.add('Weekly');
      }
      if (monthlyInstructions.isNotEmpty) {
        frequencies.add('Monthly');
      }
      if (quarterlyInstructions.isNotEmpty) {
        frequencies.add('Quarterly');
      }
      if (yearlyInstructions.isNotEmpty) {
        frequencies.add('Yearly');
      }

      Procedure procedure = Procedure(
        id: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        title: title,
        effectiveDate: DateTime.parse(effectiveDate),
        documentNumber: documentNumber,
        amendmentNumber: amendmentNumber,
        areaTitle: areaTitle,
        accountId: selectedAccountId.value,
        cleaningRecord: cleaningRecord,
        maintenanceAssistance: maintenanceAssistance,
        frequencies: frequencies,
        responsibility: responsibility,
        inspectedBy: inspectedBy,
        chemicals: chemicals,
        safetyRequirements: safetyRequirements,
        colourCodes: colourCodes,
        equipmentRequired: equipmentRequired,
        dailyInstructions: dailyInstructions,
        weeklyInstructions: weeklyInstructions,
        monthlyInstructions: monthlyInstructions,
        quarterlyInstructions: quarterlyInstructions,
        yearlyInstructions: yearlyInstructions,
        imageUrls: [],
      );

      DocumentReference docRef = await _firestore
          .collection(procedurePath)
          .add(procedure.toFirestore());

      // Upload images and get URLs
      List<String> imageUrls = await _uploadImages(docRef.id);

      // Update the procedure document with image URLs
      await docRef.update({'imageUrls': imageUrls});

      //save the checmicals
      for (var chemical in chemicals) {
        await _firestore
            .collection(chemicalPath)
            .doc(chemical.chemicalId)
            .update(chemical.toFirestore());
      }

      Navigator.of(Get.overlayContext!).pop();
      resetProcedures();
      selectedImages.clear();
      Get.snackbar(
          'Procedure Created', 'Procedure created with ID: ${docRef.id}',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('Procedure Error', 'Error creating procedure: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  // Update a procedure
  Future<void> updateProcedure(Procedure procedure) async {
    try {
      isLoading.value = true;

      List<String> frequencies = [];
      if (dailyInstructions.isNotEmpty) {
        frequencies.add('Daily');
      }
      if (weeklyInstructions.isNotEmpty) {
        frequencies.add('Weekly');
      }
      if (monthlyInstructions.isNotEmpty) {
        frequencies.add('Monthly');
      }
      if (quarterlyInstructions.isNotEmpty) {
        frequencies.add('Quarterly');
      }
      if (yearlyInstructions.isNotEmpty) {
        frequencies.add('Yearly');
      }

      Procedure updatedProcedure = Procedure(
        id: procedure.id,
        createdAt: procedure.createdAt,
        updatedAt: DateTime.now(),
        title: title,
        effectiveDate: DateTime.parse(effectiveDate),
        documentNumber: documentNumber,
        amendmentNumber: amendmentNumber,
        areaTitle: areaTitle,
        accountId: selectedAccountId.value,
        cleaningRecord: cleaningRecord,
        maintenanceAssistance: maintenanceAssistance,
        frequencies: frequencies,
        responsibility: responsibility,
        inspectedBy: inspectedBy,
        chemicals: chemicals,
        safetyRequirements: safetyRequirements,
        colourCodes: colourCodes,
        equipmentRequired: equipmentRequired,
        dailyInstructions: dailyInstructions,
        weeklyInstructions: weeklyInstructions,
        monthlyInstructions: monthlyInstructions,
        quarterlyInstructions: quarterlyInstructions,
        yearlyInstructions: yearlyInstructions,
        imageUrls: [],
      );

      List<String> imageUrls = [];
      if (selectedImages.isNotEmpty) {
        // Upload new images
        imageUrls = await _uploadImages(procedure.id);
      } else {
        imageUrls = procedure.imageUrls;
      }

      // Delete images that are no longer in the list of imageUrls
      if (deleteImages.isNotEmpty) {
        for (var image in deleteImages) {
          //Get the file name from the url
          String fileName =
              image.split('/').last.split('%2F').last.split('?').first;
          await _storageService.deleteImages(procedurePath, procedure.id,
              fileName: fileName);
        }
        deleteImages.clear();
      }

      await _firestore.collection(procedurePath).doc(procedure.id).update({
        ...updatedProcedure.toFirestore(),
        'imageUrls': imageUrls,
      });

      //save the checmicals, this is for the chemicals that are not in the procedure but are in the chemicals list
      for (var chemical in chemicals) {
        await _firestore
            .collection(chemicalPath)
            .doc(chemical.chemicalId)
            .set(chemical.toFirestore());
      }

      Navigator.of(Get.overlayContext!).pop();
      resetProcedures();
      selectedImages.clear();
      Get.snackbar('Procedure Updated', 'Procedure updated successfully',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('Procedure Error', 'Error updating procedure: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  // Delete a procedure
  Future<void> deleteProcedure(Procedure procedure) async {
    try {
      isLoading.value = true;

      // Delete images first
      await _storageService.deleteImages(procedurePath, procedure.id);

      // Then delete the procedure document
      await _firestore.collection(procedurePath).doc(procedure.id).delete();

      Navigator.of(Get.overlayContext!).pop();
      resetProcedures();
      Get.snackbar('Procedure Deleted', 'Procedure deleted successfully',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('Procedure Error', 'Error deleting procedure: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }
}

class ProcedureControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProcedureController>(() => ProcedureController());
  }
}

class AccountMenuItem {
  final String id;
  final String title;

  AccountMenuItem(this.id, this.title);
}
