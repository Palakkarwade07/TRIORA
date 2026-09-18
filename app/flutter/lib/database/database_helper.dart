import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'schema/tables.dart';
import 'models/patient.dart';

class DatabaseHelper {
  static const String _databaseName = "triora.db";
  static const int _databaseVersion = 1;

  // Singleton instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initializeDatabase();
    return _database!;
  }

  // Initialize SQLite database
  Future<Database> initializeDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Create tables on initial launch
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(Tables.createPatientsTable);
    await db.execute(Tables.createAssessmentsTable);
  }

  // Close the database connection
  Future<void> close() async {
    final Database db = await database;
    db.close();
  }

  // ==========================================
  // PATIENT CRUD OPERATIONS (Create, Read, Update)
  // ==========================================

  // Create / Insert a new patient
  Future<int> insertPatient(Patient patient) async {
    final Database db = await database;
    return await db.insert(
      Tables.tablePatients,
      patient.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read: Fetch a single patient by their ID
  Future<Patient?> getPatient(String patientId) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      Tables.tablePatients,
      where: '${Tables.colPatientId} = ?',
      whereArgs: [patientId],
    );

    if (maps.isNotEmpty) {
      return Patient.fromMap(maps.first);
    }
    return null;
  }

  // Read: Fetch all registered patients
  Future<List<Patient>> getPatients() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      Tables.tablePatients,
      orderBy: '${Tables.colCreatedAt} DESC',
    );

    return List.generate(maps.length, (i) => Patient.fromMap(maps[i]));
  }

  // Update an existing patient record
  Future<int> updatePatient(Patient patient) async {
    final Database db = await database;
    return await db.update(
      Tables.tablePatients,
      patient.toMap(),
      where: '${Tables.colPatientId} = ?',
      whereArgs: [patient.patientId],
    );
  }
}