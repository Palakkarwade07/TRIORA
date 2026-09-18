class Tables {
  static const String tablePatients = 'patients';
  static const String tableAssessments = 'assessments';

  // Columns: patients
  static const String colPatientId = 'patient_id';
  static const String colIdentifier = 'identifier';
  static const String colAge = 'age';
  static const String colSex = 'sex';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  // Columns: assessments
  static const String colAssessmentId = 'assessment_id';
  static const String colAssessmentPatientId = 'patient_id';
  static const String colAssessmentDate = 'assessment_date';
  static const String colInputData = 'input_data';
  static const String colRiskLevel = 'risk_level';
  static const String colConfidence = 'confidence';
  static const String colReferral = 'referral';
  static const String colExplanation = 'explanation';

  // DDL: Create Patients Table
  static const String createPatientsTable = '''
    CREATE TABLE $tablePatients (
      $colPatientId TEXT PRIMARY KEY,
      $colIdentifier TEXT NOT NULL,
      $colAge INTEGER NOT NULL,
      $colSex TEXT NOT NULL,
      $colCreatedAt TEXT NOT NULL,
      $colUpdatedAt TEXT NOT NULL
    );
  ''';

  // DDL: Create Assessments Table
  static const String createAssessmentsTable = '''
    CREATE TABLE $tableAssessments (
      $colAssessmentId TEXT PRIMARY KEY,
      $colAssessmentPatientId TEXT NOT NULL,
      $colAssessmentDate TEXT NOT NULL,
      $colInputData TEXT NOT NULL,
      $colRiskLevel TEXT NOT NULL,
      $colConfidence REAL NOT NULL,
      $colReferral TEXT NOT NULL,
      $colExplanation TEXT NOT NULL,
      FOREIGN KEY ($colAssessmentPatientId) REFERENCES $tablePatients ($colPatientId) ON DELETE CASCADE
    );
  ''';
}