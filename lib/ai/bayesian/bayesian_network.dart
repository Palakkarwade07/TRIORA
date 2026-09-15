// lib/ai/bayesian/bayesian_network.dart

import 'bayesian_node.dart';

class BayesianNetwork {
  final Map<String, BayesianNode> nodes = {};

  BayesianNetwork() {
    _initializeNetwork();
  }

  void _initializeNetwork() {
    // 1. Evidence Node: Fever
    nodes['fever'] = BayesianNode(
      id: 'fever',
      states: ['present', 'absent'],
      cpt: {
        'default': {'present': 0.30, 'absent': 0.70}
      },
    );

    // 2. Evidence Node: Respiratory Distress
    nodes['respiratory_distress'] = BayesianNode(
      id: 'respiratory_distress',
      states: ['present', 'absent'],
      cpt: {
        'default': {'present': 0.10, 'absent': 0.90}
      },
    );

    // 3. Target Variable Node: Clinical Risk (Parents: fever, respiratory_distress)
    nodes['clinical_risk'] = BayesianNode(
      id: 'clinical_risk',
      states: ['LOW', 'MODERATE', 'HIGH'],
      parentIds: ['fever', 'respiratory_distress'],
      cpt: {
        'fever:absent|respiratory_distress:absent': {'LOW': 0.85, 'MODERATE': 0.10, 'HIGH': 0.05},
        'fever:present|respiratory_distress:absent': {'LOW': 0.40, 'MODERATE': 0.45, 'HIGH': 0.15},
        'fever:absent|respiratory_distress:present': {'LOW': 0.10, 'MODERATE': 0.30, 'HIGH': 0.60},
        'fever:present|respiratory_distress:present': {'LOW': 0.02, 'MODERATE': 0.18, 'HIGH': 0.80},
      },
    );
  }

  /// Calculates posterior probability distribution given observed symptom evidence
  Map<String, double> inferRisk(Map<String, String> evidence) {
    String feverState = evidence['fever'] ?? 'absent';
    String respState = evidence['respiratory_distress'] ?? 'absent';

    String cptKey = 'fever:$feverState|respiratory_distress:$respState';

    return nodes['clinical_risk']?.cpt[cptKey] ?? {
      'LOW': 0.33,
      'MODERATE': 0.33,
      'HIGH': 0.34,
    };
  }
}