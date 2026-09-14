# Load JSON rules
import json
import os
from red_flags.red_flag_engine import check_red_flags
from rules.rule_engine import evaluate_rules
from referral.referral_engine import generate_referral_summary

# Locate rules.json relative to this script
script_dir = os.path.dirname(os.path.abspath(__file__))
json_path = os.path.join(script_dir, "rules", "rules.json")

# Load JSON rules
with open(json_path, "r") as f:
    config = json.load(f)

# Example patient: High malaria risk area with fever
patient_sample = {
    "fever": True,
    "fever_duration_days": 2,
    "high_malaria_risk_area": True,
    "unconscious_or_lethargic": False,
    "unable_to_drink": False,
    "repeated_vomiting": False
}

red_flags = check_red_flags(patient_sample, config["red_flags"])
rules = evaluate_rules(patient_sample, config["rules"])
final_output = generate_referral_summary(red_flags, rules)

print(json.dumps(final_output, indent=2))