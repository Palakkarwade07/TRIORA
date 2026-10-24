import json
import sqlite3

DB_PATH = "TRIORA.db"


def get_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON;")
    return conn


def init_db():
    """Initializes the SQLite database, creates tables, and adds performance indexes."""
    conn = get_connection()
    cursor = conn.cursor()
    
    # Create patients table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS patients (
            patient_id TEXT PRIMARY KEY,
            age_months INTEGER NOT NULL,
            fever_duration_days INTEGER,
            has_danger_signs BOOLEAN
        )
    """)
    
    # Create assessments table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS assessments (
            assessment_id TEXT PRIMARY KEY,
            patient_id TEXT NOT NULL,
            risk_level TEXT NOT NULL,
            needs_referral BOOLEAN NOT NULL,
            applied_rules TEXT,
            FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
        )
    """)
    
    # --- DAY 13: DATABASE INDEX OPTIMIZATION ---
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_patient_id ON assessments(patient_id);
    """)
    cursor.execute("""
        CREATE INDEX IF NOT EXISTS idx_risk_level ON assessments(risk_level);
    """)
    
    conn.commit()
    conn.close()


# Automatically initialize database and indexes on module load
init_db()


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