// lib/ai/bayesian/bayesian_node.dart

import 'probability_source.dart';

class BayesianNode {
  final String id;
  final List<String> states;
  final List<String> parentIds;
  
  // Mapping: ParentKey -> (State -> ProbabilityMetadata)
  final Map<String, Map<String, ProbabilityMetadata>> cpt;

  BayesianNode({
    required this.id,
    required this.states,
    this.parentIds = const [],
    required this.cpt,
  });
}