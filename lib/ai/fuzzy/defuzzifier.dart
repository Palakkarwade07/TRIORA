// lib/ai/fuzzy/defuzzifier.dart

import 'membership_function.dart';

class Defuzzifier {
  /// Calculates a crisp numerical output score [0.0 - 100.0] using the Centroid method
  static double centerOfGravity({
    required Map<String, MembershipFunction> outputSets,
    required Map<String, double> activationDegrees,
    double min = 0.0,
    double max = 100.0,
    double step = 0.5,
  }) {
    double numerator = 0.0;
    double denominator = 0.0;

    // Discretize the domain range [0.0, 100.0] into discrete samples
    for (double x = min; x <= max; x += step) {
      double aggregateMembership = 0.0;

      // Mamdani min-max clipping/aggregation across active sets
      outputSets.forEach((label, mf) {
        final activation = activationDegrees[label] ?? 0.0;
        final membership = mf.calculate(x);
        
        // Clip membership height by rule activation level
        final clippedValue = membership < activation ? membership : activation;
        
        if (clippedValue > aggregateMembership) {
          aggregateMembership = clippedValue;
        }
      });

      numerator += x * aggregateMembership;
      denominator += aggregateMembership;
    }

    if (denominator == 0) return (min + max) / 2.0; // Fallback to midpoint
    return double.parse((numerator / denominator).toStringAsFixed(2));
  }
}