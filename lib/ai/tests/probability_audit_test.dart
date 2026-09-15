// lib/ai/tests/probability_audit_test.dart

import '../bayesian/bayesian_network.dart';
import '../bayesian/probability_source.dart';

void main() {
  final network = BayesianNetwork();
  int totalValues = 0;
  int unverifiedCount = 0;

  print('=== PROBABILITY SOURCE AUDIT REPORT ===');

  network.nodes.forEach((nodeId, node) {
    node.cpt.forEach((cptKey, stateMap) {
      stateMap.forEach((state, meta) {
        totalValues++;
        if (meta.origin == ProbabilityOrigin.testDemo || meta.sourceCitation.contains('TODO')) {
          unverifiedCount++;
          print('[UNVERIFIED] Node: $nodeId | Key: $cptKey | State: $state | Citation: "${meta.sourceCitation}"');
        } else {
          print('[SOURCED] Node: $nodeId | State: $state | Source: ${meta.sourceCitation}');
        }
      });
    });
  });

  print('\nSummary: $unverifiedCount of $totalValues probability values require defensible sources.');
}