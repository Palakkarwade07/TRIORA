class Assessment {
  final String assessmentId;
  final String patientId;
  final String assessmentDate;
  final String inputData; // Stored as a raw JSON string
  final String riskLevel;
  final double confidence;
  final String referral;
  final String explanation;

  Assessment({
    required this.assessmentId,
    required this.patientId,
    required this.assessmentDate,
    required this.inputData,
    required this.riskLevel,
    required this.confidence,
    required this.referral,
    required this.explanation,
  });

  // Convert Model to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'assessment_id': assessmentId,
      'patient_id': patientId,
      'assessment_date': assessmentDate,
      'input_data': inputData,
      'risk_level': riskLevel,
      'confidence': confidence,
      'referral': referral,
      'explanation': explanation,
    };
  }

  // Convert SQLite Map to Model
  factory Assessment.fromMap(Map<String, dynamic> map) {
    return Assessment(
      assessmentId: map['assessment_id'] as String,
      patientId: map['patient_id'] as String,
      assessmentDate: map['assessment_date'] as String,
      inputData: map['input_data'] as String,
      riskLevel: map['risk_level'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      referral: map['referral'] as String,
      explanation: map['explanation'] as String,
    );
  }
}