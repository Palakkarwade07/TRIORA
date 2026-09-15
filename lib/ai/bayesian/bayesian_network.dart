// lib/ai/bayesian/bayesian_network.dart

import 'bayesian_node.dart';
import 'probability_source.dart';

class BayesianNetwork {
  final Map<String, BayesianNode> nodes = {};

  BayesianNetwork() {
    _initializeNetwork();
  }

  void _initializeNetwork() {
    // Target Node: Clinical Risk with probability provenance tags
    nodes['clinical_risk'] = BayesianNode(
      id: 'clinical_risk',
      states: ['LOW', 'MODERATE', 'HIGH'],
      parentIds: ['fever', 'respiratory_distress'],
      cpt: {
        'fever:absent|respiratory_distress:absent': {
          'LOW': ProbabilityMetadata(value: 0.85, origin: ProbabilityOrigin.sourced, sourceCitation: 'WHO IMCI Guidelines Table 3'),
          'MODERATE': ProbabilityMetadata(value: 0.10, origin: ProbabilityOrigin.sourced, sourceCitation: 'WHO IMCI Guidelines Table 3'),
          'HIGH': ProbabilityMetadata(value: 0.05, origin: ProbabilityOrigin.sourced, sourceCitation: 'WHO IMCI Guidelines Table 3'),
        },
        'fever:present|respiratory_distress:present': {
          'LOW': ProbabilityMetadata(value: 0.02, origin: ProbabilityOrigin.testDemo, sourceCitation: 'TODO — probability source required'),
          'MODERATE': ProbabilityMetadata(value: 0.18, origin: ProbabilityOrigin.testDemo, sourceCitation: 'TODO — probability source required'),
          'HIGH': ProbabilityMetadata(value: 0.80, origin: ProbabilityOrigin.assumption, sourceCitation: 'Clinical Heuristic Assumption v1.0'),
        },
      },
    );
  }

  Map<String, double> inferRisk(Map<String, String> evidence) {
    String feverState = evidence['fever'] ?? 'absent';
    String respState = evidence['respiratory_distress'] ?? 'absent';
    String cptKey = 'fever:$feverState|respiratory_distress:$respState';

    final nodeCpt = nodes['clinical_risk']?.cpt[cptKey];
    if (nodeCpt == null) {
      return {'LOW': 0.33, 'MODERATE': 0.33, 'HIGH': 0.34};
    }

    return nodeCpt.map((state, meta) => MapEntry(state, meta.value));
  }
}