// lib/ai/fuzzy/fuzzy_variable.dart

import 'membership_function.dart';

class FuzzyVariable {
  final String name;
  final Map<String, MembershipFunction> sets;

  FuzzyVariable({required this.name, required this.sets});

  Map<String, double> fuzzify(double value) {
    final Map<String, double> degrees = {};
    sets.forEach((label, mf) {
      degrees[label] = double.parse(mf.calculate(value).toStringAsFixed(2));
    });
    return degrees;
  }
}

class ClinicalFuzzyVariables {
  /// Severity (0 - 10 scale)
  static final FuzzyVariable severity = FuzzyVariable(
    name: 'severity',
    sets: {
      'LOW': TrapezoidalMF(0, 0, 2, 5),       // Full 1.0 from 0 to 2, ramps down to 0 at 5
      'MODERATE': TriangularMF(3, 5, 8),     // Peak 1.0 at 5
      'HIGH': TrapezoidalMF(6, 8, 10, 10),    // Ramps up from 6, full 1.0 from 8 to 10
    },
  );

  /// Duration (Days)
  static final FuzzyVariable duration = FuzzyVariable(
    name: 'duration_days',
    sets: {
      'ACUTE': TrapezoidalMF(0, 0, 3, 7),
      'SUBACUTE': TriangularMF(5, 14, 21),
      'CHRONIC': TrapezoidalMF(14, 28, 365, 365),
    },
  );
}