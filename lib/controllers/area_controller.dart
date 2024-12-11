import 'dart:io';

import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:advancedcleaning/controllers/site_controller.dart';
import 'package:advancedcleaning/models/area_model.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:advancedcleaning/models/inspection_models/question_model.dart';
import 'package:advancedcleaning/models/site_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;

class AreaController extends GetxController {
  final AuthController authController = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;

  RxList<InspectionArea> areas = <InspectionArea>[].obs;
  RxInt totalAreas = 0.obs;
  RxInt lastIndex = 0.obs;
  final int pageSize = 10;
  RxString sortColumn = 'createdAt'.obs;
  RxBool sortAscending = true.obs;
  DocumentSnapshot? lastDocument;

  final _titleController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _statusController = TextEditingController();

  TextEditingController get titleController => _titleController;
  TextEditingController get barcodeController => _barcodeController;
  TextEditingController get statusController => _statusController;
  String get title => _titleController.text;
  String get barcode => _barcodeController.text;
  String get status => _statusController.text;

  @override
  void onInit() {
    super.onInit();
    getTotalAreaCount();
    fetchAreas();
  }

  @override
  void onClose() {
    _titleController.dispose();
    super.onClose();
  }

  void resetAreas() async {
    areas.clear();
    totalAreas.value = 0;
    lastIndex.value = 0;
    lastDocument = null;
    await getTotalAreaCount();
    await fetchAreas();
  }

