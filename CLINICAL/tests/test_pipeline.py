import sqlite3
import unittest
from engine_pipeline import process_patient_intake, process_batch_intake
from STORAGE.db_manager import get_patient_history, get_clinical_summary
from CLINICAL.validators import PatientValidationError


class TestEnginePipeline(unittest.TestCase):

    def setUp(self):
        self.rules_config = {
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

    def test_high_risk_intake_persistence(self):
        patient = {
            "patient_id": "TEST-P01",
            "age_months": 24,
            "fever_duration_days": 2,
            "has_danger_signs": True,
        }
        result = process_patient_intake(patient, self.rules_config)

        # Assert memory result
        self.assertEqual(result["risk_level"], "HIGH")

        # Assert database record
        conn = sqlite3.connect("TRIORA.db")
        row = conn.execute(
            "SELECT risk_level, needs_referral FROM assessments WHERE patient_id='TEST-P01'"
        ).fetchone()
        conn.close()

        self.assertIsNotNone(row)
        self.assertEqual(row[0], "HIGH")
        self.assertEqual(row[1], 1)

    def test_priority_conflict_resolution(self):
        # Patient triggers both MODERATE and HIGH risk rules
        patient = {
            "patient_id": "TEST-P02",
            "age_months": 12,
            "fever_duration_days": 7,
            "has_danger_signs": True,
        }
        result = process_patient_intake(patient, self.rules_config)
        self.assertEqual(result["risk_level"], "HIGH")
        self.assertEqual(len(result["triggered_rules"]), 2)

    def test_missing_intake_fields_graceful_handling(self):
        # Patient missing 'has_danger_signs' field entirely
        patient = {
            "patient_id": "TEST-P03",
            "age_months": 6,
            "fever_duration_days": 2,
        }
        result = process_patient_intake(patient, self.rules_config)
        self.assertEqual(result["risk_level"], "LOW")
        self.assertFalse(result["referral_required"])

    def test_batch_patient_processing(self):
        patients = [
            {
                "patient_id": "BATCH-01",
                "age_months": 10,
                "fever_duration_days": 1,
                "has_danger_signs": False,
            },
            {
                "patient_id": "BATCH-02",
                "age_months": 36,
                "fever_duration_days": 8,
                "has_danger_signs": True,
            },
        ]
        results = process_batch_intake(patients, self.rules_config)
        self.assertEqual(len(results), 2)

        # Verify persistence in DB
        conn = sqlite3.connect("TRIORA.db")
        count = conn.execute(
            "SELECT COUNT(*) FROM patients WHERE patient_id LIKE 'BATCH-%'"
        ).fetchone()[0]
        conn.close()
        self.assertEqual(count, 2)

    def test_query_utilities_and_summary(self):
        # Test fetching history for an existing test patient
        history = get_patient_history("TEST-P01")
        self.assertTrue(len(history) > 0)
        self.assertEqual(history[0]["risk_level"], "HIGH")

        # Test clinical metrics summary calculation
        summary = get_clinical_summary()
        self.assertIn("total_patients", summary)
        self.assertIn("risk_breakdown", summary)
        self.assertTrue(summary["total_assessments"] > 0)

    def test_validation_missing_required_field(self):
        invalid_patient = {"age_months": 12}  # Missing patient_id
        with self.assertRaises(PatientValidationError):
            process_patient_intake(invalid_patient, self.rules_config)

    def test_validation_invalid_data_type(self):
        invalid_patient = {"patient_id": "TEST-ERR", "age_months": -5}  # Invalid negative age
        with self.assertRaises(PatientValidationError):
            process_patient_intake(invalid_patient, self.rules_config)


    def test_json_and_csv_exporters(self):
        import os
        from STORAGE.exporter import export_assessments_to_json, export_assessments_to_csv

        json_file = "test_export.json"
        csv_file = "test_export.csv"

        json_count = export_assessments_to_json(json_file)
        csv_count = export_assessments_to_csv(csv_file)

        self.assertTrue(os.path.exists(json_file))
        self.assertTrue(os.path.exists(csv_file))
        self.assertTrue(json_count > 0)
        self.assertTrue(csv_count > 0)

        # Cleanup temporary test files
        os.remove(json_file)
        os.remove(csv_file)  


    def test_full_system_integration(self):
        from STORAGE.db_manager import get_patient_history, get_clinical_summary
        from STORAGE.exporter import export_assessments_to_json, export_assessments_to_csv

        patient = {
            "patient_id": "E2E-TEST-99",
            "age_months": 14,
            "fever_duration_days": 8,
            "has_danger_signs": True,
        }
        # 1. Process Intake
        res = process_patient_intake(patient, self.rules_config)
        self.assertEqual(res["risk_level"], "HIGH")

        # 2. Query History
        hist = get_patient_history("E2E-TEST-99")
        self.assertEqual(len(hist), 1)

        # 3. Check Metrics Summary
        summary = get_clinical_summary()
        self.assertGreater(summary["total_assessments"], 0)

        # 4. Export Verification
        j_cnt = export_assessments_to_json("e2e_export.json")
        c_cnt = export_assessments_to_csv("e2e_export.csv")
        self.assertGreater(j_cnt, 0)
        self.assertGreater(c_cnt, 0)

        import os
        os.remove("e2e_export.json")
        os.remove("e2e_export.csv")          


if __name__ == "__main__":
    unittest.main()