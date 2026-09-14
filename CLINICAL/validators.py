class PatientValidationError(Exception):
    """Custom exception raised when patient intake data fails schema validation."""
    pass


def validate_patient_intake(patient_data):
    """
    Validates patient data structure and data types.
    Raises PatientValidationError if required fields are missing or invalid.
    """
    if not isinstance(patient_data, dict):
        raise PatientValidationError("Intake data must be a valid JSON/dictionary object.")

    required_fields = ["patient_id", "age_months"]
    for field in required_fields:
        if field not in patient_data:
            raise PatientValidationError(f"Missing required field: '{field}'")

    if not isinstance(patient_data["patient_id"], str) or not patient_data["patient_id"].strip():
        raise PatientValidationError("Field 'patient_id' must be a non-empty string.")

    if not isinstance(patient_data["age_months"], (int, float)) or patient_data["age_months"] < 0:
        raise PatientValidationError("Field 'age_months' must be a non-negative number.")

    if "fever_duration_days" in patient_data:
        fever = patient_data["fever_duration_days"]
        if not isinstance(fever, (int, float)) or fever < 0:
            raise PatientValidationError("Field 'fever_duration_days' must be a non-negative number.")

    return True