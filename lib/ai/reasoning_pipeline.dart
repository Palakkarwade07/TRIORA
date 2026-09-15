// lib/ai/reasoning_pipeline.dart

import 'pipeline_contract.dart';

class ReasoningPipeline {
  Future<AssessmentResult> process({
    required Map<String, dynamic> rawInput,
    required ClinicalRuleResult ruleResult,
  }) async {
    // 1. Red Flag Override check
    if (ruleResult.redFlag) {
      return AssessmentResult(
        riskLevel: 'HIGH',
        confidence: 1.0,
        explanation: 'Red flag condition detected requiring urgent escalation.',
        triggeredRules: ruleResult.triggeredRules,
        evidence: ruleResult.evidence,
        referral: ruleResult.referralRecommendation ?? 'EMERGENCY_REFERRAL',
      );
    }

    // 2. Bayesian Reasoning Stage
    final bayesianProbabilities = _runBayesianInference(rawInput, ruleResult);

    // 3. Fuzzy Risk Assessment Stage
    final fuzzyScore = _runFuzzyEvaluation(rawInput);

    // 4. Combined Decision Policy
    final finalRisk = _combineDecision(bayesianProbabilities, fuzzyScore);

    // 5. Explanation & Confidence Generation
    final explanation = _generateExplanation(ruleResult, finalRisk);
    final confidence = _calculateConfidence(bayesianProbabilities);

    return AssessmentResult(
      riskLevel: finalRisk,
      confidence: confidence,
      explanation: explanation,
      triggeredRules: ruleResult.triggeredRules,
      evidence: ruleResult.evidence,
      referral: finalRisk == 'HIGH' ? 'REQUIRED' : 'OPTIONAL',
    );
  }

  Map<String, double> _runBayesianInference(Map<String, dynamic> input, ClinicalRuleResult ruleResult) {
    return {'LOW': 0.2, 'MODERATE': 0.3, 'HIGH': 0.5}; // Placeholder
  }

  double _runFuzzyEvaluation(Map<String, dynamic> input) {
    return 0.7; // Placeholder
  }

  String _combineDecision(Map<String, double> bayes, double fuzzy) {
    return (bayes['HIGH']! > 0.4 || fuzzy > 0.6) ? 'HIGH' : 'MODERATE';
  }

  String _generateExplanation(ClinicalRuleResult ruleResult, String risk) {
    return 'Assessment computed based on rule matches and probabilistic risk.';
  }

  double _calculateConfidence(Map<String, double> bayes) {
    return bayes.values.reduce((a, b) => a > b ? a : b);
  }
}