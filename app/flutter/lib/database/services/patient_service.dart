import '../database_helper.dart';
import '../models/patient.dart';

class PatientService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Called by Ritu's Flutter Form when submitting patient details
  Future<String> registerPatient({
    required String identifier,
    required int age,
    required String sex,
  }) async {
    // Generate a unique patient ID (e.g. based on epoch timestamp)
    final String generatedId = 'P_${DateTime.now().millisecondsSinceEpoch}';
    final String now = DateTime.now().toIso8601String();

    final Patient newPatient = Patient(
      patientId: generatedId,
      identifier: identifier,
      age: age,
      sex: sex,
      createdAt: now,
      updatedAt: now,
    );

    await _dbHelper.insertPatient(newPatient);
    return generatedId;
  }

  /// Retrieve patient by ID
  Future<Patient?> fetchPatient(String patientId) async {
    return await _dbHelper.getPatient(patientId);
  }

  /// Retrieve all registered patients
  Future<List<Patient>> fetchAllPatients() async {
    return await _dbHelper.getPatients();
  }
}