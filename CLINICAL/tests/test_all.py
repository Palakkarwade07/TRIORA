import json
import os
import sys

# Ensure parent directory is in Python path for imports
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from red_flags.red_flag_engine import check_red_flags
from rules.rule_engine import evaluate_rules
from referral.referral_engine import generate_referral_summary

def run_test_suite():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    rules_path = os.path.join(base_dir, "..", "rules", "rules.json")

    with open(rules_path, "r") as f:
        config = json.load(f)

    test_files = ["normal_case.json", "high_risk_case.json", "red_flag_case.json"]

    print("--- RUNNING CLINICAL ENGINE SUITE ---")
    for test_file in test_files:
        file_path = os.path.join(base_dir, test_file)
        if not os.path.exists(file_path):
            print(f"[SKIP] File not found: {test_file}")
            continue

        with open(file_path, "r") as tf:
            patient_data = json.load(tf)

        red_flags = check_red_flags(patient_data, config["red_flags"])
        rules = evaluate_rules(patient_data, config["rules"])
        summary = generate_referral_summary(red_flags, rules)

        print(f"\nTest: {test_file}")
        print(f"Status: {summary['status']} | Risk Level: {summary['risk_level']}")
        print(f"Recommendation: {summary['referral_recommendation']}")

if __name__ == "__main__":
    run_test_suite()