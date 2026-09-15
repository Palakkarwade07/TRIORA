// lib/ai/tests/fuzzy_test.dart

import '../fuzzy/fuzzy_engine.dart';

void main() {
  final engine = FuzzyEngine();

  // Test continuous boundary value (severity = 6.5 out of 10)
  final result = engine.evaluate(severityScore: 6.5, durationDays: 10);

  print('=== FUZZY BOUNDARY EVALUATION TEST ===');
  print('Input Severity: 6.5 / 10');
  print('Severity Fuzzy Memberships: ${result['severity_degrees']}');
  print('Composite Fuzzy Risk Score: ${result['fuzzy_score']}');
  print('Assigned Fuzzy Category: ${result['fuzzy_category']}');
}