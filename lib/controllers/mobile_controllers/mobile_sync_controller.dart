import 'dart:async';

import 'package:advancedcleaning/constants/app_constants.dart';
import 'package:advancedcleaning/controllers/auth_controller.dart';
import 'package:advancedcleaning/models/account_model.dart';
import 'package:advancedcleaning/models/inspection_models/answer_model.dart';
import 'package:advancedcleaning/models/area_model.dart';
import 'package:advancedcleaning/models/ncr_models/client_ncr_model.dart';
import 'package:advancedcleaning/models/enum_model.dart';
import 'package:advancedcleaning/models/inspection_models/inspection_model.dart';
import 'package:advancedcleaning/models/inspection_models/question_answer_model.dart';
import 'package:advancedcleaning/models/inspection_models/question_model.dart';
import 'package:advancedcleaning/models/notification_model.dart';
import 'package:advancedcleaning/models/site_model.dart';
import 'package:advancedcleaning/models/user_model.dart';
import 'package:advancedcleaning/models_mobile/db_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

class MobileSyncController extends GetxController {
  final AuthController authController = Get.find();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;

  static const _databaseName = "acs.db";
  static const _databaseVersion = 1;

  // Make this a singleton class
  MobileSyncController._privateConstructor();
  static final MobileSyncController instance =
      MobileSyncController._privateConstructor();

  // Only allow a single open connection to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Open the database and create it if it doesn't exist
  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = '$databasesPath/$_databaseName';

    return await openDatabase(dbPath,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> getDbPath() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = '$databasesPath/$_databaseName';
    Get.snackbar('Database Path', dbPath, duration: const Duration(seconds: 5));
    print(dbPath);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute(DbAccounts.createStatement);
    await db.execute(DbSites.createStatement);
    await db.execute(DbAreas.createStatement);
    await db.execute(DbQuestions.createStatement);
    await db.execute(DbInspections.createStatement);
    await db.execute(DbInspectionAnswers.createStatement);
  }

  Future<void> pullSync() async {
    isLoading.value = true;
    try {
      List<Future> futures = [
        fetchAccounts(),
        fetchSites(),
        fetchArea(),
        fetchQuestions()
      ];

      List promises = await Future.wait(futures);
      bool allTrue = promises.every((promise) => promise == true);
      if (allTrue) {
        //update the users lastSync
        Map<String, dynamic> newData = {
          'lastSynced': Timestamp.now(),
        };

        if (authController.currentUserId != null) {
          await _firestore
              .collection(userPath)
              .doc(authController.currentUserId)
              .update(newData);
        }
      }
    } catch (e) {
      print("Error puling from server: $e");
    } finally {
      isLoading.value = false;
    }
  }

  //This will check if there are any new changes based on the site sync time and the user last sync time.
  //If the timestamps are out of date, the app will pull all data
  Future<bool> checkIfOutdated({bool overideTime = false}) async {
    Database db = await instance.database;
    try {
      String siteID = authController.currentUserSiteId ?? '';
      if (siteID.isEmpty) {
        throw ('No site assigned');
      }

      //check if any sites exits
      final rawSite = await db.query(DbSites.table,
          where: '${DbSites.columnStatus} = ?',
          whereArgs: ['active'],
          limit: 1);

      if (rawSite.isEmpty) {
        print("Pulling data");
        await pullSync();
        return true;
      } else {
        final earlier = DateTime.now().subtract(const Duration(hours: 5));
        //Only check the sync time on the server if the users has not synced in the last 5 hours
        if (overideTime == true ||
            (authController.currentUser!.lastSynced == null ||
                authController.currentUser!.lastSynced!.isBefore(earlier))) {
          DocumentSnapshot documentSnapshot =
              await _firestore.collection(sitePath).doc(siteID).get();

          if (documentSnapshot.exists) {
            Site site = Site.fromFirestore(documentSnapshot);

            if (site.appChanges != null &&
                authController.currentUser!.lastSynced != null) {
              if (site.appChanges!
                  .isBefore(authController.currentUser!.lastSynced!)) {
                print("Pulling data");
                await pullSync();
                return true;
              }
            }
          }
        }
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Error checking for updates: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
    }

    return false;
  }

  Future<void> deleteDatabaseFile() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = '$databasesPath/$_databaseName';

    //First push any unsynced inspections
    await pushAllInspections();
    await deleteDatabase(dbPath);
    _database = null;
  }

