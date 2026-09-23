import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'schema/tables.dart';

class DatabaseHelper {
  static const String _dbName = 'triora_clinical.db';
  static const int _dbVersion = 2; // Incremented for Day 3 indexing migration

  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Ensure foreign keys are strictly enforced by the SQLite runtime engine
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Initial table and index provisioning
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DatabaseTables.createPatientsTable);
    await db.execute(DatabaseTables.createAssessmentsTable);

    // Apply indexes
    await db.execute(DatabaseTables.idxAssessmentsPatientId);
    await db.execute(DatabaseTables.idxAssessmentsDate);
    await db.execute(DatabaseTables.idxPatientsIdentifier);
  }

  /// Schema migration path when moving between versions without data loss
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Version 1 -> Version 2: Add performance lookup indexes
      await db.execute(DatabaseTables.idxAssessmentsPatientId);
      await db.execute(DatabaseTables.idxAssessmentsDate);
      await db.execute(DatabaseTables.idxPatientsIdentifier);
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}