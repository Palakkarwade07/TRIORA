class DatabaseTables {
  // Table: Patients
  static const String tablePatients = 'patients';
  static const String createPatientsTable = '''
    CREATE TABLE $tablePatients (
      id TEXT PRIMARY KEY,
      identifier TEXT NOT NULL UNIQUE,
      age INTEGER NOT NULL,
      sex TEXT NOT NULL,
      created_at TEXT NOT NULL
    );
  ''';

  // Table: Assessments
  static const String tableAssessments = 'assessments';
  static const String createAssessmentsTable = '''
    CREATE TABLE $tableAssessments (
      id TEXT PRIMARY KEY,
      patient_id TEXT NOT NULL,
      assessment_date TEXT NOT NULL,
      input_data TEXT NOT NULL,
      risk_level TEXT NOT NULL,
      confidence REAL NOT NULL,
      referral TEXT NOT NULL,
      explanation TEXT NOT NULL,
      triggered_rules TEXT NOT NULL,
      FOREIGN KEY (patient_id) REFERENCES $tablePatients (id) ON DELETE CASCADE
    );
  ''';

  // Index 1: Optimize queries looking up history by patient ID
  static const String idxAssessmentsPatientId = '''
    CREATE INDEX IF NOT EXISTS idx_assessments_patient_id 
    ON $tableAssessments (patient_id);
  ''';

  // Index 2: Optimize date-based filtering and chronological sorting
  static const String idxAssessmentsDate = '''
    CREATE INDEX IF NOT EXISTS idx_assessments_date 
    ON $tableAssessments (assessment_date DESC);
  ''';

  // Index 3: Optimize fast lookup on patient unique external identifier
  static const String idxPatientsIdentifier = '''
    CREATE INDEX IF NOT EXISTS idx_patients_identifier 
    ON $tablePatients (identifier);
  ''';
}