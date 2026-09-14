import json
import os

def evaluate_rules(patient_data, rules_list):
    """
    Evaluates patient data against clinical decision rules.
    """
    triggered_rules = []
    highest_risk = "LOW"
    referral_needed = False

    for rule in rules_list:
        match = True
        conditions = rule["conditions"]

        for key, val in conditions.items():
            # For numeric comparisons like fever_duration_days >= 7
            if key == "fever_duration_days":
                if patient_data.get(key, 0) < val:
                    match = False
                    break
            else:
                if patient_data.get(key) != val:
                    match = False
                    break

        if match:
            triggered_rules.append(rule["id"])
            if rule["referral_required"]:
                referral_needed = True
            if rule["risk_level"] == "HIGH":
                highest_risk = "HIGH"
            elif rule["risk_level"] == "MODERATE" and highest_risk != "HIGH":
                highest_risk = "MODERATE"

    return {
        "risk_level": highest_risk,
        "referral_required": referral_needed,
        "triggered_rules": triggered_rules
    }