// lib/ai/tests/dynamic_inference_test.dart

import '../bayesian/bayesian_network.dart';
import '../bayesian/inference_engine.dart';

void main() {
  final network = BayesianNetwork();
  final engine = DynamicInferenceEngine(network);

  // Partial evidence: Only fever is known, respiratory distress is omitted/missing
  final partialEvidence = {
    'fever': 'present',
  };

  final result = engine.inferTarget(
    targetNodeId: 'clinical_risk',
    observedEvidence: partialEvidence,
  );

  print('=== DYNAMIC VARIABLE ELIMINATION TEST ===');
  print('Observed Partial Evidence: $partialEvidence');
  print('Dynamic Risk Posterior Distribution:');
  result.forEach((state, prob) {
    print('  - $state: ${(prob * 100).toStringAsFixed(1)}%');
  });
}