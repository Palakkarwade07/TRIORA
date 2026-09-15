// lib/ai/pipeline_contract.dart

class ClinicalRuleResult {
  final bool redFlag;
  final List<String> triggeredRules;
  final Map<String, dynamic> evidence;
  final String? referralRecommendation;

  ClinicalRuleResult({
    required this.redFlag,
    required this.triggeredRules,
    required this.evidence,
    this.referralRecommendation,
  });
}

class AssessmentResult {
  final String riskLevel; // LOW, MODERATE, HIGH
  final double confidence; // e.g., 0.85 (85%)
  final String explanation;
  final List<String> triggeredRules;
  final Map<String, dynamic> evidence;
  final String referral;

  AssessmentResult({
    required this.riskLevel,
    required this.confidence,
    required this.explanation,
    required this.triggeredRules,
    required this.evidence,
    required this.referral,
  });
}