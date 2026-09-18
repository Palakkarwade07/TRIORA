import '../database_helper.dart';
import '../models/patient.dart';
import '../models/assessment.dart';

class PatientHistoryRecord {
  final Patient patient;
  final List<Assessment> assessments;

  PatientHistoryRecord({
    required this.patient,
    required this.assessments,
  });

  int get totalAssessments => assessments.length;

  Assessment? get latestAssessment =>
      assessments.isNotEmpty ? assessments.first : null;
}

class HistoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Fetches a patient and all their past assessments ordered by date
  Future<PatientHistoryRecord?> getCompletePatientHistory(String patientId) async {
    try {
      final Patient? patient = await _dbHelper.getPatient(patientId);
      if (patient == null) {
        return null;
      }

      // getPatientAssessments already returns ordered by assessment_date DESC
      final List<Assessment> assessments =
          await _dbHelper.getPatientAssessments(patientId);

      return PatientHistoryRecord(
        patient: patient,
        assessments: assessments,
      );
    } catch (e) {
      print("Error fetching patient history: $e");
      return null;
    }
  }

  /// Fetches past assessments only
  Future<List<Assessment>> getAssessmentsByPatient(String patientId) async {
    try {
      return await _dbHelper.getPatientAssessments(patientId);
    } catch (e) {
      print("Error retrieving assessment list: $e");
      return [];
    }
  }
}