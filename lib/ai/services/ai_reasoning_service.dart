// lib/ai/services/ai_reasoning_service.dart

import '../bayesian/bayesian_network.dart';
import '../bayesian/inference_engine.dart';
import '../fuzzy/fuzzy_engine.dart';
import '../fuzzy/defuzzifier.dart';
import '../fuzzy/membership_function.dart';
import '../explainability/explanation_generator.dart';
import '../explainability/reasoning_explanation.dart';

class AIReasoningService {
  late final BayesianNetwork _bayesNet;
  late final DynamicInferenceEngine _inferenceEngine;
  late final FuzzyEngine _fuzzyEngine;
  late final ExplanationGenerator _explanationGenerator;

  AIReasoningService() {
    _bayesNet = BayesianNetwork();
    _inferenceEngine = DynamicInferenceEngine(_bayesNet);
    _fuzzyEngine = FuzzyEngine();
    _explanationGenerator = ExplanationGenerator();
  }

  /// Single service endpoint called by Flutter UI Controllers / State Managers
  Future<ReasoningExplanation> analyzePatientData({
    required Map<String, String> observedSymptoms,
    required double severityScore,
    required double durationDays,
  }) async {
    // 1. Dynamic Bayesian Inference
    final bayesianPosterior = _inferenceEngine.inferTarget(
      targetNodeId: 'clinical_risk',
      observedEvidence: observedSymptoms,
    );

    // 2. Continuous Fuzzy Set Evaluation
    final fuzzyEvaluation = _fuzzyEngine.evaluate(
      severityScore: severityScore,
      durationDays: durationDays,
    );

    // 3. Center of Gravity Defuzzification
    final outputSets = {
      'LOW': TrapezoidalMF(0, 0, 20, 40),
      'MODERATE': TriangularMF(30, 50, 70),
      'HIGH': TrapezoidalMF(60, 80, 100, 100),
    };

    final activeDegrees = {
      'LOW': bayesianPosterior['LOW'] ?? 0.0,
      'MODERATE': bayesianPosterior['MODERATE'] ?? 0.0,
      'HIGH': bayesianPosterior['HIGH'] ?? 0.0,
    };

    final continuousRiskScore = Defuzzifier.centerOfGravity(
      outputSets: outputSets,
      activationDegrees: activeDegrees,
    );

    fuzzyEvaluation['defuzzified_risk_score'] = continuousRiskScore;

    // 4. Generate Structured Explanation Output
    return _explanationGenerator.generate(
      bayesianDistribution: bayesianPosterior,
      fuzzyEvaluation: fuzzyEvaluation,
      evidence: observedSymptoms,
    );
  }
}