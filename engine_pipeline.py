# engine_pipeline.py
import uuid
from CLINICAL.rules.rule_engine import evaluate_rules
from STORAGE.db_manager import save_assessment


def process_patient_intake(patient_data, rules_config):
    """Processes patient data through the clinical rule engine and persists results."""
    # 1. Evaluate clinical rules
    assessment_result = evaluate_rules(patient_data, rules_config["rules"])

    # 2. Attach a unique assessment ID
    assessment_result["assessment_id"] = f"EVAL-{uuid.uuid4().hex[:8]}"

    # 3. Persist patient and assessment records
    save_assessment(patient_data, assessment_result)

    return assessment_result
