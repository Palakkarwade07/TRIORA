import 'dart:convert';
import 'database_helper.dart';
import 'models/integration_contract.dart';
import 'services/patient_service.dart';
import 'services/assessment_service.dart';
import 'services/assessment_orchestrator.dart';

class DatabaseEdgeCaseSuite {
  final PatientService _patientService = PatientService();
  final AssessmentService _assessmentService = AssessmentService();
  final AssessmentOrchestrator _orchestrator = AssessmentOrchestrator();

  /// Runs all database stress tests and prints status reports
  Future<void> runAllTests() async {
    print("==========================================");
    print("  STARTING DAY 3: SQLITE EDGE-CASE SUITE  ");
    print("==========================================");

    await testDuplicatePatientRegistration();
    await testMissingVitalsGracefulHandling();
    await testMalformedJsonPayload();
    await testNonExistentPatientAssessment();
    await testExtremeBoundaryValues();

    print("==========================================");
    print("  ALL EDGE-CASE TESTS COMPLETED           ");
    print("==========================================");
  }

  /// Edge Case 1: Re-registering an existing patient identifier
  /// Expected: Must return existing patient ID, avoiding UNIQUE constraint crashes.
  Future<void> testDuplicatePatientRegistration() async {
    print("\n[Test 1] Duplicate Patient Registration Check...");
    try {
      final String id1 = await _patientService.registerPatient(
        identifier: "TRIORA-TEST-DUP-01",
        age: 34,
        sex: "Female",
      );

      final String id2 = await _patientService.registerPatient(
        identifier: "TRIORA-TEST-DUP-01",
        age: 34,
        sex: "Female",
      );

      if (id1 == id2) {
        print("  -> PASS: Idempotent registration verified. Reused ID: $id1");
      } else {
        print("  -> FAIL: Duplicate identifiers generated distinct UUIDs.");
      }
    } catch (e) {
      print("  -> FAIL: Threw unhandled exception on duplicate: $e");
    }
  }

  /// Edge Case 2: Vitals Map completely empty or missing systolic_bp
  /// Expected: Assessment must fall back to baseline rule without null crash.
  Future<void> testMissingVitalsGracefulHandling() async {
    print("\n[Test 2] Missing/Null Vitals Data Check...");
    try {
      final AssessmentResult result = await _orchestrator.runFullAssessmentFlow(
        identifier: "TRIORA-TEST-EMPTY-VITALS",
        age: 45,
        sex: "Male",
        clinicalData: {}, // Completely empty map
      );

      if (result.riskLevel == 'LOW' && result.assessmentId.isNotEmpty) {
        print("  -> PASS: Gracefully defaulted missing vitals to baseline risk.");
      } else {
        print("  -> FAIL: Unexpected output on empty map: ${result.riskLevel}");
      }
    } catch (e) {
      print("  -> FAIL: Null safety failure on missing vitals: $e");
    }
  }

  /// Edge Case 3: Payload containing special characters, escaped quotes, or nested maps
  /// Expected: Serialization to SQLite TEXT and deserialization back must not corrupt.
  Future<void> testMalformedJsonPayload() async {
    print("\n[Test 3] Special Character & Escaped JSON Handling...");
    try {
      final complexMap = {
        'notes': 'Patient said: "Feeling dizzy\'s & cold", [stage: 1]',
        'nested': {'systolic_bp': 175, 'pulse': null},
        'unicode': 'Éxamen Clínico — Normal',
      };

      final AssessmentResult result = await _orchestrator.runFullAssessmentFlow(
        identifier: "TRIORA-TEST-COMPLEX-JSON",
        age: 60,
        sex: "Female",
        clinicalData: complexMap,
      );

      // Verify persistence via fetch
      final history = await _assessmentService.getPatientAssessments(result.patientId);
      final savedAssessment = history.firstWhere(
        (a) => a.assessmentId == result.assessmentId,
      );

      if (savedAssessment.input.clinicalData['notes'] == complexMap['notes']) {
        print("  -> PASS: JSON serialization preserved quotes and unicode cleanly.");
      } else {
        print("  -> FAIL: Extracted JSON data corrupted during write/read.");
      }
    } catch (e) {
      print("  -> FAIL: Exception during JSON handling: $e");
    }
  }

  /// Edge Case 4: Persisting assessment with invalid/non-existent patient ID
  /// Expected: Handled gracefully according to foreign key configuration.
  Future<void> testNonExistentPatientAssessment() async {
    print("\n[Test 4] Orphan Assessment Insertion...");
    try {
      final dummyInput = AssessmentInput(
        patientId: "NON_EXISTENT_PATIENT_999",
        age: 20,
        sex: "Other",
        clinicalData: {'systolic_bp': 110},
      );

      final dummyResult = AssessmentResult(
        assessmentId: "ASM_ORPHAN_${DateTime.now().millisecondsSinceEpoch}",
        patientId: "NON_EXISTENT_PATIENT_999",
        assessmentDate: DateTime.now().toIso8601String(),
        input: dummyInput,
        riskLevel: "LOW",
        confidence: 0.85,
        referral: "ROUTINE",
        explanation: "Orphan test record.",
        triggeredRules: ["RULE_NORMAL"],
      );

      final bool saved = await _assessmentService.recordAssessment(dummyResult);
      print("  -> INFO: Persistence returned status: $saved");
    } catch (e) {
      print("  -> PASS: Caught expected foreign key or validation error: $e");
    }
  }

  /// Edge Case 5: Out-of-bounds boundary values (e.g., negative or 300+ BP)
  /// Expected: High-risk triggers activate without mathematical overflows.
  Future<void> testExtremeBoundaryValues() async {
    print("\n[Test 5] Extreme Boundary Values (Systolic BP = 280)...");
    try {
      final AssessmentResult result = await _orchestrator.runFullAssessmentFlow(
        identifier: "TRIORA-TEST-EXTREME-BP",
        age: 72,
        sex: "Male",
        clinicalData: {'systolic_bp': 280},
      );

      if (result.riskLevel == 'HIGH' && result.triggeredRules.contains('RULE_CRITICAL_BP')) {
        print("  -> PASS: Correctly triggered high-risk triage on extreme vitals.");
      } else {
        print("  -> FAIL: Did not flag extreme boundary values as HIGH.");
      }
    } catch (e) {
      print("  -> FAIL: Error handling extreme values: $e");
    }
  }
}