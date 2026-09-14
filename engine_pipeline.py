import uuid
from CLINICAL.rules.rule_engine import evaluate_rules
from STORAGE.db_manager import save_assessment, get_connection
import json

def process_patient_intake(patient_data, rules_config):
    """Processes single patient data through the clinical rule engine and persists results."""
    assessment_result = evaluate_rules(patient_data, rules_config["rules"])
    assessment_result["assessment_id"] = f"EVAL-{uuid.uuid4().hex[:8]}"
    save_assessment(patient_data, assessment_result)
    return assessment_result

def process_batch_intake(patients_list, rules_config):
    """Processes a batch of patient records in a single database transaction for performance."""
    results = []
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("BEGIN TRANSACTION;")
        for patient in patients_list:
            assessment_result = evaluate_rules(patient, rules_config["rules"])
            assessment_id = f"EVAL-{uuid.uuid4().hex[:8]}"
            assessment_result["assessment_id"] = assessment_id

            # Insert patient
            cursor.execute(
                """
                INSERT OR REPLACE INTO patients (patient_id, age_months, fever_duration_days, has_danger_signs)
                VALUES (?, ?, ?, ?)
                """,
                (
                    patient["patient_id"],
                    patient["age_months"],
                    patient["fever_duration_days"],
                    patient.get("has_danger_signs", False),
                ),
            )

            # Insert assessment
            risk_level = assessment_result.get("risk_level", "LOW")
            needs_referral = assessment_result.get("referral_required", False)

            cursor.execute(
                """
                INSERT OR REPLACE INTO assessments (assessment_id, patient_id, risk_level, needs_referral, applied_rules)
                VALUES (?, ?, ?, ?, ?)
                """,
                (
                    assessment_id,
                    patient["patient_id"],
                    risk_level,
                    needs_referral,
                    json.dumps(assessment_result.get("triggered_rules", [])),
                ),
            )
            results.append(assessment_result)

        conn.commit()
    except Exception as e:
        conn.rollback()
        raise e
    finally:
        conn.close()

    return results
