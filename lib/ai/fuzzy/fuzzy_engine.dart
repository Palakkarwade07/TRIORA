// lib/ai/fuzzy/fuzzy_engine.dart

import 'fuzzy_variable.dart';

class FuzzyEngine {
  Map<String, dynamic> evaluate({
    required double severityScore,
    required double durationDays,
  }) {
    final severityDegrees = ClinicalFuzzyVariables.severity.fuzzify(severityScore);
    final durationDegrees = ClinicalFuzzyVariables.duration.fuzzify(durationDays);

    // Rule 1: High severity -> High fuzzy risk
    double highRiskDegree = severityDegrees['HIGH'] ?? 0.0;

    // Rule 2: Moderate severity + Chronic duration -> High fuzzy risk
    double modChron = (severityDegrees['MODERATE'] ?? 0.0) < (durationDegrees['CHRONIC'] ?? 0.0)
        ? (severityDegrees['MODERATE'] ?? 0.0)
        : (durationDegrees['CHRONIC'] ?? 0.0);

    if (modChron > highRiskDegree) highRiskDegree = modChron;

    // Composite continuous score calculation [0.0 - 1.0]
    double fuzzyRiskScore = (severityScore / 10.0) * 0.7 + (highRiskDegree * 0.3);

    String fuzzyCategory = 'LOW';
    if (fuzzyRiskScore >= 0.7) {
      fuzzyCategory = 'HIGH';
    } else if (fuzzyRiskScore >= 0.4) {
      fuzzyCategory = 'MODERATE';
    }

    return {
      'severity_degrees': severityDegrees,
      'duration_degrees': durationDegrees,
      'fuzzy_score': double.parse(fuzzyRiskScore.toStringAsFixed(2)),
      'fuzzy_category': fuzzyCategory,
    };
  }
}