  Future<void> fetchAreas({bool nextPage = false}) async {
    isLoading.value = true;

    Site? site = authController.currentSite;
    if (site == null) {
      Get.snackbar('Site Error', 'Site has not been set',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      isLoading.value = false;
      return;
    }

    try {
      Query query = _firestore
          .collection(areaPath)
          .where('accountId', isEqualTo: site.accountId)
          .where('siteId', isEqualTo: site.id)
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
        areas.addAll(
            querySnapshot.docs.map((doc) => InspectionArea.fromFirestore(doc)));
      } else {
        areas.value = querySnapshot.docs
            .map((doc) => InspectionArea.fromFirestore(doc))
            .toList();
      }

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
      }
    } catch (e) {
      Get.snackbar('Error', 'Error loading areas: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTotalAreaCount() async {
    Site? site = authController.currentSite;
    if (site == null) {
      Get.snackbar('Site Error', 'Site has not been set',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      isLoading.value = false;
      return;
    }

    try {
      AggregateQuerySnapshot snapshot = await _firestore
          .collection(areaPath)
          .where('accountId', isEqualTo: site.accountId)
          .where('siteId', isEqualTo: site.id)
          .count()
          .get();
      totalAreas.value = snapshot.count ?? 0;
    } catch (e) {
      print('Error getting total area count: $e');
    }
  }

  void sort(String column, bool ascending) {
    sortColumn.value = column;
    sortAscending.value = ascending;
    fetchAreas();
  }

  // Create a new area
  Future<void> createArea() async {
    try {
      isLoading.value = true;

      Site? site = authController.currentSite;
      if (site == null) {
        Get.snackbar('Area Error', 'Site has not been set',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
        return;
      }

      InspectionArea newArea = InspectionArea(
          id: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          title: title,
          status: Status.active,
          barcode: barcode,
          accountId: site.accountId,
          siteId: site.id);

      DocumentReference docRef =
          await _firestore.collection(areaPath).add(newArea.toFirestore());

      await SiteController().updateAppChanges(site.id);

      Navigator.of(Get.overlayContext!).pop();
      resetAreas();
      Get.snackbar('Area Created', 'Area created with ID: ${docRef.id}',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('Area Error', 'Error creating area: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  // Update an area
  Future<void> updateArea(InspectionArea area) async {
    try {
      isLoading.value = true;

      Map<String, dynamic> newData = {
        'title': title,
        'barcode': barcode,
        'status': status,
        'updatedAt': Timestamp.now()
      };

      await _firestore.collection(areaPath).doc(area.id).update(newData);
      await SiteController().updateAppChanges(area.siteId);

      Navigator.of(Get.overlayContext!).pop();
      resetAreas();
      Get.snackbar('Area Updated', 'Area updated successfully',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('Area Error', 'Error updating area: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  // Delete an area
  Future<void> deleteArea(InspectionArea area) async {
    try {
      isLoading.value = true;

      await _firestore.collection(areaPath).doc(area.id).delete();
      await SiteController().updateAppChanges(area.siteId);

      Navigator.of(Get.overlayContext!).pop();
      resetAreas();
      Get.snackbar('Area Deleted', 'Area deleted successfully',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('Area Error', 'Error deleting area: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  //Imports areas from excel
  Future<void> importAreaData(Uint8List bytes) async {
    try {
      isLoading.value = true;

      var excel = Excel.decodeBytes(bytes);

      List<Map<String, dynamic>> data = [];
      for (var table in excel.tables.keys) {
        var rows = excel.tables[table]?.rows;
        if (rows != null) {
          for (var row in rows) {
            Map<String, dynamic> rowData = {};
            for (var cell in row) {
              if (cell != null) {
                final cellValue = cell.value;
                final rowIndex = cell.rowIndex;
                final columnIndex = cell.columnIndex;

                //Make sure the user is using the correct template
                if (rowIndex == 0 && columnIndex == 0) {
                  if (cellValue == null || cellValue.toString() != 'Area ID') {
                    throw ('This import file does not look correct. Make sure the colunm header is \'Area ID\'');
                  }
                }
                if (rowIndex == 0 && columnIndex == 1) {
                  if (cellValue == null ||
                      cellValue.toString() != 'Area Title') {
                    throw ('This import file does not look correct. Make sure the colunm header is \'Area Title\'');
                  }
                }
                if (rowIndex == 0 && columnIndex == 2) {
                  if (cellValue == null || cellValue.toString() != 'Barcode') {
                    throw ('This import file does not look correct. Make sure the colunm header is \'Barcode\'');
                  }
                }
                //

                if (rowIndex > 0) {
                  // do not add the headers
                  //Make sure the cell has value else break out. Import all or nothing
                  if (cellValue == null && columnIndex > 0) {
                    throw ('Some of your cells have empty values');
                  } else {
                    if (columnIndex == 0) {
                      rowData.addAll({'id': cellValue?.toString()});
                    }
                    if (columnIndex == 1) {
                      rowData.addAll({'title': cellValue.toString()});
                    }
                    if (columnIndex == 2) {
                      rowData.addAll({'barcode': cellValue.toString()});
                    }
                  }
                }
              }
            }

            if (rowData.isNotEmpty) {
              data.add(rowData);
            }
          }
        }
      }

      if (data.isNotEmpty) {
        await importToFirestore(data);
        resetAreas();
        Get.snackbar('Import successful ', '${data.length} rows imported',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not import areas. Reason: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  //Imports the data to firestore for the current site
  Future<void> importToFirestore(List<Map<String, dynamic>> data) async {
    if (data.length > 400) {
      throw ('The sheet contains too many rows. Please split up your file so that it contains less than 400 rows');
    }

    Site? site = authController.currentSite;
    if (site == null) {
      throw ('The current site could not be found. Please reload');
    }

    WriteBatch batch = _firestore.batch();
    CollectionReference areaCollection = _firestore.collection(areaPath);

    for (Map<String, dynamic> row in data) {
      String? id = row['id'];
      String title = row['title'] ?? '';
      String barcode = row['barcode'] ?? '';
      if (title.isNotEmpty && barcode.isNotEmpty) {
        InspectionArea area = InspectionArea(
            id: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            title: title,
            barcode: barcode,
            status: Status.active,
            accountId: site.accountId,
            siteId: site.id);

        DocumentReference docRef =
            areaCollection.doc(id); //if id is set, update, else create
        batch.set(docRef, area.toFirestore());
      }
    }

    await batch.commit();
  }

  //Imports questions from excel
  Future<void> importQuestionData(Uint8List bytes) async {
    try {
      isLoading.value = true;

      var excel = Excel.decodeBytes(bytes);

      List<Map<String, dynamic>> data = [];
      for (var table in excel.tables.keys) {
        var rows = excel.tables[table]?.rows;
        if (rows != null) {
          for (var row in rows) {
            Map<String, dynamic> rowData = {};
            for (var cell in row) {
              if (cell != null) {
                final cellValue = cell.value;
                final rowIndex = cell.rowIndex;
                final columnIndex = cell.columnIndex;

                //Make sure the user is using the correct template
                if (rowIndex == 0) {
                  if (columnIndex == 0) {
                    if (cellValue == null ||
                        cellValue.toString() != 'Question ID') {
                      throw ('This import file does not look correct. Make sure the colunm header is \'Question ID\'');
                    }
                  }
                  if (columnIndex == 1) {
                    if (cellValue == null ||
                        cellValue.toString() != 'Question Title') {
                      throw ('This import file does not look correct. Make sure the colunm header is \'Question Title\'');
                    }
                  }
                  if (columnIndex == 2) {
                    if (cellValue == null ||
                        cellValue.toString() != 'Area ID') {
                      throw ('This import file does not look correct. Make sure the colunm header is \'Area ID\'');
                    }
                  }
                  if (columnIndex == 3) {
                    if (cellValue == null || cellValue.toString() != 'Daily') {
                      throw ('This import file does not look correct. Make sure the colunm header is \'Daily\'');
                    }
                  }
                  if (columnIndex == 4) {
                    if (cellValue == null || cellValue.toString() != 'Weekly') {
                      throw ('This import file does not look correct. Make sure the colunm header is \'Weekly\'');
                    }
                  }
                  if (columnIndex == 5) {
                    if (cellValue == null ||
                        cellValue.toString() != 'Monthly') {
                      throw ('This import file does not look correct. Make sure the colunm header is \'Monthly\'');
                    }
                  }
                  if (columnIndex == 6) {
                    if (cellValue == null ||
                        cellValue.toString() != 'Quarterly') {
                      throw ('This import file does not look correct. Make sure the colunm header is \'Quarterly\'');
                    }
                  }
                  if (columnIndex == 7) {
                    if (cellValue == null ||
                        cellValue.toString() != 'Annually') {
                      throw ('This import file does not look correct. Make sure the colunm header is \'Annually\'');
                    }
                  }
                }
                //

                if (rowIndex > 0) {
                  // do not add the headers
                  //Make sure the cell has value else break out. Import all or nothing
                  if (cellValue == null && columnIndex > 0) {
                    throw ('Some of your cells have empty values');
                  } else {
                    if (columnIndex == 0) {
                      rowData.addAll({'id': cellValue?.toString()});
                    }
                    if (columnIndex == 1) {
                      rowData.addAll({'title': cellValue.toString()});
                    }
                    if (columnIndex == 2) {
                      rowData.addAll({'areaId': cellValue.toString()});
                    }
                    //Check the frequency
                    if (columnIndex == 3 && cellValue.toString().isNotEmpty) {
                      rowData.addAll(
                          {'frequency': InspectionFrequency.daily.name});
                    }
                    if (columnIndex == 4 && cellValue.toString().isNotEmpty) {
                      rowData.addAll(
                          {'frequency': InspectionFrequency.weekly.name});
                    }
                    if (columnIndex == 5 && cellValue.toString().isNotEmpty) {
                      rowData.addAll(
                          {'frequency': InspectionFrequency.monthly.name});
                    }
                    if (columnIndex == 6 && cellValue.toString().isNotEmpty) {
                      rowData.addAll(
                          {'frequency': InspectionFrequency.quarterly.name});
                    }
                    if (columnIndex == 7 && cellValue.toString().isNotEmpty) {
                      rowData.addAll(
                          {'frequency': InspectionFrequency.annually.name});
                    }
                  }
                }
              }
            }

            if (rowData.isNotEmpty) {
              data.add(rowData);
            }
          }
        }
      }

      if (data.isNotEmpty) {
        await importToQuestionsFirestore(data);
        Get.snackbar('Import successful ', '${data.length} rows imported',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not import questions. Reason: $e',
          duration: const Duration(seconds: 3));
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _commitBatchSafely(WriteBatch batch) async {
    try {
      await batch.commit();
    } catch (e) {
      print("Error submitting batch: $e");
    }
  }

  //Imports the data to firestore for the current site
  Future<void> importToQuestionsFirestore(
      List<Map<String, dynamic>> data) async {
    Site? site = authController.currentSite;
    if (site == null) {
      throw ('The current site could not be found. Please reload');
    }

    //fetch the areas
    Query query = _firestore
        .collection(areaPath)
        .where('accountId', isEqualTo: site.accountId)
        .where('siteId', isEqualTo: site.id)
        .orderBy(sortColumn.value, descending: !sortAscending.value);

    QuerySnapshot querySnapshot = await query.get();

    List<String> areaIds = querySnapshot.docs.map((doc) => doc.id).toList();
    //

    if (areaIds.isEmpty) {
      throw ('The current site has no areas yet');
    }

    const int batchSize = 400;
    int batchCounter = 0;
    WriteBatch batch = _firestore.batch();
    CollectionReference questionCollection =
        _firestore.collection(questionPath);

    //Check if all the areas exist
    for (Map<String, dynamic> row in data) {
      String areaId = row['areaId'] ?? '';

      if (areaId.isEmpty || !areaIds.contains(areaId)) {
        throw ('The area with id ($areaId) could not be found');
      }
    }
    //

    for (Map<String, dynamic> row in data) {
      if (batchCounter == batchSize) {
        // Commit the current batch and create a new one
        await _commitBatchSafely(batch);
        batch = _firestore.batch();
        batchCounter = 0;
      }

      String? id = row['id'];
      String title = row['title'] ?? '';
      String areaId = row['areaId'] ?? '';
      String frequency = row['frequency'] ?? '';

      if (title.isNotEmpty && frequency.isNotEmpty) {
        InspectionFrequency questionFrequency = InspectionFrequency.values
            .firstWhere((val) => val.toString().split('.').last == frequency,
                orElse: () => InspectionFrequency.daily);

        InspectionQuestion question = InspectionQuestion(
            id: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            title: title,
            frequency: questionFrequency,
            status: Status.active,
            accountId: site.accountId,
            siteId: site.id,
            areaId: areaId);

        DocumentReference docRef =
            questionCollection.doc(id); //if id is set, update, else create
        batch.set(docRef, question.toFirestore());
        batchCounter++;
      }
    }
    // Commit the remaining batch
    if (batchCounter > 0) {
      await _commitBatchSafely(batch);
    }

    Get.snackbar('Import successful ', '${data.length} rows imported',
        duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
  }

  Future<void> exportDataToExcel() async {
    try {
      isLoading.value = true;
      //Request storage permission (if needed)
      if (await _requestPermission(Permission.storage)) {
        Site? site = authController.currentSite;
        if (site == null) {
          throw ('The current site could not be found. Please reload');
        }

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(areaPath)
            .where('siteId', isEqualTo: site.id)
            .get();

        // Create a new Excel document
        var excel = Excel.createExcel();
        Sheet sheetObject = excel['Sheet1'];
        sheetObject.setColumnAutoFit(0);
        sheetObject.setColumnAutoFit(1);
        sheetObject.setColumnAutoFit(2);

        CellStyle cellStyle = CellStyle(
            backgroundColorHex: ExcelColor.blue200,
            fontFamily: getFontFamily(FontFamily.Calibri));
        cellStyle.underline = Underline.Single;
        cellStyle.fontSize = 14;

        //Add headers
        var idCell = sheetObject.cell(CellIndex.indexByString('A1'));
        idCell.value = TextCellValue('Area ID');
        idCell.cellStyle = cellStyle;

        var titleCell = sheetObject.cell(CellIndex.indexByString('B1'));
        titleCell.value = TextCellValue('Area Title');
        titleCell.cellStyle = cellStyle;

        var barcodeCell = sheetObject.cell(CellIndex.indexByString('C1'));
        barcodeCell.value = TextCellValue('Barcode');
        barcodeCell.cellStyle = cellStyle;

        // Add Firestore data to Excel
        for (var doc in querySnapshot.docs) {
          InspectionArea area = InspectionArea.fromFirestore(doc);
          sheetObject.appendRow([
            TextCellValue(area.id),
            TextCellValue(area.title),
            TextCellValue(area.barcode),
          ]);
        }

        // Save the Excel file to the device
        String filePath = await saveExcelFile(excel, 'Area_Export.xlsx');
        Get.snackbar('Areas Exported', 'Saved at: $filePath',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not export areas. Reason: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportTemplateToExcel() async {
    try {
      isLoading.value = true;
      //Request storage permission (if needed)
      if (await _requestPermission(Permission.storage)) {
        // Create a new Excel document
        var excel = Excel.createExcel();
        Sheet sheetObject = excel['Sheet1'];
        sheetObject.setColumnAutoFit(0);
        sheetObject.setColumnAutoFit(1);
        sheetObject.setColumnAutoFit(2);

        CellStyle cellStyle = CellStyle(
            backgroundColorHex: ExcelColor.blue200,
            fontFamily: getFontFamily(FontFamily.Calibri));
        cellStyle.underline = Underline.Single;
        cellStyle.fontSize = 14;

        //Add headers
        var idCell = sheetObject.cell(CellIndex.indexByString('A1'));
        idCell.value = TextCellValue('Area ID');
        idCell.cellStyle = cellStyle;

        var titleCell = sheetObject.cell(CellIndex.indexByString('B1'));
        titleCell.value = TextCellValue('Area Title');
        titleCell.cellStyle = cellStyle;

        var barcodeCell = sheetObject.cell(CellIndex.indexByString('C1'));
        barcodeCell.value = TextCellValue('Barcode');
        barcodeCell.cellStyle = cellStyle;

        // Save the Excel file to the device
        String filePath = await saveExcelFile(excel, 'Area_Export.xlsx');
        Get.snackbar('Areas Exported', 'Saved at: $filePath',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not export areas. Reason: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  //Function to save Excel file to the device
  Future<String> saveExcelFile(Excel excel, String fileName) async {
    if (kIsWeb) {
      // Convert the Excel document to bytes
      List<int> bytes = excel.encode()!;

      // Convert to Uint8List
      Uint8List excelBytes = Uint8List.fromList(bytes);

      // Create a Blob containing the data
      final blob = html.Blob([excelBytes]);

      // Create a URL for the Blob
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create an anchor element with the URL
      html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click(); // Simulate a click to trigger the download

      // Clean up by revoking the object URL
      html.Url.revokeObjectUrl(url);

      return 'downloads';
    } else {
      // Get the directory for saving the file
      Directory? directory = await getDownloadsDirectory();

      if (directory != null) {
        // Create the file path
        String filePath = '${directory.path}/$fileName';

        // Save the Excel file
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(excel.save()!);

        return filePath;
      }
    }

    return '';
  }

  // Function to request storage permission
  Future<bool> _requestPermission(Permission permission) async {
    //ignore if it is on web or macos
    if (kIsWeb == true || Platform.isMacOS == true) {
      return true;
    } else {
      if (await permission.isGranted) {
        return true;
      } else {
        var result = await permission.request();
        return result == PermissionStatus.granted;
      }
    }
  }
}

class AreaManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AreaController>(() => AreaController());
  }
}
