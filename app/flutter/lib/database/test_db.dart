import 'services/assessment_orchestrator.dart';
import 'services/history_service.dart';

void main() async {
  print("--- Testing Day 2 Task 5: Full E2E Pipeline ---");

  final orchestrator = AssessmentOrchestrator();
  final historyService = HistoryService();

  // 1. Simulate UI submission (P3)
  print("Running end-to-end assessment...");
  final result = await orchestrator.runFullAssessmentFlow(
    identifier: "PATIENT-TRIORA-01",
    age: 55,
    sex: "Female",
    clinicalData: {
      "systolic_bp": 175,
      "heart_rate": 90,
      "symptoms": ["chest pain", "shortness of breath"]
    },
  );

  print("Assessment ID: ${result.assessmentId}");
  print("Patient ID: ${result.patientId}");
  print("Calculated Risk: ${result.riskLevel}");
  print("Referral Advice: ${result.referral}");

  // 2. Verify complete persistence via HistoryService
  print("\nVerifying database persistence via HistoryService...");
  final history = await historyService.getCompletePatientHistory(result.patientId);

  if (history != null && history.assessments.isNotEmpty) {
    print("SUCCESS: Pipeline fully persisted!");
    print("Patient: ${history.patient.identifier}");
    print("Total Recorded Assessments: ${history.totalAssessments}");
    print("Latest Note: ${history.latestAssessment?.explanation}");
  } else {
    print("FAILURE: Assessment record not found in database.");
  }
}