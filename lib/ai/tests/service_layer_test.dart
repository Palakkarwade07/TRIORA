// lib/ai/tests/service_layer_test.dart

import '../services/ai_reasoning_service.dart';

void main() async {
  final service = AIReasoningService();

  final result = await service.analyzePatientData(
    observedSymptoms: {
      'fever': 'present',
      'respiratory_distress': 'present',
    },
    severityScore: 8.5,
    durationDays: 5,
  );

  print('=== AI REASONING SERVICE FACADE TEST ===');
  print(result);
}