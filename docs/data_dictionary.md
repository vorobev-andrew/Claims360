# Claims360 Data Dictionary

This document defines the data contracts for synthetic datasets used in the Claims360 project.  
Schemas are modeled on real-world healthcare reimbursement data, simplified for clarity.

---

## Internal vs. External Data Sources

The project unifies **internal provider exports** and **external payer/clearinghouse feeds** to create a complete claim lifecycle:

- **Internal (EHR batch exports)** → captures the provider’s *internal truth*: expected reimbursement, workqueue status, encounter context.  
- **External (277CA acknowledgments, 835 remittances)** → capture the *external reality*: clearinghouse/payer acceptance, adjudication, denials, and payments.  

By reconciling these perspectives, the Lakehouse surfaces mismatches, identifies process gaps, and enables predictive denial prevention.

---

## EHR Batch Claim Exports
#### Exported from the hospital/provider’s EHR.  
*Meaning*: Provides the provider’s internal view of a claim’s lifecycle.

| Field             | Type      | Description                                                | Example        |
|-------------------|-----------|------------------------------------------------------------|----------------|
| claim_id          | string    | Unique claim identifier within EHR                         | CLM12345       |
| patient_id        | string    | De-identified patient ID                                   | PT001          |
| encounter_id      | string    | Encounter/visit ID tied to the claim                       | ENC98765       |
| payer_id          | string    | Identifier for expected payer                              | PAYER001       |
| cpt               | string    | CPT/Procedure code                                         | 99213          |
| billed_amt        | decimal   | Amount billed to payer                                     | 150.00         |
| expected_amt      | decimal   | Expected reimbursement per contract                        | 120.00         |
| workqueue_status  | string    | Internal workflow status (Submitted, In WQ, Resubmitted)   | Submitted      |
| as_of_date        | date      | Snapshot date of export                                    | 2024-04-12     |
| source_file_id    | string    | Name/ID of source file ingested                            | ehr_001.csv    |

---

## 277CA — Claim Acknowledgment
#### Transmitted from Clearinghouse → hospital/provider.  
*Meaning*: Confirms whether the payer/clearinghouse received and accepted a claim.

| Field           | Type      | Description                                        | Example       |
|-----------------|-----------|----------------------------------------------------|---------------|
| interchange_id  | string    | File-level interchange control number              | INTCHG12345   |
| claim_id        | string    | Unique claim identifier                            | CLM12345      |
| payer_id        | string    | Identifier for payer                               | PAYER001      |
| status_code     | string    | Status of claim (A=accepted, R=rejected, etc.)     | A             |
| status_desc     | string    | Human-readable description of status               | Accepted      |
| event_ts        | timestamp | Timestamp of status event (UTC)                    | 2024-04-12T08:30:00 |
| source_file_id  | string    | Name/ID of source file ingested                    | 277ca_001.json |

---

## 835 — Electronic Remittance Advice (ERA)
#### Transmitted from Payer → hospital/provider.  
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
| source_file_id | string    | Name/ID of source file ingested                    | 835_001.json  |