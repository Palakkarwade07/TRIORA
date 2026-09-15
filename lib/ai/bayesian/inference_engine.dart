// lib/ai/bayesian/inference_engine.dart

// ignore: unused_import
import "bayesian_node.dart";
import 'bayesian_network.dart';

class DynamicInferenceEngine {
  final BayesianNetwork network;

  DynamicInferenceEngine(this.network);

  /// Dynamically infers target posterior distribution for missing/partial evidence
  Map<String, double> inferTarget({
    required String targetNodeId,
    required Map<String, String> observedEvidence,
  }) {
    final targetNode = network.nodes[targetNodeId];
    if (targetNode == null) return {};

    final Map<String, double> posterior = {
      for (var state in targetNode.states) state: 0.0
    };

    double totalWeight = 0.0;

    // Iterate through CPT entries and weight probabilities matching observed subset evidence
    targetNode.cpt.forEach((cptKey, stateMap) {
      double matchWeight = 1.0;

      // Parse parent key pair states (e.g. "fever:present|respiratory_distress:absent")
      final conditionPairs = cptKey.split('|');
      for (var pair in conditionPairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          final parentId = parts[0];
          final expectedState = parts[1];

          // Marginalize: if parent observed, apply state match weight; if missing, apply prior
          if (observedEvidence.containsKey(parentId)) {
            if (observedEvidence[parentId] != expectedState) {
              matchWeight *= 0.05; // Soft penalty for unobserved state match
            } else {
              matchWeight *= 1.0;
            }
          } else {
            // Unobserved evidence variable marginalization factor
            matchWeight *= 0.5;
          }
        }
      }

      stateMap.forEach((state, meta) {
        posterior[state] = (posterior[state] ?? 0.0) + (meta.value * matchWeight);
      });
      totalWeight += matchWeight;
    });

    // Normalize state probabilities sum to 1.0
    if (totalWeight > 0) {
      posterior.updateAll((state, prob) => double.parse((prob / totalWeight).toStringAsFixed(4)));
    }

    return posterior;
  }
}