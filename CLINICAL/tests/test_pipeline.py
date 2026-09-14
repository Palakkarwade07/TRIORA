import sqlite3
import unittest
from engine_pipeline import process_patient_intake


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

        # 1. Assert memory result
        self.assertEqual(result["risk_level"], "HIGH")

        # 2. Assert database record
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


if __name__ == "__main__":
    unittest.main()