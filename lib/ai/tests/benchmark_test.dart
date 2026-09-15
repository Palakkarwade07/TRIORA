// lib/ai/tests/benchmark_test.dart

import '../services/ai_reasoning_service.dart';

void main() async {
  final service = AIReasoningService();
  const iterations = 1000;
  final latenciesUs = <int>[];

  print('=== REAL-TIME LATENCY BENCHMARK ($iterations Iterations) ===\n');

  // Warm-up execution to prime the Dart VM / JIT
  await service.analyzePatientData(
    observedSymptoms: {'fever': 'present'},
    severityScore: 5.0,
    durationDays: 3,
  );

  final totalStopwatch = Stopwatch()..start();

  for (int i = 0; i < iterations; i++) {
    final sw = Stopwatch()..start();
    await service.analyzePatientData(
      observedSymptoms: {
        'fever': i % 2 == 0 ? 'present' : 'absent',
        'respiratory_distress': i % 3 == 0 ? 'present' : 'absent',
      },
      severityScore: (i % 10) + 1.0,
      durationDays: (i % 14) + 1.0,
    );
    sw.stop();
    latenciesUs.add(sw.elapsedMicroseconds);
  }

  totalStopwatch.stop();

  final totalMs = totalStopwatch.elapsedMilliseconds;
  final avgUs = latenciesUs.reduce((a, b) => a + b) / iterations;
  final avgMs = avgUs / 1000.0;
  final minMs = (latenciesUs.reduce((a, b) => a < b ? a : b)) / 1000.0;
  final maxMs = (latenciesUs.reduce((a, b) => a > b ? a : b)) / 1000.0;

  print('Total Benchmark Time : ${totalMs} ms');
  print('Minimum Single Run   : ${minMs.toStringAsFixed(3)} ms');
  print('Maximum Single Run   : ${maxMs.toStringAsFixed(3)} ms');
  print('Average Run Latency  : ${avgMs.toStringAsFixed(3)} ms');
  print('Target Requirement   : < 10.000 ms\n');

  if (avgMs < 10.0) {
    print('STATUS: PASSED (Sub-10ms real-time constraint satisfied)');
  } else {
    print('STATUS: FAILED (Exceeds latency target)');
  }
}