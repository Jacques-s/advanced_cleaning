import 'dart:io';

import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:advancedcleaning/controllers/site_controller.dart';
import 'package:advancedcleaning/models/area_model.dart';
import 'package:advancedcleaning/models/question_model.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;

class QuestionController extends GetxController {
  final AuthController authController = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;

  RxList<InspectionQuestion> questions = <InspectionQuestion>[].obs;
  RxInt totalQuestions = 0.obs;
  RxInt lastIndex = 0.obs;
  final int pageSize = 10;
  RxString sortColumn = 'createdAt'.obs;
  RxBool sortAscending = true.obs;
  DocumentSnapshot? lastDocument;

  final _titleController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _statusController = TextEditingController();

  TextEditingController get titleController => _titleController;
  TextEditingController get frequencyController => _frequencyController;
  TextEditingController get statusController => _statusController;
  String get title => _titleController.text;
  String get frequency => _frequencyController.text;
  String get status => _statusController.text;

  @override
  void onInit() {
    super.onInit();
    getTotalQuestionCount();
    fetchQuestions();
  }

  @override
  void onClose() {
    _titleController.dispose();
    super.onClose();
  }

  void resetQuestions() async {
    questions.clear();
    totalQuestions.value = 0;
    lastIndex.value = 0;
    lastDocument = null;
    await getTotalQuestionCount();
    await fetchQuestions();
  }

