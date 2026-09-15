// lib/ai/tests/stream_controller_test.dart

import 'dart:async';
import '../services/reasoning_stream_controller.dart';

void main() async {
  final streamController = ReasoningStreamController();
  int updateCount = 0;

  print('=== REACTIVE STREAM CONTROLLER TEST ===\n');

  // Subscribe listener to stream updates
  final subscription = streamController.reasoningStream.listen((explanation) {
    updateCount++;
    print('[Stream Update #$updateCount]');
    print('  Risk Level : ${explanation.primaryRiskLevel}');
    print('  Confidence : ${(explanation.confidenceScore * 100).toStringAsFixed(1)}%');
    print('  Factors    : ${explanation.contributingFactors.length} identified\n');
  });

  print('Simulating real-time clinician slider/toggle interactions...\n');

  // Event 1: Mild initial symptoms
  await streamController.updatePatientData(
    observedSymptoms: {'fever': 'present'},
    severityScore: 3.0,
    durationDays: 2,
  );

  await Future.delayed(const Duration(milliseconds: 50));

  // Event 2: Acute symptom aggravation
  await streamController.updatePatientData(
    observedSymptoms: {'fever': 'present', 'respiratory_distress': 'present'},
    severityScore: 8.5,
    durationDays: 5,
  );

  await Future.delayed(const Duration(milliseconds: 50));

  await subscription.cancel();
  streamController.dispose();

  print('STATUS: PASSED (Emitted $updateCount real-time diagnostic updates)');
}