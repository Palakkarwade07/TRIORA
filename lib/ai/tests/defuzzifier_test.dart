// lib/ai/tests/defuzzifier_test.dart

import '../fuzzy/defuzzifier.dart';
import '../fuzzy/membership_function.dart';

void main() {
  // Output risk fuzzy sets defined on scale 0 - 100
  final outputSets = {
    'LOW': TrapezoidalMF(0, 0, 20, 40),
    'MODERATE': TriangularMF(30, 50, 70),
    'HIGH': TrapezoidalMF(60, 80, 100, 100),
  };

  // Simulated activation degrees after rule evaluation
  final activationDegrees = {
    'LOW': 0.10,
    'MODERATE': 0.60,
    'HIGH': 0.85,
  };

  final crispScore = Defuzzifier.centerOfGravity(
    outputSets: outputSets,
    activationDegrees: activationDegrees,
  );

  print('=== CENTER OF GRAVITY DEFUZZIFICATION TEST ===');
  print('Activation Degrees : $activationDegrees');
  print('Calculated Continuous Risk Score : $crispScore / 100.0');
}