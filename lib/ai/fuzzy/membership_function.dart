// lib/ai/fuzzy/membership_function.dart

abstract class MembershipFunction {
  double calculate(double x);
}

/// Triangular Membership Function defined by 3 points (a, b, c)
class TriangularMF implements MembershipFunction {
  final double a;
  final double b;
  final double c;

  TriangularMF(this.a, this.b, this.c);

  @override
  double calculate(double x) {
    if (x <= a || x >= c) return 0.0;
    if (x == b) return 1.0;
    if (x > a && x < b) return (x - a) / (b - a);
    return (c - x) / (c - b);
  }
}

/// Trapezoidal Membership Function defined by 4 points (a, b, c, d)
class TrapezoidalMF implements MembershipFunction {
  final double a;
  final double b;
  final double c;
  final double d;

  TrapezoidalMF(this.a, this.b, this.c, this.d);

  @override
  double calculate(double x) {
    if (x <= a || x >= d) return 0.0;
    if (x >= b && x <= c) return 1.0;
    if (x > a && x < b) return (x - a) / (b - a);
    return (d - x) / (d - c);
  }
}