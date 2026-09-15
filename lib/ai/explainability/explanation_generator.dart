// lib/ai/explainability/explanation_generator.dart

import 'reasoning_explanation.dart';

class ExplanationGenerator {
  /// Synthesizes Bayesian probability distribution and Fuzzy set memberships
  ReasoningExplanation generate({
    required Map<String, double> bayesianDistribution,
    required Map<String, dynamic> fuzzyEvaluation,
    required Map<String, String> evidence,
  }) {
    // Determine dominant risk category
    String topRisk = 'LOW';
    double highestProb = 0.0;
    bayesianDistribution.forEach((riskState, prob) {
      if (prob > highestProb) {
        highestProb = prob;
        topRisk = riskState;
      }
    });

    // Calculate overall confidence score based on probability sharpness and fuzzy certainty
    double fuzzyScore = (fuzzyEvaluation['fuzzy_score'] as double? ?? 0.5);
    double confidence = (highestProb * 0.6) + (fuzzyScore * 0.4);

    // Extract clinical factors
    List<String> factors = [];
    evidence.forEach((symptom, status) {
      if (status == 'present') {
        factors.add('Observed Symptom: ${symptom.replaceAll('_', ' ').toUpperCase()}');
      }
    });

    Map<String, double> severityDegrees = Map<String, double>.from(
      fuzzyEvaluation['severity_degrees'] ?? {},
    );
    severityDegrees.forEach((level, degree) {
      if (degree > 0.3) {
        factors.add('Severity Membership ($level): ${(degree * 100).toStringAsFixed(0)}%');
      }
    });

    // Rationale construction
    String rationale = 'Patient presented with active symptoms (${evidence.keys.join(', ')}). '
        'Fuzzy reasoning evaluated a composite severity/duration score of ${fuzzyScore.toStringAsFixed(2)}, '
        'yielding a dominant $topRisk risk category with ${(highestProb * 100).toStringAsFixed(1)}% Bayesian certainty.';

    return ReasoningExplanation(
      primaryRiskLevel: topRisk,
      confidenceScore: double.parse(confidence.toStringAsFixed(2)),
      contributingFactors: factors,
      probabilityProvenanceSummary: 'WHO IMCI Guidelines Table 3 / Hybrid Expert Heuristic v1.0',
      narrativeRationale: rationale,
    );
  }
}