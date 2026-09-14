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

    # (end of save_assessment function above)
    conn.commit()
    conn.close()


def get_patient_history(patient_id):
    """Retrieves all past assessments for a specific patient ID."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        """
        SELECT assessment_id, risk_level, needs_referral, applied_rules 
        FROM assessments 
        WHERE patient_id = ? 
        ORDER BY assessment_id DESC
    """,
        (patient_id,),
    )
    rows = cursor.fetchall()
    conn.close()

    history = []
    for row in rows:
        history.append(
            {
                "assessment_id": row[0],
                "risk_level": row[1],
                "needs_referral": bool(row[2]),
                "applied_rules": json.loads(row[3]) if row[3] else [],
            }
        )
    return history


def get_clinical_summary():
    """Calculates overall intake metrics and risk counts."""
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT COUNT(*) FROM patients")
    total_patients = cursor.fetchone()[0]

    cursor.execute("SELECT COUNT(*) FROM assessments")
    total_assessments = cursor.fetchone()[0]

    cursor.execute(
        "SELECT risk_level, COUNT(*) FROM assessments GROUP BY risk_level"
    )
    risk_counts = dict(cursor.fetchall())

    conn.close()

    return {
        "total_patients": total_patients,
        "total_assessments": total_assessments,
        "risk_breakdown": risk_counts,
    }