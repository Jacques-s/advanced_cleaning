class DbAccounts {
  static const table = 'accounts';

  static const columnId = 'id';
  static const columnCreatedAt = 'createdAt';
  static const columnUpdatedAt = 'updatedAt';
  static const columnTitle = 'title';
  static const columnStatus = 'status';
  static const columnLastSynced = 'lastSynced'; //Mobile only field

  static const createStatement = '''
      CREATE TABLE $table (
        $columnId TEXT PRIMARY KEY,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL,
        $columnTitle TEXT NOT NULL,
        $columnStatus TEXT NOT NULL,
        $columnLastSynced TEXT
      )
    ''';
}

class DbSites {
  static const table = 'sites';

  static const columnId = 'id';
  static const columnCreatedAt = 'createdAt';
  static const columnUpdatedAt = 'updatedAt';
  static const columnTitle = 'title';
  static const columnAddress = 'address';
  static const columnStatus = 'status';
  static const columnAccountId = 'accountId';
  static const columnAppChanges = 'appChanges';

  static const createStatement = '''
      CREATE TABLE $table (
        $columnId TEXT PRIMARY KEY,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL,
        $columnTitle TEXT NOT NULL,
        $columnAddress TEXT,
        $columnStatus TEXT NOT NULL,
        $columnAccountId TEXT NOT NULL,
        $columnAppChanges TEXT
      )
    ''';
}

class DbAreas {
  static const table = 'areas';

  static const columnId = 'id';
  static const columnCreatedAt = 'createdAt';
  static const columnUpdatedAt = 'updatedAt';
  static const columnTitle = 'title';
  static const columnBarcode = 'barcode';
  static const columnStatus = 'status';
  static const columnAccountId = 'accountId';
  static const columnSiteId = 'siteId';

  static const createStatement = '''
      CREATE TABLE $table (
        $columnId TEXT PRIMARY KEY,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL,
        $columnTitle TEXT NOT NULL,
        $columnBarcode TEXT NOT NULL,
        $columnStatus TEXT NOT NULL,
        $columnAccountId TEXT NOT NULL,
        $columnSiteId TEXT NOT NULL
      )
    ''';
}

class DbQuestions {
  static const table = 'questions';

  static const columnId = 'id';
  static const columnCreatedAt = 'createdAt';
  static const columnUpdatedAt = 'updatedAt';
  static const columnTitle = 'title';
  static const columnFrequency = 'frequency';
  static const columnStatus = 'status';
  static const columnNextInspectionDate = 'nextInspectionDate';
  static const columnLastInspectionDate = 'lastInspectionDate';
  static const columnLastInspectionResult = 'lastInspectionResult';
  static const columnAccountId = 'accountId';
  static const columnSiteId = 'siteId';
  static const columnAreaId = 'areaId';

  static const createStatement = '''
      CREATE TABLE $table (
        $columnId TEXT PRIMARY KEY,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL,
        $columnTitle TEXT NOT NULL,
        $columnFrequency TEXT NOT NULL,
        $columnStatus TEXT NOT NULL,
        $columnNextInspectionDate TEXT,
        $columnLastInspectionDate TEXT,
        $columnLastInspectionResult TEXT,
        $columnAccountId TEXT NOT NULL,
        $columnSiteId TEXT NOT NULL,
        $columnAreaId TEXT NOT NULL
      )
    ''';
}

class DbInspections {
  static const table = 'inspections';

  static const columnId = 'id';
  static const columnCreatedAt = 'createdAt';
  static const columnUpdatedAt = 'updatedAt';
  static const columnConductedDate = 'conductedDate';
  static const columnScore = 'score';
  static const columnPass = 'pass';
  static const columnFail = 'fail';
  static const columnAccountId = 'accountId';
  static const columnSiteId = 'siteId';
  static const columnSiteTitle = 'siteTitle';
  static const columnUserId = 'userId';
  static const columnUserFullName = 'userFullName';

  static const createStatement = '''
      CREATE TABLE $table (
        $columnId TEXT PRIMARY KEY,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL,
        $columnConductedDate TEXT NOT NULL,
        $columnScore REAL,
        $columnPass REAL,
        $columnFail REAL,
        $columnAccountId TEXT NOT NULL,
        $columnSiteId TEXT NOT NULL,
        $columnSiteTitle TEXT NOT NULL,
        $columnUserId TEXT NOT NULL,
        $columnUserFullName TEXT NOT NULL
      )
    ''';
}

class DbInspectionAnswers {
  static const table = 'inspectionsAnswers';

  static const columnId = 'id';
  static const columnCreatedAt = 'createdAt';
  static const columnUpdatedAt = 'updatedAt';
  static const columnFailureReason = 'failureReason';
  static const columnCorrectiveAction = 'correctiveAction';
  static const columnStatus = 'status';
  static const columnAccountId = 'accountId';
  static const columnSiteId = 'siteId';
  static const columnAreaId = 'areaId';
  static const columnInspectionId = 'inspectionId';
  static const columnQuestionId = 'questionId';
  static const columnQuestionTitle = 'questionTitle';
  static const columnQuestionFrequency = 'questionFrequency';

  static const createStatement = '''
      CREATE TABLE $table (
        $columnId TEXT PRIMARY KEY,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL,
        $columnFailureReason TEXT,
        $columnCorrectiveAction TEXT,
        $columnStatus TEXT NOT NULL,
        $columnAccountId TEXT NOT NULL,
        $columnSiteId TEXT NOT NULL,
        $columnAreaId TEXT NOT NULL,
        $columnInspectionId TEXT NOT NULL,
        $columnQuestionId TEXT NOT NULL,
        $columnQuestionTitle TEXT NOT NULL,
        $columnQuestionFrequency TEXT NOT NULL
      )
    ''';
}
