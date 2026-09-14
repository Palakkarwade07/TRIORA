import csv
import json
from STORAGE.db_manager import get_connection


def export_assessments_to_json(output_file="assessments_export.json"):
    """Exports all assessment records and details to a JSON file."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        """
        SELECT a.assessment_id, a.patient_id, a.risk_level, a.needs_referral, a.applied_rules, p.age_months
        FROM assessments a
        JOIN patients p ON a.patient_id = p.patient_id
    """
    )
    rows = cursor.fetchall()
    conn.close()

    export_data = []
    for row in rows:
        export_data.append(
            {
                "assessment_id": row[0],
                "patient_id": row[1],
                "risk_level": row[2],
                "needs_referral": bool(row[3]),
                "applied_rules": json.loads(row[4]) if row[4] else [],
                "age_months": row[5],
            }
        )

    with open(output_file, "w") as f:
        json.dump(export_data, f, indent=4)

    return len(export_data)


def export_assessments_to_csv(output_file="assessments_export.csv"):
    """Exports assessment summary data to a CSV file."""
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(
        """
        SELECT assessment_id, patient_id, risk_level, needs_referral 
        FROM assessments
    """
    )
    rows = cursor.fetchall()
    conn.close()

    with open(output_file, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(
            ["Assessment ID", "Patient ID", "Risk Level", "Needs Referral"]
        )
        for row in rows:
            writer.writerow([row[0], row[1], row[2], bool(row[3])])

    return len(rows)