  // CRUD operations

  Future<bool> fetchAccounts() async {
    try {
      String accountID = authController.currentUser!.accountId ?? '';
      if (accountID.isEmpty) {
        throw ('No account assigned');
      }

      DocumentSnapshot documentSnapshot =
          await _firestore.collection(accountPath).doc(accountID).get();

      if (documentSnapshot.exists) {
        await insertAccount(Account.fromFirestore(documentSnapshot));
      }
      return true;
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Error loading accounts: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      return false;
    }
  }

  Future<int> insertAccount(Account account) async {
    Database db = await instance.database;
    return await db.insert(DbAccounts.table, account.toDB(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> fetchSites() async {
    try {
      String accountId = authController.currentAccountId ?? '';
      if (accountId.isEmpty) {
        throw ('No account assigned');
      }

      QuerySnapshot snapshot = await _firestore
          .collection(sitePath)
          .where('accountId', isEqualTo: accountId)
          .get();

      List<Site> sites =
          snapshot.docs.map((doc) => Site.fromFirestore(doc)).toList();

      if (sites.isNotEmpty) {
        for (Site site in sites) {
          await insertSite(site);
        }
      }

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Error loading sites: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      return false;
    }
  }

  Future<int> insertSite(Site site) async {
    Database db = await instance.database;
    return await db.insert(DbSites.table, site.toDB(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> fetchArea() async {
    try {
      String accountId = authController.currentUser!.accountId ?? '';
      if (accountId.isEmpty) {
        throw ('No account assigned for areas');
      }

      String siteId = authController.currentUserSiteId ?? '';
      if (siteId.isEmpty) {
        throw ('No sites assigned for areas');
      }

      QuerySnapshot snapshot = await _firestore
          .collection(areaPath)
          .where('accountId', isEqualTo: accountId)
          .where('siteId', isEqualTo: siteId)
          .get();

      List<InspectionArea> areas = snapshot.docs
          .map((doc) => InspectionArea.fromFirestore(doc))
          .toList();

      if (areas.isNotEmpty) {
        for (InspectionArea area in areas) {
          await insertArea(area);
        }
      }

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Error loading areas: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      return false;
    }
  }

  Future<int> insertArea(InspectionArea area) async {
    Database db = await instance.database;
    return await db.insert(DbAreas.table, area.toDB(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> fetchQuestions() async {
    try {
      String accountId = authController.currentUser!.accountId ?? '';
      if (accountId.isEmpty) {
        throw ('No account assigned for questions');
      }

      String siteId = authController.currentUserSiteId ?? '';
      if (siteId.isEmpty) {
        throw ('No sites assigned for questions');
      }

      QuerySnapshot snapshot = await _firestore
          .collection(questionPath)
          .where('accountId', isEqualTo: accountId)
          .where('siteId', isEqualTo: siteId)
          .get();

      List<InspectionQuestion> questions = snapshot.docs
          .map((doc) => InspectionQuestion.fromFirestore(doc))
          .toList();

      if (questions.isNotEmpty) {
        for (InspectionQuestion question in questions) {
          await insertQuestion(question);
        }
      }

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Error loading questions: $e',
          duration: appSnackBarDuration, backgroundColor: appSnackBarColor);
      return false;
    }
  }

  Future<int> insertQuestion(InspectionQuestion question) async {
    Database db = await instance.database;
    return await db.insert(DbQuestions.table, question.toDB(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertInspection(Inspection inspection) async {
    Database db = await instance.database;
    return await db.insert(DbInspections.table, inspection.toDB(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertAnswer(InspectionAnswer answer) async {
    Database db = await instance.database;
    return await db.insert(DbInspectionAnswers.table, answer.toDB(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getMissingSiteAreas(
      String? inspectionID) async {
    Database db = await instance.database;
    if (authController.currentUserSiteId != null) {
      inspectionID ??= '-1';
      try {
        return await db.rawQuery('''
      SELECT ${DbAreas.table}.${DbAreas.columnTitle} AS 'areaTitle',
      ${DbAreas.table}.${DbAreas.columnBarcode} AS 'areaBarcode',
      ${DbInspectionAnswers.table}.${DbInspectionAnswers.columnId} AS 'isCompleded'
      FROM ${DbAreas.table} 
      LEFT JOIN ${DbInspectionAnswers.table} ON ${DbAreas.table}.${DbAreas.columnId} = ${DbInspectionAnswers.table}.${DbInspectionAnswers.columnAreaId}
      AND ${DbInspectionAnswers.table}.${DbInspectionAnswers.columnInspectionId} = '$inspectionID'
      WHERE ${DbAreas.table}.${DbAreas.columnSiteId} = '${authController.currentUserSiteId}'
      AND ${DbAreas.table}.${DbAreas.columnStatus} = 'active'
      GROUP BY ${DbAreas.table}.${DbAreas.columnId}
      ORDER BY ${DbAreas.table}.${DbAreas.columnTitle}
      ''');
      } catch (e) {
        print(e);
      }
    }

    return Future.value(List.empty());
  }

  // Get all the questions for a area and convert to local QuestionAnswer objects
  Future<Map<String, dynamic>> getAreaQuestions(String areaBarcode) async {
    Database db = await instance.database;

    final rawArea = await db.query(DbAreas.table,
        where: '${DbAreas.columnBarcode} = ? AND ${DbAreas.columnStatus} = ?',
        whereArgs: [areaBarcode, 'active'],
        limit: 1);

    if (rawArea.isNotEmpty) {
      InspectionArea area = InspectionArea.fromDB(rawArea.first);

      final rawQuestions = await db.query(DbQuestions.table,
          where:
              '${DbQuestions.columnAreaId} = ? AND ${DbQuestions.columnStatus} = ?',
          whereArgs: [area.id, 'active']);

      if (rawQuestions.isNotEmpty) {
        List<InspectionQuestion> questions = rawQuestions
            .map((question) => InspectionQuestion.fromDB(question))
            .toList();

        List<QuestionAnswer> questionAnswers = [];
        for (InspectionQuestion question in questions) {
          questionAnswers.add(QuestionAnswer(
              title: question.title,
              frequency: question.frequency,
              accountId: question.accountId,
              siteId: question.siteId,
              areaId: question.areaId,
              questionId: question.id,
              lastInspectionDate: question.lastInspectionDate,
              lastInspectionResult: question.lastInspectionResult,
              nextInspectionDate: question.nextInspectionDate));
        }

        return {'area': area, 'questions': questionAnswers};
      }
    }

    throw ('Area not found');
  }

  Future<InspectionArea?> getLocalAreaByBarcode(String areaBarcode) async {
    Database db = await instance.database;
    final rawArea = await db.query(DbAreas.table,
        where: '${DbAreas.columnBarcode} = ?',
        whereArgs: [areaBarcode],
        limit: 1);
    if (rawArea.isNotEmpty) {
      return InspectionArea.fromDB(rawArea.first);
    }
    return null;
  }

  // Gets all the user's linked sites
  Future<List<Site>> getUserSites() async {
    Database db = await instance.database;

    List<String> userSites = authController.currentSiteIds;
    if (userSites.isNotEmpty) {
      String whereClause = '\'${userSites.join('\', \'')}\'';

      final sql = '''
          SELECT * FROM ${DbSites.table} 
          WHERE ${DbSites.columnId} IN ($whereClause) AND ${DbSites.columnStatus} = 'active'
          ''';
      final rawSites = await db.rawQuery(sql);
      if (rawSites.isNotEmpty) {
        return rawSites.map((site) => Site.fromDB(site)).toList();
      }
    }

    return [];
  }

  Future<Site?> getSite(String siteId) async {
    Database db = await instance.database;

    final rawSite = await db.query(DbSites.table,
        where: '${DbSites.columnId} = ? AND ${DbSites.columnStatus} = ?',
        whereArgs: [siteId, 'active'],
        limit: 1);

    if (rawSite.isNotEmpty) {
      return Site.fromDB(rawSite.first);
    } else {
      return null;
    }
  }

  // Delete an ispection and all its answers from local db
  Future<void> deleteInspection(String inspectionId) async {
    Database db = await instance.database;
    try {
      await db.delete(DbInspectionAnswers.table,
          where: '${DbInspectionAnswers.columnInspectionId} = ?',
          whereArgs: [inspectionId]);

      await db.delete(DbInspections.table,
          where: '${DbInspections.columnId} = ?', whereArgs: [inspectionId]);
    } catch (e) {
      print('Error deleteing inspection: $e');
    }
  }

  Future<Map<String, Map>?> calculateScores(String inspectionID) async {
    Database db = await instance.database;
    try {
      final results = await db.rawQuery('''
      SELECT 
      ${DbAreas.table}.${DbAreas.columnId} AS 'areaID',
      ${DbAreas.table}.${DbAreas.columnTitle} AS 'areaTitle',
      ${DbInspectionAnswers.table}.${DbInspectionAnswers.columnStatus} AS 'status',
      COUNT(${DbInspectionAnswers.table}.${DbInspectionAnswers.columnStatus}) AS 'statusTotal'
      FROM ${DbInspectionAnswers.table} 
      LEFT JOIN ${DbAreas.table} ON	${DbInspectionAnswers.table}.${DbInspectionAnswers.columnAreaId} = ${DbAreas.table}.${DbAreas.columnId}
      WHERE ${DbInspectionAnswers.columnInspectionId} = '$inspectionID'
      GROUP BY ${DbAreas.table}.${DbAreas.columnId}, ${DbInspectionAnswers.table}.${DbInspectionAnswers.columnStatus}
      ''');

      if (results.isNotEmpty) {
        int overallTotal = 0;
        int overallPasses = 0;
        int overallFails = 0;
        Map<String, Map> areaScores = {};
        for (var score in results) {
          String areaId = score['areaID'].toString();
          String areaTitle = score['areaTitle'].toString();
          String status = score['status'].toString();
          String count = score['statusTotal'].toString();

          if (!areaScores.containsKey(areaId)) {
            areaScores.addAll({
              areaId: {'areaTitle': areaTitle}
            });
          }
          areaScores[areaId]!.addAll({status: count});
        }

        if (areaScores.isNotEmpty) {
          Map<String, Map> finalScores = {};
          for (var areakey in areaScores.keys) {
            Map areaScore = areaScores[areakey]!;

            String title = areaScore['areaTitle'] ?? 'Unknown';
            int passes =
                areaScore['pass'] != null ? int.parse(areaScore['pass']) : 0;
            int fails =
                areaScore['fail'] != null ? int.parse(areaScore['fail']) : 0;
            int percentage = (passes / (passes + fails) * 100).round();

            finalScores.addAll({
              areakey: {
                'areaTitle': title,
                'pass': passes,
                'fail': fails,
                'percentage': percentage
              }
            });

            overallPasses += passes;
            overallFails += fails;

            overallTotal += passes;
            overallTotal += fails;
          }

          int finalInspectionScore =
              (overallPasses / overallTotal * 100).round();

          await db.update(
              DbInspections.table,
              {
                'score': finalInspectionScore,
                'pass': overallPasses,
                'fail': overallFails
              },
              where: '${DbInspections.columnId} = ?',
              whereArgs: [inspectionID]);

          return finalScores;
        }
      }
    } catch (e) {
      print(e);
    }

    return null;
  }

  Future<void> _commitBatchSafely(WriteBatch batch) async {
    try {
      await batch.commit();
    } catch (e) {
      print("Error submitting batch: $e");
    }
  }

  // This will try and submit the curret inspection to the local db
  Future<void> submitInspectionLocal(String inspectionId) async {
    Database db = await instance.database;

    final areaScores = await calculateScores(inspectionId);

    try {
      final rawInspection = await db.query(DbInspections.table,
          where: '${DbInspections.columnId} = ?',
          whereArgs: [inspectionId],
          limit: 1);

      if (rawInspection.isNotEmpty) {
        Inspection inspection = Inspection.fromDB(rawInspection.first);

        if (areaScores != null) {
          inspection.areaScores = areaScores;
        }

        final rawAnswers = await db.query(DbInspectionAnswers.table,
            where: '${DbInspectionAnswers.columnInspectionId} = ?',
            whereArgs: [inspectionId]);

        if (rawAnswers.isNotEmpty) {
          for (var rawAnswer in rawAnswers) {
            InspectionAnswer answer = InspectionAnswer.fromDB(rawAnswer);

            String frequency = answer.questionFrequency.name;
            String result = answer.status.name;
            DateTime nextInspectionDate = getNextInspectionDate(frequency);
            await db.update(
                DbQuestions.table,
                {
                  DbQuestions.columnLastInspectionDate:
                      DateTime.now().toString(),
                  DbQuestions.columnLastInspectionResult: result,
                  DbQuestions.columnNextInspectionDate:
                      nextInspectionDate.toString()
                },
                where: '${DbQuestions.columnId} = ?',
                whereArgs: [answer.questionId]);
          }
        }

        //Try an submit to server
        submitInspectionServer(inspectionId);
      }
    } catch (e) {
      print("Error sending submission: $e");
    }
  }

  // This will try and submit the curret inspection to the server
  Future<void> submitInspectionServer(String inspectionId) async {
    Database db = await instance.database;

    final areaScores = await calculateScores(inspectionId);

    try {
      final rawInspection = await db.query(DbInspections.table,
          where: '${DbInspections.columnId} = ?',
          whereArgs: [inspectionId],
          limit: 1);

      if (rawInspection.isNotEmpty) {
        Inspection inspection = Inspection.fromDB(rawInspection.first);

        if (areaScores != null) {
          inspection.areaScores = areaScores;
        }

        final rawAnswers = await db.query(DbInspectionAnswers.table,
            where: '${DbInspectionAnswers.columnInspectionId} = ?',
            whereArgs: [inspectionId]);

        if (rawAnswers.isNotEmpty) {
          const int batchSize = 400;
          int batchCounter =
              1; //It is set to one as the inspection itself is the first submition of the batch

          // Create a WriteBatch instance
          WriteBatch batch = _firestore.batch();

          CollectionReference inspectionCollection =
              _firestore.collection(inspectionPath);

          DocumentReference docRef = inspectionCollection.doc(inspection.id);
          batch.set(docRef, inspection.toFirestore());

          CollectionReference answerCollection =
              _firestore.collection(inspectionAnswerPath);

          Map<String, Map> questionIds = {};
          for (var rawAnswer in rawAnswers) {
            if (batchCounter == batchSize) {
              // Commit the current batch and create a new one
              await _commitBatchSafely(batch);
              batch = _firestore.batch();
              batchCounter = 0;
            }

            InspectionAnswer answer = InspectionAnswer.fromDB(rawAnswer);
            questionIds.addAll({
              answer.questionId: {
                'result': answer.status.name,
                'frequency': answer.questionFrequency.name
              }
            });
            DocumentReference docRef = answerCollection.doc(answer.id);
            batch.set(docRef, answer.toFirestore());
            batchCounter++;
          }

          // Commit the remaining batch
          if (batchCounter > 0) {
            await _commitBatchSafely(batch);
          }
          /////////////////////////////////

          // This batch will be used to update the last sumitted fields on questions
          WriteBatch questionBatch = _firestore.batch();
          if (questionIds.isNotEmpty) {
            batchCounter = 0; //Reset the batch

            CollectionReference questionCollection =
                _firestore.collection(questionPath);

            for (var question in questionIds.entries) {
              String key = question.key;
              var value = question.value;

              if (batchCounter == batchSize) {
                // Commit the current batch and create a new one
                await _commitBatchSafely(questionBatch);
                questionBatch = _firestore.batch();
                batchCounter = 0;
              }

              String result = value['result'] ?? InspectionResult.pass.name;
              String frequency =
                  value['frequency'] ?? InspectionFrequency.daily.name;

              //Get the local question
              var rawLocalQuestion = await db.query(DbQuestions.table,
                  where: '${DbQuestions.columnId} = ?',
                  whereArgs: [key],
                  limit: 1);

              late DateTime nextInspectionDate;
              late DateTime lastInspectionDate;

              if (rawLocalQuestion.isNotEmpty) {
                InspectionQuestion localQuestion =
                    InspectionQuestion.fromDB(rawLocalQuestion.first);
                nextInspectionDate = localQuestion.nextInspectionDate ??
                    getNextInspectionDate(frequency);
                lastInspectionDate =
                    localQuestion.lastInspectionDate ?? DateTime.now();
              } else {
                nextInspectionDate = getNextInspectionDate(frequency);
                lastInspectionDate = DateTime.now();
              }

              DocumentReference docRef = questionCollection.doc(key);
              questionBatch.update(docRef, {
                'lastInspectionDate': Timestamp.fromDate(lastInspectionDate),
                'lastInspectionResult': result,
                'nextInspectionDate': Timestamp.fromDate(nextInspectionDate)
              });
              batchCounter++;
            }

            // Commit the remaining batch
            if (batchCounter > 0) {
              await _commitBatchSafely(questionBatch);
            }
          }
        }
      }
    } catch (e) {
      print("Error sending submission: $e");
    }
  }

  DateTime getNextInspectionDate(String frequency) {
    switch (frequency) {
      case 'weekly':
        {
          return DateTime.now().add(const Duration(days: 7));
        }
      case 'monthly':
        {
          return DateTime.now().add(const Duration(days: 30));
        }
      case 'quarterly':
        {
          return DateTime.now().add(const Duration(days: 90));
        }
      case 'annually':
        {
          return DateTime.now().add(const Duration(days: 365));
        }
      default: //daily
        {
          return DateTime.now().add(const Duration(days: 1));
        }
    }
  }

  // This will try and submit the pass weeks inspections
  Future<void> pushAllInspections() async {
    Database db = await instance.database;
    isLoading.value = true;
    try {
      if (authController.currentAccountId == null) {
        throw ('Your account could not be verified. Logout and log back in');
      }

      String weekAgo =
          DateTime.now().subtract(const Duration(days: 7)).toString();

      // Create a WriteBatch instance
      WriteBatch batch = _firestore.batch();
      CollectionReference inspectionCollection =
          _firestore.collection(inspectionPath);

      CollectionReference answerCollection =
          _firestore.collection(inspectionAnswerPath);

      final rawInspections = await db.query(
        DbInspections.table,
        where: '${DbInspections.columnAccountId} = ? AND createdAt >= ?',
        whereArgs: [authController.currentAccountId, weekAgo],
      );

      if (rawInspections.isNotEmpty) {
        for (var rawInspection in rawInspections) {
          Inspection inspection = Inspection.fromDB(rawInspection);
          final areaScores = await calculateScores(inspection.id);

          if (areaScores != null) {
            inspection.areaScores = areaScores;
          }

          final rawAnswers = await db.query(DbInspectionAnswers.table,
              where: '${DbInspectionAnswers.columnInspectionId} = ?',
              whereArgs: [inspection.id]);

          if (rawAnswers.isNotEmpty) {
            DocumentReference docRef = inspectionCollection.doc(inspection.id);
            batch.set(docRef, inspection.toFirestore());

            for (var rawAnswer in rawAnswers) {
              InspectionAnswer answer = InspectionAnswer.fromDB(rawAnswer);
              DocumentReference docRef = answerCollection.doc(answer.id);
              batch.set(docRef, answer.toFirestore());
            }
          }
        }

        try {
          await batch.commit();
        } catch (e) {
          print("Error submitting batch: $e");
        }
      }
    } catch (e) {
      print("Error sending submissions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  //This will get the last 7 days worth of inspections and will return a null if any were missed
  Future<List<Map<String, dynamic>>> dashboardInspections() async {
    Database db = await instance.database;

    final siteId = authController.currentUserSiteId;
    if (siteId != null && siteId.isNotEmpty) {
      return await db.rawQuery('''
    WITH DateRange AS (
        SELECT date('now', '-6 days') AS date
        UNION ALL
        SELECT date('now', '-5 days')
        UNION ALL
        SELECT date('now', '-4 days')
        UNION ALL
        SELECT date('now', '-3 days')
        UNION ALL
        SELECT date('now', '-2 days')
        UNION ALL
        SELECT date('now', '-1 days')
        UNION ALL
        SELECT date('now') AS date
    )
    SELECT 
        DateRange.date AS inspectionDate,
        ${DbInspections.table}.*
    FROM 
        DateRange
    LEFT JOIN 
       ${DbInspections.table} ON DateRange.date = date(${DbInspections.table}.${DbInspections.columnCreatedAt})
        AND ${DbInspections.table}.${DbInspections.columnSiteId} = '$siteId'
    ORDER BY 
        DateRange.date DESC;
    ''');
    } else {
      return [];
    }
  }

  Future<void> saveClientNcr(ClientNCR ncr) async {
    try {
      isLoading.value = true;
      await _firestore.collection(clientNcrPath).add(ncr.toFirestore());
    } catch (e) {
      print("Error saving client NCR: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Get the notifications for the current user
  Future<List<AppNotification>> getNotifications() async {
    final rawNotifications = await _firestore
        .collection(notificationPath)
        .where('userId', isEqualTo: authController.currentUserId)
        .where('read', isEqualTo: false)
        .get();
    return rawNotifications.docs
        .map((doc) => AppNotification.fromFirestore(doc))
        .toList();
  }

  // Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection(notificationPath).doc(notificationId).update({
      'read': true,
    });
  }

  // Send Notification
  Future<void> sendNotification({
    required String title,
    required String message,
    required String userId,
    required String eventId,
    required String accountId,
    required String siteId,
    required String type,
  }) async {
    AppNotification notification = AppNotification(
      id: '',
      title: title,
      message: message,
      userId: userId,
      eventId: eventId,
      createdAt: DateTime.now(),
      read: false,
      type: type,
      accountId: accountId,
      siteId: siteId,
    );

    await _firestore
        .collection(notificationPath)
        .add(notification.toFirestore());
  }

  Future<List<ClientNCR>> fetchUserClientNcrs(
      {String status = 'pending'}) async {
    final rawNcrs = await _firestore
        .collection(clientNcrPath)
        .where('responsibleIds', arrayContains: authController.currentUserId)
        .where('status', isEqualTo: status)
        .get();
    return rawNcrs.docs.map((doc) => ClientNCR.fromFirestore(doc)).toList();
  }

  // Update a client NCR as a site manager
  Future<void> updateClientNcr(ClientNCR ncr) async {
    await _firestore
        .collection(clientNcrPath)
        .doc(ncr.id)
        .update(ncr.toFirestore());
  }
}
