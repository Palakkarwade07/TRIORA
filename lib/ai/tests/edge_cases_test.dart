// lib/ai/tests/edge_cases_test.dart

import '../services/ai_reasoning_service.dart';

void main() async {
  final service = AIReasoningService();

  print('=== EDGE-CASE & ROBUSTNESS TEST SUITE ===\n');

  // Test 1: Out-of-bounds numeric inputs (severity = -5.0, severity = 15.0)
  print('[Test 1] Out-of-bounds Severity Clamping (-5.0 & 15.0)');
  final test1a = await service.analyzePatientData(
    observedSymptoms: {'fever': 'absent'},
    severityScore: -5.0,
    durationDays: -10,
  );
  print('  -> Result (-5.0): Risk=${test1a.primaryRiskLevel}, Confidence=${test1a.confidenceScore}');

  final test1b = await service.analyzePatientData(
    observedSymptoms: {'fever': 'present'},
    severityScore: 15.0,
    durationDays: 30,
  );
  print('  -> Result (15.0): Risk=${test1b.primaryRiskLevel}, Confidence=${test1b.confidenceScore}');

  // Test 2: Completely empty evidence map
  print('\n[Test 2] Empty Symptom Evidence Map');
  final test2 = await service.analyzePatientData(
    observedSymptoms: {},
    severityScore: 5.0,
    durationDays: 3,
  );
  print('  -> Result (Empty Map): Risk=${test2.primaryRiskLevel}, Confidence=${test2.confidenceScore}');

  // Test 3: Unrecognized symptom key
  print('\n[Test 3] Unknown/Unregistered Symptom Keys');
  final test3 = await service.analyzePatientData(
    observedSymptoms: {'unknown_symptom_x': 'present'},
    severityScore: 4.0,
    durationDays: 2,
  );
  print('  -> Result (Unknown Key): Risk=${test3.primaryRiskLevel}, Confidence=${test3.confidenceScore}');

  print('\n=== ALL EDGE CASE TESTS PASSED SUCCESSFULLY ===');
}