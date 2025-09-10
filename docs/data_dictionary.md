# Claims360 Data Dictionary

This document defines the data contracts for synthetic datasets used in the Claims360 project.  
Each dataset schema is based on real-world healthcare EDI and EHR exports but simplified for clarity.

---

## 277CA — Claim Acknowledgment
#### This information is transmitted from the Clearinghouse -> hospital/provider.
*Meaning*: Tells you whether payer/clearinghouse received and accepted a claim.

| Field           | Type      | Description                                        | Example       |
|-----------------|-----------|----------------------------------------------------|---------------|
| interchange_id  | string    | File-level interchange control number              | INTCHG12345   |
| claim_id        | string    | Unique claim identifier                            | CLM12345      |
| payer_id        | string    | Identifier for payer                               | PAYER001      |
| status_code     | string    | Status of claim (A=accepted, R=rejected, etc.)     | A             |
| status_desc     | string    | Human-readable description of status               | Accepted      |
| event_ts        | timestamp | Timestamp of status event (UTC)                    | 2024-04-12T08:30:00 |
| source_file_id  | string    | Name/ID of source file ingested                    | file_001.json |

---

## 835 — Electronic Remittance Advice (ERA)
#### This information is transmitted from payer -> hospital/provider.
*Meaning*: Explains how a claim was processed; paid / denied / adjusted.


| Field          | Type      | Description                                        | Example       |
|----------------|-----------|----------------------------------------------------|---------------|
| claim_id       | string    | Unique claim identifier                            | CLM12345      |
| payer_id       | string    | Identifier for payer                               | PAYER001      |
| cpt            | string    | CPT/Procedure code                                 | 99213         |
| billed_amt     | decimal   | Original billed amount                             | 150.00        |
| allowed_amt    | decimal   | Allowed amount per contract                        | 120.00        |
| paid_amt       | decimal   | Actual paid amount                                 | 118.00        |
| denial_code    | string    | CARC denial code if denied                         | 97            |
| remark_code    | string    | RARC remark code                                   | N290          |
| remit_ts       | timestamp | Remittance timestamp (UTC)                         | 2024-04-15T14:45:00 |
| source_file_id | string    | Name/ID of source file ingested                    | file_002.json |

---

## HL7/FHIR Events
#### This information is transmitted from the EHR source.
*Meaning*: clinical and encounter-level events helping link the clinical story to the financial story.

| Field         | Type      | Description                          | Example       |
|---------------|-----------|--------------------------------------|---------------|
| patient_id    | string    | Unique patient identifier             | PT001         |
| encounter_id  | string    | Hospital encounter/visit ID           | ENC98765      |
| claim_id      | string    | Current linked claim ID                       | CLM12345      |
| diagnosis     | string    | ICD-10 diagnosis code                 | E11.9         |
| proc_code     | string    | CPT/Procedure code                    | 99213         |
| event_ts      | timestamp | Event timestamp (UTC)                 | 2024-04-12T10:00:00 |
| source_file_id| string    | Name/ID of source file ingested       | hl7_001.json  |