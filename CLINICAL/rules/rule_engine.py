def evaluate_rules(patient_data, rules):
    """Evaluates patient data against clinical rules with priority resolution and field validation."""
    triggered_rules = []
    highest_risk = "LOW"
    needs_referral = False

    # Risk precedence order
    risk_hierarchy = {"LOW": 1, "MODERATE": 2, "HIGH": 3}

    for rule in rules:
        conditions = rule.get("conditions", {})
        match = True

        # Validate conditions against patient intake data
        for key, val in conditions.items():
            if key not in patient_data or patient_data[key] != val:
                match = False
                break

        if match:
            triggered_rules.append(rule["id"])

            # Determine risk priority
            rule_risk = rule.get("risk_level", "LOW").upper()
            if risk_hierarchy.get(rule_risk, 1) > risk_hierarchy.get(
                highest_risk, 1
            ):
                highest_risk = rule_risk

            # Flag referral if any triggered rule requires it
            if rule.get("referral_required", False):
                needs_referral = True

    return {
        "risk_level": highest_risk,
        "referral_required": needs_referral,
        "triggered_rules": triggered_rules,
    }