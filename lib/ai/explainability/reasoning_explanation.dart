// lib/ai/explainability/reasoning_explanation.dart

class ReasoningExplanation {
  final String primaryRiskLevel;
  final double confidenceScore; // Range: 0.0 to 1.0
  final List<String> contributingFactors;
  final String probabilityProvenanceSummary;
  final String narrativeRationale;

  ReasoningExplanation({
    required this.primaryRiskLevel,
    required this.confidenceScore,
    required this.contributingFactors,
    required this.probabilityProvenanceSummary,
    required this.narrativeRationale,
  });

  @override
  String toString() {
    final confidencePct = (confidenceScore * 100).toStringAsFixed(1);
    return '''
==================================================
        CLINICAL EXPLAINABILITY REPORT
==================================================
Assigned Risk Level : $primaryRiskLevel
Confidence Rating   : $confidencePct%

Contributing Clinical Factors:
${contributingFactors.map((f) => '  - $f').join('\n')}

Probability Provenance:
  $probabilityProvenanceSummary

Diagnostic Rationale:
  $narrativeRationale
==================================================''';
  }
}