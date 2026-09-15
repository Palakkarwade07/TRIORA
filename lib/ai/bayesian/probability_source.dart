// lib/ai/bayesian/probability_source.dart

enum ProbabilityOrigin {
  sourced,      // Defensible source (WHO, ICMR, clinical guidelines)
  assumption,   // Expert/clinical heuristic assumption
  testDemo      // Demo placeholder for prototype testing
}

class ProbabilityMetadata {
  final double value;
  final ProbabilityOrigin origin;
  final String sourceCitation;

  ProbabilityMetadata({
    required this.value,
    required this.origin,
    required this.sourceCitation,
  });
}