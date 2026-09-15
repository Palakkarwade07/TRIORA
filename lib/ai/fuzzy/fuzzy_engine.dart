// lib/ai/fuzzy/fuzzy_engine.dart

import 'fuzzy_variable.dart';

class FuzzyEngine {
  Map<String, dynamic> evaluate({
    required double severityScore,
    required double durationDays,
  }) {
    // Clamping values to valid domain ranges to prevent mathematical distortion
    final safeSeverity = severityScore.clamp(0.0, 10.0);
    final safeDuration = durationDays < 0.0 ? 0.0 : durationDays;

    final severityDegrees = ClinicalFuzzyVariables.severity.fuzzify(safeSeverity);
    final durationDegrees = ClinicalFuzzyVariables.duration.fuzzify(safeDuration);

    double highRiskDegree = severityDegrees['HIGH'] ?? 0.0;

    double modChron = (severityDegrees['MODERATE'] ?? 0.0) < (durationDegrees['CHRONIC'] ?? 0.0)
        ? (severityDegrees['MODERATE'] ?? 0.0)
        : (durationDegrees['CHRONIC'] ?? 0.0);

    if (modChron > highRiskDegree) highRiskDegree = modChron;

    double fuzzyRiskScore = (safeSeverity / 10.0) * 0.7 + (highRiskDegree * 0.3);

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