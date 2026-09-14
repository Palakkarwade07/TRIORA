import sys
import json
from engine_pipeline import process_patient_intake, process_batch_intake
from STORAGE.db_manager import get_patient_history, get_clinical_summary
from STORAGE.exporter import export_assessments_to_json, export_assessments_to_csv
from CLINICAL.validators import PatientValidationError

# Sample default rules configuration
DEFAULT_RULES = {
    "rules": [
        {
            "id": "RULE_DANGER_01",
            "conditions": {"has_danger_signs": True},
            "risk_level": "HIGH",
            "referral_required": True,
        },
        {
            "id": "RULE_FEVER_01",
            "conditions": {"fever_duration_days": 7},
            "risk_level": "MODERATE",
            "referral_required": False,
        },
    ]
}


def print_menu():
    print("\n=========================================")
    print("      TRIORA CLINICAL ASSESSMENT ENGINE  ")
    print("=========================================")
    print("1. Process Single Patient Intake")
    print("2. Process Batch Patient Intake")
    print("3. View Patient History")
    print("4. Display Clinical Metrics Summary")
    print("5. Export Assessments (JSON & CSV)")
    print("6. Exit")
    print("=========================================")


def main():
    while True:
        print_menu()
        choice = input("Select an option (1-6): ").strip()

        if choice == "1":
            p_id = input("Enter Patient ID: ").strip()
            age = input("Enter Age in Months: ").strip()
            fever = input("Enter Fever Duration (days): ").strip()
            danger = input("Has Danger Signs? (y/n): ").strip().lower() == "y"

            try:
                patient = {
                    "patient_id": p_id,
                    "age_months": float(age) if age else 0,
                    "fever_duration_days": float(fever) if fever else 0,
                    "has_danger_signs": danger,
                }
                res = process_patient_intake(patient, DEFAULT_RULES)
                print(f"\n[SUCCESS] Assessment Generated: {json.dumps(res, indent=2)}")
            except PatientValidationError as e:
                print(f"\n[VALIDATION ERROR] {e}")
            except Exception as e:
                print(f"\n[ERROR] {e}")

        elif choice == "2":
            print("\nProcessing demo batch...")
            demo_batch = [
                {"patient_id": "CLI-BATCH-01", "age_months": 18, "fever_duration_days": 2, "has_danger_signs": False},
                {"patient_id": "CLI-BATCH-02", "age_months": 24, "fever_duration_days": 9, "has_danger_signs": True},
            ]
            try:
                results = process_batch_intake(demo_batch, DEFAULT_RULES)
                print(f"\n[SUCCESS] Processed {len(results)} records in batch.")
            except Exception as e:
                print(f"\n[ERROR] Batch processing failed: {e}")

        elif choice == "3":
            p_id = input("Enter Patient ID to lookup: ").strip()
            history = get_patient_history(p_id)
            print(f"\nHistory for {p_id}: {json.dumps(history, indent=2)}")

        elif choice == "4":
            summary = get_clinical_summary()
            print(f"\n--- Clinical Metrics Summary ---\n{json.dumps(summary, indent=2)}")

        elif choice == "5":
            j_cnt = export_assessments_to_json()
            c_cnt = export_assessments_to_csv()
            print(f"\n[SUCCESS] Exported {j_cnt} records to JSON and {c_cnt} records to CSV.")

        elif choice == "6":
            print("Exiting engine. Goodbye!")
            sys.exit(0)
        else:
            print("Invalid selection. Try again.")


if __name__ == "__main__":
    main()