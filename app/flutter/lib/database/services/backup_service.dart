import 'dart:convert';
import '../database_helper.dart';

class BackupService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Exports all patient records and their assessments into a structured JSON string
  Future<String> exportDatabaseToJson() async {
    final db = await _dbHelper.database;

    // Fetch all patients
    final List<Map<String, dynamic>> patients = await db.query('patients');

    // Fetch all assessments
    final List<Map<String, dynamic>> rawAssessments = await db.query('assessments');

    // Decode nested JSON fields inside assessments for clean structured export
    final List<Map<String, dynamic>> assessments = rawAssessments.map((record) {
      final map = Map<String, dynamic>.from(record);
      if (map['input_data'] != null && map['input_data'] is String) {
        try {
          map['input_data'] = jsonDecode(map['input_data']);
        } catch (_) {}
      }
      if (map['triggered_rules'] != null && map['triggered_rules'] is String) {
        try {
          map['triggered_rules'] = jsonDecode(map['triggered_rules']);
        } catch (_) {}
      }
      return map;
    }).toList();

    final exportPayload = {
      'metadata': {
        'system': 'Triora Offline Clinical Support',
        'version': '1.0.0',
        'exported_at': DateTime.now().toIso8601String(),
        'patient_count': patients.length,
        'assessment_count': assessments.length,
      },
      'patients': patients,
      'assessments': assessments,
    };

    return const JsonEncoder.withIndent('  ').convert(exportPayload);
  }

  /// Exports assessments flattened as standard CSV string for spreadsheet tools (Excel, LibreOffice)
  Future<String> exportAssessmentsToCsv() async {
    final db = await _dbHelper.database;

    // Join assessments with patients to get patient identifiers
    const String query = '''
      SELECT 
        a.id AS assessment_id,
        p.identifier AS patient_identifier,
        p.age,
        p.sex,
        a.assessment_date,
        a.risk_level,
        a.confidence,
        a.referral,
        a.explanation
      FROM assessments a
      LEFT JOIN patients p ON a.patient_id = p.id
      ORDER BY a.assessment_date DESC
    ''';

    final List<Map<String, dynamic>> records = await db.rawQuery(query);

    final StringBuffer csvBuffer = StringBuffer();

    // CSV Header row
    csvBuffer.writeln(
      'Assessment ID,Patient Identifier,Age,Sex,Assessment Date,Risk Level,Confidence,Referral,Explanation',
    );

    // Data rows
    for (final row in records) {
      final String id = _escapeCsv(row['assessment_id']?.toString() ?? '');
      final String patient = _escapeCsv(row['patient_identifier']?.toString() ?? '');
      final String age = row['age']?.toString() ?? '';
      final String sex = _escapeCsv(row['sex']?.toString() ?? '');
      final String date = _escapeCsv(row['assessment_date']?.toString() ?? '');
      final String risk = _escapeCsv(row['risk_level']?.toString() ?? '');
      final String conf = row['confidence']?.toString() ?? '';
      final String referral = _escapeCsv(row['referral']?.toString() ?? '');
      final String expl = _escapeCsv(row['explanation']?.toString() ?? '');

      csvBuffer.writeln('$id,$patient,$age,$sex,$date,$risk,$conf,$referral,$expl');
    }

    return csvBuffer.toString();
  }

  /// Helper to safely escape strings with quotes or commas according to RFC 4180
  String _escapeCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      final escaped = field.replaceAll('"', '""');
      return '"$escaped"';
    }
    return field;
  }
}