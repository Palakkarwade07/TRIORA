# TRIORA AI Reasoning Engine

High-performance hybrid AI engine combining Bayesian Networks and Fuzzy Logic for real-time offline clinical triage.

## Architecture & Features
- **Bayesian Network (`lib/ai/bayesian/`)**: Probabilistic inference engine supporting dynamic variable elimination and probability provenance tracking.
- **Fuzzy Logic Engine (`lib/ai/fuzzy/`)**: Continuous variable assessment (severity/duration) with Center of Gravity (CoG) defuzzification.
- **Explainability Generator (`lib/ai/explainability/`)**: Human-readable clinical rationale output with confidence scoring and audit logging.
- **Service Layer Facade (`lib/ai/services/`)**: Unified service wrapper and reactive `StreamController` for Flutter UI state management.

## Quick Start Usage
(dart...
final aiService = AIReasoningService();

final result = await aiService.analyzePatientData(
observedSymptoms: {
'fever': 'present',
'respiratory_distress': 'present',
},
severityScore: 8.5,
durationDays: 4,
);

print('Assigned Risk: ${result.primaryRiskLevel}');
print('Confidence: ${result.confidenceScore}');
)