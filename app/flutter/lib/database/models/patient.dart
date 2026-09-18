class Patient {
  final String patientId;
  final String identifier;
  final int age;
  final String sex;
  final String createdAt;
  final String updatedAt;

  Patient({
    required this.patientId,
    required this.identifier,
    required this.age,
    required this.sex,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Model to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'patient_id': patientId,
      'identifier': identifier,
      'age': age,
      'sex': sex,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Build Model from SQLite Map query
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      patientId: map['patient_id'] as String,
      identifier: map['identifier'] as String,
      age: map['age'] as int,
      sex: map['sex'] as String,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}