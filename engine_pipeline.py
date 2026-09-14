import uuid
import json
from CLINICAL.rules.rule_engine import evaluate_rules
from CLINICAL.validators import validate_patient_intake, PatientValidationError
from STORAGE.db_manager import save_assessment, get_connection


def process_patient_intake(patient_data, rules_config):
    """Validates patient intake data, evaluates rules, and persists results."""
    validate_patient_intake(patient_data)
    assessment_result = evaluate_rules(patient_data, rules_config["rules"])
    assessment_result["assessment_id"] = f"EVAL-{uuid.uuid4().hex[:8]}"
    save_assessment(patient_data, assessment_result)
    return assessment_result


def process_batch_intake(patients_list, rules_config):
    """Validates and processes a batch of patient records within a single transaction."""
    for patient in patients_list:
        validate_patient_intake(patient)

    results = []
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("BEGIN TRANSACTION;")
        for patient in patients_list:
            assessment_result = evaluate_rules(patient, rules_config["rules"])
            assessment_id = f"EVAL-{uuid.uuid4().hex[:8]}"
            assessment_result["assessment_id"] = assessment_id

            cursor.execute(
                """
                INSERT OR REPLACE INTO patients (patient_id, age_months, fever_duration_days, has_danger_signs)
                VALUES (?, ?, ?, ?)
                """,
                (
                    patient["patient_id"],
                    patient["age_months"],
                    patient.get("fever_duration_days", 0),
                    patient.get("has_danger_signs", False),
                ),
            )

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
