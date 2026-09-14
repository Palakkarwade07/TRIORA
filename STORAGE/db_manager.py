import json
import sqlite3

DB_PATH = "TRIORA.db"


def get_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON;")
    return conn


def save_assessment(patient_data, assessment_result):
    conn = get_connection()
    cursor = conn.cursor()

    # Insert patient information
    cursor.execute(
        """
        INSERT OR REPLACE INTO patients (patient_id, age_months, fever_duration_days, has_danger_signs)
        VALUES (?, ?, ?, ?)
    """,
        (
            patient_data["patient_id"],
            patient_data["age_months"],
            patient_data["fever_duration_days"],
            patient_data.get("has_danger_signs", False),
        ),
    )

    # Safely extract values regardless of minor key mismatches
    risk_level = assessment_result.get("risk_level") or assessment_result.get(
        "risk", "UNKNOWN"
    )
    needs_referral = assessment_result.get(
        "needs_referral", assessment_result.get("referral_required", False)
    )

    # Insert assessment outcome
   # Insert assessment outcome
    cursor.execute(
        """
        INSERT OR REPLACE INTO assessments (assessment_id, patient_id, risk_level, needs_referral, applied_rules)
        VALUES (?, ?, ?, ?, ?)
    """,
        (
            assessment_result["assessment_id"],
            patient_data["patient_id"],
            risk_level,
            needs_referral,
            json.dumps(
                assessment_result.get(
                    "applied_rules",
                    assessment_result.get(
                        "triggered_rules",
                        assessment_result.get("rules_triggered", []),
                    ),
                )
            ),
        ),
    )

    conn.commit()
    conn.close()