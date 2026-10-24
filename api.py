from fastapi import FastAPI, HTTPException
import json
from engine_pipeline import process_patient_intake, process_batch_intake
from STORAGE.db_manager import get_patient_history, get_clinical_summary
from CLINICAL.validators import PatientValidationError

app = FastAPI(
    title="TRIORA Clinical Assessment API",
    description="RESTful API for pediatric clinical intake and risk evaluation engine.",
    version="1.0.0",
)

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

@app.post("/api/v1/assess", summary="Process Single Patient Intake")
def assess_patient(patient: dict):
    try:
        result = process_patient_intake(patient, DEFAULT_RULES)
        return {"status": "success", "assessment": result}
    except PatientValidationError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v1/assess/batch", summary="Process Batch Patient Intake")
def assess_batch(payload: dict):
    patients_list = payload.get("patients", [])
    if not isinstance(patients_list, list):
        raise HTTPException(status_code=400, detail="Payload must contain a 'patients' list.")
    try:
        results = process_batch_intake(patients_list, DEFAULT_RULES)
        return {"status": "success", "processed_count": len(results), "results": results}
    except PatientValidationError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v1/patients/{patient_id}/history", summary="Get Patient History")
def patient_history(patient_id: str):
    history = get_patient_history(patient_id)
    return {"patient_id": patient_id, "history": history}

@app.get("/api/v1/summary", summary="Get Clinical Metrics Summary")
def clinical_summary():
    return get_clinical_summary()