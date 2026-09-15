// lib/ai/services/reasoning_stream_controller.dart

import 'dart:async';
import 'ai_reasoning_service.dart';
import '../explainability/reasoning_explanation.dart';

class ReasoningStreamController {
  final AIReasoningService _service = AIReasoningService();
  final StreamController<ReasoningExplanation> _controller =
      StreamController<ReasoningExplanation>.broadcast();

  /// Stream consumed by Flutter StreamBuilder / Provider / Bloc widgets
  Stream<ReasoningExplanation> get reasoningStream => _controller.stream;

  /// Triggered on UI input events (slider changes, symptom checkbox toggles)
  Future<void> updatePatientData({
    required Map<String, String> observedSymptoms,
    required double severityScore,
    required double durationDays,
  }) async {
    final explanation = await _service.analyzePatientData(
      observedSymptoms: observedSymptoms,
      severityScore: severityScore,
      durationDays: durationDays,
    );

    if (!_controller.isClosed) {
      _controller.add(explanation);
    }
  }

  void dispose() {
    _controller.close();
  }
}