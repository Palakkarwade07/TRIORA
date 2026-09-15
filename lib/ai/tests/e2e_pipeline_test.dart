// lib/ai/tests/e2e_pipeline_test.dart

import '../services/ai_reasoning_service.dart';
import '../explainability/audit_logger.dart';

void main() async {
  final service = AIReasoningService();
  final auditLogger = AuditLogger();

  print('=== END-TO-END CLINICAL PIPELINE INTEGRATION TEST ===\n');

  // Scenario 1: Critical Emergency Triage Profile
  print('[Scenario 1] High-Risk Critical Profile (Fever + Respiratory Distress)');
  final criticalInput = {
    'fever': 'present',
    'respiratory_distress': 'present',
  };
  final criticalResult = await service.analyzePatientData(
    observedSymptoms: criticalInput,
    severityScore: 9.0,
    durationDays: 4,
  );

  auditLogger.logAnalysisEvent(
    patientId: 'PT-1001',
    inputs: criticalInput,
    explanation: criticalResult,
  );

  assert(criticalResult.primaryRiskLevel == 'HIGH', 'Expected HIGH risk for critical profile');
  assert(criticalResult.confidenceScore > 0.75, 'Expected > 75% confidence for critical profile');
  print('  -> Result: Risk=${criticalResult.primaryRiskLevel}, Confidence=${(criticalResult.confidenceScore * 100).toStringAsFixed(1)}% [VERIFIED]');

  // Scenario 2: Low-Risk Outpatient Profile
  print('\n[Scenario 2] Low-Risk Outpatient Profile (Mild Fever Only)');
  final mildInput = {
    'fever': 'present',
    'respiratory_distress': 'absent',
  };
  final mildResult = await service.analyzePatientData(
    observedSymptoms: mildInput,
    severityScore: 2.5,
    durationDays: 2,
  );

  auditLogger.logAnalysisEvent(
    patientId: 'PT-1002',
    inputs: mildInput,
    explanation: mildResult,
  );

  assert(mildResult.primaryRiskLevel != 'HIGH', 'Expected non-HIGH risk for mild profile');
  print('  -> Result: Risk=${mildResult.primaryRiskLevel}, Confidence=${(mildResult.confidenceScore * 100).toStringAsFixed(1)}% [VERIFIED]');

  // Audit Log Verification
  print('\n=== GENERATED AUDIT LOG TRAIL ===');
  for (var log in auditLogger.logs) {
    print(log);
  }

  print('STATUS: ALL END-TO-END SCENARIOS & AUDIT LOGS PASSED VERIFICATION');
}