  Future<void> fetchQuestions({bool nextPage = false}) async {
    isLoading.value = true;

    InspectionArea? area = authController.currentArea;
    if (area == null) {
      Get.snackbar('Area Error', 'Area has not been set',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      isLoading.value = false;
      return;
    }

    try {
      Query query = _firestore
          .collection(questionPath)
          .where('accountId', isEqualTo: area.accountId)
          .where('siteId', isEqualTo: area.siteId)
          .where('areaId', isEqualTo: area.id)
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
        questions.addAll(querySnapshot.docs
            .map((doc) => InspectionQuestion.fromFirestore(doc)));
      } else {
        questions.value = querySnapshot.docs
            .map((doc) => InspectionQuestion.fromFirestore(doc))
            .toList();
      }

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
      }
    } catch (e) {
      Get.snackbar('Error', 'Error loading questions: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getTotalQuestionCount() async {
    InspectionArea? area = authController.currentArea;
    if (area == null) {
      Get.snackbar('Area Error', 'Area has not been set',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      isLoading.value = false;
      return;
    }

    try {
      AggregateQuerySnapshot snapshot = await _firestore
          .collection(questionPath)
          .where('accountId', isEqualTo: area.accountId)
          .where('siteId', isEqualTo: area.siteId)
          .where('areaId', isEqualTo: area.id)
          .count()
          .get();
      totalQuestions.value = snapshot.count ?? 0;
    } catch (e) {
      print('Error getting total question count: $e');
    }
  }

  void sort(String column, bool ascending) {
    sortColumn.value = column;
    sortAscending.value = ascending;
    fetchQuestions();
  }

  // Create a new question
  Future<void> createQuestion() async {
    try {
      isLoading.value = true;

      InspectionArea? area = authController.currentArea;
      if (area == null) {
        Get.snackbar('Question Error', 'Area has not been set',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
        return;
      }

      InspectionQuestion newQuestion = InspectionQuestion(
          id: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          title: title,
          status: Status.active,
          frequency: InspectionFrequency.daily,
          accountId: area.accountId,
          siteId: area.siteId,
          areaId: area.id);

      DocumentReference docRef = await _firestore
          .collection(questionPath)
          .add(newQuestion.toFirestore());
      await SiteController().updateAppChanges(area.siteId);

      Navigator.of(Get.overlayContext!).pop();
      resetQuestions();
      Get.snackbar('Question Created', 'Question created with ID: ${docRef.id}',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('Question Error', 'Error creating question: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  // Update an question
  Future<void> updateQuestion(InspectionQuestion question) async {
    try {
      isLoading.value = true;

      Map<String, dynamic> newData = {
        'title': title,
        'frequency': frequency,
        'status': status,
        'updatedAt': Timestamp.now()
      };

      await _firestore
          .collection(questionPath)
          .doc(question.id)
          .update(newData);
      await SiteController().updateAppChanges(question.siteId);

      Navigator.of(Get.overlayContext!).pop();
      resetQuestions();
      Get.snackbar('Question Updated', 'Question updated successfully',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('Question Error', 'Error updating question: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
  }

  // Delete an question
  Future<void> deleteQuestion(InspectionQuestion question) async {
    try {
      isLoading.value = true;

      await _firestore.collection(questionPath).doc(question.id).delete();
      await SiteController().updateAppChanges(question.siteId);

      Navigator.of(Get.overlayContext!).pop();
      resetQuestions();
      Get.snackbar('Question Deleted', 'Question deleted successfully',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } catch (e) {
      Get.snackbar('Question Error', 'Error deleting question: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    } finally {
      isLoading.value = false;
    }
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
        await importToFirestore(data);
        resetQuestions();
        Get.snackbar('Import successful ', '${data.length} rows imported',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not import questions. Reason: $e',
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

    InspectionArea? area = authController.currentArea;
    if (area == null) {
      throw ('The current area could not be found. Please reload');
    }

    WriteBatch batch = _firestore.batch();
    CollectionReference questionCollection =
        _firestore.collection(questionPath);

    for (Map<String, dynamic> row in data) {
      String? id = row['id'];
      String title = row['title'] ?? '';
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
            accountId: area.accountId,
            siteId: area.siteId,
            areaId: area.id);

        DocumentReference docRef =
            questionCollection.doc(id); //if id is set, update, else create
        batch.set(docRef, question.toFirestore());
      }
    }

    await batch.commit();
  }

  Future<void> exportDataToExcel() async {
    try {
      isLoading.value = true;
      //Request storage permission (if needed)
      if (await _requestPermission(Permission.storage)) {
        InspectionArea? area = authController.currentArea;
        if (area == null) {
          throw ('The current area could not be found. Please reload');
        }

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(questionPath)
            .where('areaId', isEqualTo: area.id)
            .get();

        // Create a new Excel document
        var excel = Excel.createExcel();
        Sheet sheetObject = excel['Sheet1'];
        sheetObject.setColumnWidth(0, 30);
        sheetObject.setColumnWidth(1, 35);
        sheetObject.setColumnWidth(2, 30);
        sheetObject.setColumnWidth(3, 10);
        sheetObject.setColumnWidth(4, 10);
        sheetObject.setColumnWidth(5, 10);
        sheetObject.setColumnWidth(6, 10);
        sheetObject.setColumnWidth(7, 10);

        CellStyle cellStyle = CellStyle(
            backgroundColorHex: ExcelColor.blue200,
            fontFamily: getFontFamily(FontFamily.Calibri));
        cellStyle.underline = Underline.Single;
        cellStyle.fontSize = 14;

        //Add headers
        var idCell = sheetObject.cell(CellIndex.indexByString('A1'));
        idCell.value = TextCellValue('Question ID');
        idCell.cellStyle = cellStyle;

        var titleCell = sheetObject.cell(CellIndex.indexByString('B1'));
        titleCell.value = TextCellValue('Question Title');
        titleCell.cellStyle = cellStyle;

        var areaIdCell = sheetObject.cell(CellIndex.indexByString('C1'));
        areaIdCell.value = TextCellValue('Area ID');
        areaIdCell.cellStyle = cellStyle;

        var frequencyDailyCell =
            sheetObject.cell(CellIndex.indexByString('D1'));
        frequencyDailyCell.value = TextCellValue('Daily');
        frequencyDailyCell.cellStyle = cellStyle;

        var frequencyWeeklyCell =
            sheetObject.cell(CellIndex.indexByString('E1'));
        frequencyWeeklyCell.value = TextCellValue('Weekly');
        frequencyWeeklyCell.cellStyle = cellStyle;

        var frequencyMonthlyCell =
            sheetObject.cell(CellIndex.indexByString('F1'));
        frequencyMonthlyCell.value = TextCellValue('Monthly');
        frequencyMonthlyCell.cellStyle = cellStyle;

        var frequencyQuarterlyCell =
            sheetObject.cell(CellIndex.indexByString('G1'));
        frequencyQuarterlyCell.value = TextCellValue('Quarterly');
        frequencyQuarterlyCell.cellStyle = cellStyle;

        var frequencyAnnuallyCell =
            sheetObject.cell(CellIndex.indexByString('H1'));
        frequencyAnnuallyCell.value = TextCellValue('Annually');
        frequencyAnnuallyCell.cellStyle = cellStyle;

        // Add Firestore data to Excel
        for (var doc in querySnapshot.docs) {
          InspectionQuestion question = InspectionQuestion.fromFirestore(doc);
          sheetObject.appendRow([
            TextCellValue(question.id),
            TextCellValue(question.title),
            TextCellValue(question.areaId),
            question.frequency == InspectionFrequency.daily
                ? TextCellValue('X')
                : TextCellValue(''),
            question.frequency == InspectionFrequency.weekly
                ? TextCellValue('X')
                : TextCellValue(''),
            question.frequency == InspectionFrequency.monthly
                ? TextCellValue('X')
                : TextCellValue(''),
            question.frequency == InspectionFrequency.quarterly
                ? TextCellValue('X')
                : TextCellValue(''),
            question.frequency == InspectionFrequency.annually
                ? TextCellValue('X')
                : TextCellValue(''),
          ]);
        }

        // Save the Excel file to the device
        String filePath = await saveExcelFile(excel, 'Question_Export.xlsx');
        Get.snackbar('Questions Exported', 'Saved at: $filePath',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not export questions. Reason: $e',
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
        sheetObject.setColumnWidth(0, 30);
        sheetObject.setColumnWidth(1, 35);
        sheetObject.setColumnWidth(2, 30);
        sheetObject.setColumnWidth(3, 10);
        sheetObject.setColumnWidth(4, 10);
        sheetObject.setColumnWidth(5, 10);
        sheetObject.setColumnWidth(6, 10);
        sheetObject.setColumnWidth(7, 10);

        CellStyle cellStyle = CellStyle(
            backgroundColorHex: ExcelColor.blue200,
            fontFamily: getFontFamily(FontFamily.Calibri));
        cellStyle.underline = Underline.Single;
        cellStyle.fontSize = 14;

        //Add headers
        var idCell = sheetObject.cell(CellIndex.indexByString('A1'));
        idCell.value = TextCellValue('Question ID');
        idCell.cellStyle = cellStyle;

        var titleCell = sheetObject.cell(CellIndex.indexByString('B1'));
        titleCell.value = TextCellValue('Question Title');
        titleCell.cellStyle = cellStyle;

        var areaIdCell = sheetObject.cell(CellIndex.indexByString('C1'));
        areaIdCell.value = TextCellValue('Area ID');
        areaIdCell.cellStyle = cellStyle;

        var frequencyDailyCell =
            sheetObject.cell(CellIndex.indexByString('D1'));
        frequencyDailyCell.value = TextCellValue('Daily');
        frequencyDailyCell.cellStyle = cellStyle;

        var frequencyWeeklyCell =
            sheetObject.cell(CellIndex.indexByString('E1'));
        frequencyWeeklyCell.value = TextCellValue('Weekly');
        frequencyWeeklyCell.cellStyle = cellStyle;

        var frequencyMonthlyCell =
            sheetObject.cell(CellIndex.indexByString('F1'));
        frequencyMonthlyCell.value = TextCellValue('Monthly');
        frequencyMonthlyCell.cellStyle = cellStyle;

        var frequencyQuarterlyCell =
            sheetObject.cell(CellIndex.indexByString('G1'));
        frequencyQuarterlyCell.value = TextCellValue('Quarterly');
        frequencyQuarterlyCell.cellStyle = cellStyle;

        var frequencyAnnuallyCell =
            sheetObject.cell(CellIndex.indexByString('H1'));
        frequencyAnnuallyCell.value = TextCellValue('Annually');
        frequencyAnnuallyCell.cellStyle = cellStyle;

        // Save the Excel file to the device
        String filePath = await saveExcelFile(excel, 'Question_Export.xlsx');
        Get.snackbar('Questions Exported', 'Saved at: $filePath',
            duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not export questions. Reason: $e',
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

class QuestionManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuestionController>(() => QuestionController());
  }
}
