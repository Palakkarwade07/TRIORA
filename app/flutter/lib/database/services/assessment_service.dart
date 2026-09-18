import '../database_helper.dart';
import '../models/assessment.dart';
import '../models/integration_contract.dart';

class AssessmentService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Takes the full result produced by the decision engine and saves it to SQLite
  Future<bool> recordAssessment(AssessmentResult result) async {
    try {
      final Assessment dbAssessment = Assessment(
        assessmentId: result.assessmentId,
        patientId: result.patientId,
        assessmentDate: result.assessmentDate,
        inputData: result.input.toJson(),
        riskLevel: result.riskLevel,
        confidence: result.confidence,
        referral: result.referral,
        explanation: result.explanation,
      );

      final int rowId = await _dbHelper.saveAssessment(dbAssessment);
      return rowId > 0;
    } catch (e) {
      print("Error saving assessment to SQLite: $e");
      return false;
    }
  }

  /// Retrieve a specific past assessment by its unique ID
  Future<Assessment?> fetchAssessment(String assessmentId) async {
    return await _dbHelper.getAssessment(assessmentId);
  }
}