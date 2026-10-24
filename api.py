from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional
from engine_pipeline import process_patient_intake, process_batch_intake
from STORAGE.db_manager import get_patient_history, get_clinical_summary
from CLINICAL.validators import PatientValidationError

app = FastAPI(
    title="TRIORA Clinical Assessment API",
    description="RESTful API for pediatric clinical intake and risk evaluation engine with Pydantic validation.",
    version="1.2.0",
)

# --- Pydantic Request Models ---
class PatientIntakeSchema(BaseModel):
    patient_id: str = Field(..., example="PAT_001", description="Unique identifier for the patient")
    age_months: int = Field(..., ge=0, example=24, description="Age of the patient in months")
    fever_duration_days: Optional[int] = Field(None, ge=0, example=3, description="Number of days the patient has had a fever")
    has_danger_signs: Optional[bool] = Field(False, example=True, description="Presence of clinical danger signs")

class BatchIntakeSchema(BaseModel):
    patients: List[PatientIntakeSchema]

# Default clinical rules configuration
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
def assess_patient(patient: PatientIntakeSchema):
    """Evaluates a single patient record using Pydantic validated data and persists to SQLite."""
    try:
        # Convert Pydantic model to standard dictionary for the engine pipeline
        result = process_patient_intake(patient.dict(), DEFAULT_RULES)
        return {"status": "success", "assessment": result}
    except PatientValidationError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/assess/batch", summary="Process Batch Patient Intake")
def assess_batch(payload: BatchIntakeSchema):
    """Processes a batch of patient records atomically within a transaction."""
    try:
        # Convert list of Pydantic models to dictionaries
        patients_list = [p.dict() for p in payload.patients]
        results = process_batch_intake(patients_list, DEFAULT_RULES)
        return {"status": "success", "processed_count": len(results), "results": results}
    except PatientValidationError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/v1/patients/{patient_id}/history", summary="Get Patient History")
def patient_history(patient_id: str):
    """Retrieves all past assessment records for a given patient ID."""
    history = get_patient_history(patient_id)
    return {"patient_id": patient_id, "history": history}


@app.get("/api/v1/summary", summary="Get Clinical Metrics Summary")
def clinical_summary():
    """Returns aggregate metrics including total patients and risk breakdowns."""
    return get_clinical_summary()