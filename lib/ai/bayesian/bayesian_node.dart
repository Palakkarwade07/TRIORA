// lib/ai/bayesian/bayesian_node.dart

class BayesianNode {
  final String id;
  final List<String> states;
  final List<String> parentIds;
  
  // Conditional Probability Table: Map<ParentKey, Map<State, Probability>>
  final Map<String, Map<String, double>> cpt;

  BayesianNode({
    required this.id,
    required this.states,
    this.parentIds = const [],
    required this.cpt,
  });
}