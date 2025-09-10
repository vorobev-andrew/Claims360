# Claims360 Data Quality Expectations

This document defines the data quality rules enforced during ingestion and transformation.  
Rules are applied in the **Silver layer** using pipeline expectations.  
Failures are quarantined, not dropped.

---

## 277CA Expectations

- **Critical**
  - `claim_id` must not be null
  - `event_ts` must not be null and within ±365 days of current date
- **Warning**
  - `status_code` must be in {A, R, P}; unknown codes flagged
  - Duplicate `(claim_id, event_ts, source_file_id)` flagged

---

## 835 Expectations

- **Critical**
  - `claim_id`, `payer_id` must not be null
  - `paid_amt >= 0` and `billed_amt >= paid_amt`
- **Warning**
  - `denial_code` in known CARC list; unknown → flagged
  - `remark_code` in known RARC list; unknown → flagged

---

## HL7/FHIR Expectations

- **Critical**
  - `patient_id`, `encounter_id` must not be null
- **Warning**
  - `proc_code` must exist in CPT code set
  - `diagnosis` must exist in ICD-10 list

---

## Quarantine Strategy

- Invalid rows routed to:
  - `silver._quarantine_claims`
  - `silver._quarantine_denials`
- Retained indefinitely for audit and debugging