// lib/ai/tests/explainability_test.dart

import '../bayesian/bayesian_network.dart';
import '../fuzzy/fuzzy_engine.dart';
import '../explainability/explanation_generator.dart';

void main() {
  final bayesNet = BayesianNetwork();
  final fuzzyEngine = FuzzyEngine();
  final explanationGenerator = ExplanationGenerator();

  // 1. Clinical inputs
  final evidence = {
    'fever': 'present',
    'respiratory_distress': 'present',
  };
  double severityInput = 8.5; // Scale 0-10
  double durationDays = 12;   // Days

  // 2. Compute Bayesian distribution
  final bayesDist = bayesNet.inferRisk(evidence);

  // 3. Compute Fuzzy risk evaluation
  final fuzzyEval = fuzzyEngine.evaluate(
    severityScore: severityInput,
    durationDays: durationDays,
  );

  // 4. Generate Explainable Diagnostic Output
  final report = explanationGenerator.generate(
    bayesianDistribution: bayesDist,
    fuzzyEvaluation: fuzzyEval,
    evidence: evidence,
  );

  print(report);
}