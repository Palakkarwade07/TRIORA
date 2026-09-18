import '../models/integration_contract.dart';
import 'patient_service.dart';
import 'assessment_service.dart';

class AssessmentOrchestrator {
  final PatientService _patientService = PatientService();
  final AssessmentService _assessmentService = AssessmentService();

  /// Full end-to-end pipeline:
  /// 1. Persists patient if not already saved (or retrieves existing).
  /// 2. Packages payload into AssessmentInput.
  /// 3. Simulates/invokes the Clinical (P1) & AI (P2) decision engines.
  /// 4. Persists the final AssessmentResult to SQLite.
  /// 5. Returns AssessmentResult to P3 for display.
  Future<AssessmentResult> runFullAssessmentFlow({
    required String identifier,
    required int age,
    required String sex,
    required Map<String, dynamic> clinicalData,
  }) async {
    // Step A: Persist patient identity
    final String patientId = await _patientService.registerPatient(
      identifier: identifier,
      age: age,
      sex: sex,
    );

    // Step B: Construct standard contract input
    final AssessmentInput input = AssessmentInput(
      patientId: patientId,
      age: age,
      sex: sex,
      clinicalData: clinicalData,
    );

    // Step C: Execute decision pipeline (P1 Rules + P2 Model Engine)
    // Replace with Athu & Palak's exact engine call when combined
    final AssessmentResult result = _evaluateClinicalRules(input);

    // Step D: Persist final clinical assessment to SQLite
    final bool isSaved = await _assessmentService.recordAssessment(result);
    if (!isSaved) {
      print("Warning: Assessment failed to persist to SQLite.");
    }

    // Step E: Return structured output directly to UI
    return result;
  }

  /// Internal mock of P1 & P2 engine logic for validation testing
  AssessmentResult _evaluateClinicalRules(AssessmentInput input) {
    final String assessmentId = 'ASM_${DateTime.now().millisecondsSinceEpoch}';
    final String now = DateTime.now().toIso8601String();

    // Basic heuristic simulation until P1 & P2 models are wired
    final bool hasHighRiskVitals = input.clinicalData['systolic_bp'] != null &&
        (input.clinicalData['systolic_bp'] as num) > 160;

    final String risk = hasHighRiskVitals ? 'HIGH' : 'LOW';
    final double confidence = hasHighRiskVitals ? 0.92 : 0.88;
    final String referral = hasHighRiskVitals ? 'URGENT' : 'ROUTINE';
    final String explanation = hasHighRiskVitals
        ? 'Systolic blood pressure exceeds threshold (>160 mmHg).'
        : 'Vitals and clinical observations are within baseline range.';

    return AssessmentResult(
      assessmentId: assessmentId,
      patientId: input.patientId,
      assessmentDate: now,
      input: input,
      riskLevel: risk,
      confidence: confidence,
      referral: referral,
      explanation: explanation,
      triggeredRules: hasHighRiskVitals ? ['RULE_CRITICAL_BP'] : ['RULE_NORMAL'],
    );
  }
}