// lib/ai/tests/bayesian_test.dart

import '../bayesian/bayesian_network.dart';

void main() {
  final bayesNet = BayesianNetwork();

  final evidence = {
    'fever': 'present',
    'respiratory_distress': 'present',
  };

  final distribution = bayesNet.inferRisk(evidence);

  print('--- Bayesian Variable Graph Inference Test ---');
  print('Input Evidence: $evidence');
  distribution.forEach((riskState, probability) {
    final percentage = (probability * 100).toStringAsFixed(1);
    print('Probability ($riskState): $percentage%');
  });
}