// lib/ai/tests/pipeline_test.dart

import '../reasoning_pipeline.dart';
import '../pipeline_contract.dart';

void main() async {
  final pipeline = ReasoningPipeline();
  
  final mockRuleResult = ClinicalRuleResult(
    redFlag: false,
    triggeredRules: ['R001'],
    evidence: {'symptom_A': true},
  );

  final result = await pipeline.process(
    rawInput: {'age': 25, 'severity': 8},
    ruleResult: mockRuleResult,
  );

  print('Pipeline working correctly! Calculated Risk: ${result.riskLevel}');
}