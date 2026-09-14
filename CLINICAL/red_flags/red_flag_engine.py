def check_red_flags(patient_data, red_flag_rules):
    """
    Checks if any clinical red flag is triggered.
    """
    triggered_red_flags = []

    for rf in red_flag_rules:
        field = rf["field"]
        target_val = rf["value"]
        
        # Check if the patient data matches the red flag condition
        if patient_data.get(field) == target_val:
            triggered_red_flags.append({
                "id": rf["id"],
                "message": rf["message"]
            })

    if triggered_red_flags:
        return {
            "is_red_flag": True,
            "action": "EMERGENCY_REFERRAL",
            "triggered": triggered_red_flags
        }

    return {
        "is_red_flag": False,
        "action": "NONE",
        "triggered": []
    }