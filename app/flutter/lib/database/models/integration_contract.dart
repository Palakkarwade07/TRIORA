import 'dart:convert';

/// P3 (UI) builds this object from the user form and hands it to the clinical/AI engine.
class AssessmentInput {
  final String patientId;
  final int age;
  final String sex;
  final Map<String, dynamic> clinicalData; // Dynamic map of symptoms, vitals, observations

  AssessmentInput({
    required this.patientId,
    required this.age,
    required this.sex,
    required this.clinicalData,
  });

  Map<String, dynamic> toMap() {
    return {
      'patient_id': patientId,
      'age': age,
      'sex': sex,
      'clinical_data': clinicalData,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory AssessmentInput.fromMap(Map<String, dynamic> map) {
    return AssessmentInput(
      patientId: map['patient_id'] as String,
      age: map['age'] as int,
      sex: map['sex'] as String,
      clinicalData: Map<String, dynamic>.from(map['clinical_data'] ?? {}),
    );
  }

  factory AssessmentInput.fromJson(String source) =>
      AssessmentInput.fromMap(jsonDecode(source));
}

/// P1 (Rules) & P2 (AI) output this payload, which P3 displays and P4 stores.
class AssessmentResult {
  final String assessmentId;
  final String patientId;
  final String assessmentDate;
  final AssessmentInput input; // Reference to original input
  final String riskLevel; // e.g. LOW, MODERATE, HIGH, CRITICAL
  final double confidence; // e.g. 0.85
  final String referral; // e.g. ROUTINE, URGENT, NONE
  final String explanation; // Explainability text
  final List<String> triggeredRules; // Rules fired during clinical check

  AssessmentResult({
    required this.assessmentId,
    required this.patientId,
    required this.assessmentDate,
    required this.input,
    required this.riskLevel,
    required this.confidence,
    required this.referral,
    required this.explanation,
    required this.triggeredRules,
  });

  Map<String, dynamic> toMap() {
    return {
      'assessment_id': assessmentId,
      'patient_id': patientId,
      'assessment_date': assessmentDate,
      'input_data': input.toJson(),
      'risk_level': riskLevel,
      'confidence': confidence,
      'referral': referral,
      'explanation': explanation,
      'triggered_rules': triggeredRules,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory AssessmentResult.fromMap(Map<String, dynamic> map) {
    return AssessmentResult(
      assessmentId: map['assessment_id'] as String,
      patientId: map['patient_id'] as String,
      assessmentDate: map['assessment_date'] as String,
      input: AssessmentInput.fromJson(map['input_data'] as String),
      riskLevel: map['risk_level'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      referral: map['referral'] as String,
      explanation: map['explanation'] as String,
      triggeredRules: List<String>.from(map['triggered_rules'] ?? []),
    );
  }
}