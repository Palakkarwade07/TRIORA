-- STORAGE/schema.sql

CREATE TABLE IF NOT EXISTS patients (
    patient_id TEXT PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    age_months INTEGER NOT NULL,
    fever_duration_days INTEGER NOT NULL,
    has_danger_signs BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS assessments (
    assessment_id TEXT PRIMARY KEY,
    patient_id TEXT NOT NULL,
    assessed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    risk_level TEXT NOT NULL,
    needs_referral BOOLEAN NOT NULL,
    applied_rules TEXT NOT NULL, -- JSON array of rule IDs
    FOREIGN KEY (patient_id) REFERENCES patients (patient_id)
);