def generate_referral_summary(red_flag_result, rule_result):
    """
    Produces the final decision summary.
    """
    if red_flag_result["is_red_flag"]:
        return {
            "status": "CRITICAL",
            "risk_level": "EMERGENCY",
            "referral_recommendation": "Immediate transfer to nearest hospital.",
            "reasons": [rf["message"] for rf in red_flag_result["triggered"]]
        }

    return {
        "status": "EVALUATED",
        "risk_level": rule_result["risk_level"],
        "referral_recommendation": "Refer to clinic for blood smear / RDT testing." if rule_result["referral_required"] else "Provide supportive care and monitor.",
        "reasons": [f"Triggered Rule: {r}" for r in rule_result["triggered_rules"]]
    }