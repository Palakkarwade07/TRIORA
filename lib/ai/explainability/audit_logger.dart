// lib/ai/explainability/audit_logger.dart

import 'reasoning_explanation.dart';

class AuditLogger {
  final List<String> _logs = [];

  List<String> get logs => List.unmodifiable(_logs);

  void logAnalysisEvent({
    required String patientId,
    required Map<String, String> inputs,
    required ReasoningExplanation explanation,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '''
[AUDIT RECORD | $timestamp]
Patient ID : $patientId
Evidence   : $inputs
Risk       : ${explanation.primaryRiskLevel} (Confidence: ${(explanation.confidenceScore * 100).toStringAsFixed(1)}%)
Provenance : ${explanation.probabilityProvenanceSummary}
--------------------------------------------------''';
    _logs.add(logEntry);
  }
}