-- Databricks notebook source
-- EHR claims (headers) -------------------------------------------------------

-- Staging stream off bronze
CREATE OR REFRESH STREAMING TABLE silver.stg_claim_headers
COMMENT "Streaming staging for EHR claim headers"
AS
SELECT
  UPPER(TRIM(claim_id))                   AS claim_id,
  UPPER(TRIM(payer_id))                   AS payer_id,
  UPPER(TRIM(patient_id))                 AS patient_id,
  UPPER(TRIM(encounter_id))               AS encounter_id,
  TRY_CAST(as_of_date AS DATE)            AS submission_date,
  TRY_CAST(as_of_date AS TIMESTAMP)       AS submission_ts,
  TRY_CAST(billed_amt   AS DECIMAL(18,2)) AS billed_amount,
  TRY_CAST(expected_amt AS DECIMAL(18,2)) AS expected_amount,
  current_timestamp()                     AS _ingest_ts,
  'EHR'                                   AS _source_system
FROM STREAM(bronze.ehr_claims_raw)
WHERE claim_id IS NOT NULL
  AND payer_id IS NOT NULL
  AND patient_id IS NOT NULL
  AND TRY_CAST(as_of_date AS DATE) IS NOT NULL
  AND TRY_CAST(billed_amt AS DECIMAL(18,2)) IS NOT NULL;

-- Latest-snapshot table (one row per claim_id)
CREATE OR REFRESH STREAMING TABLE silver.claim_headers
COMMENT "EHR claim headers; one row per claim_id, Type-1 latest"
TBLPROPERTIES (pipeline.quality = "silver");

APPLY CHANGES INTO silver.claim_headers
FROM STREAM(silver.stg_claim_headers)
KEYS (claim_id)
SEQUENCE BY submission_date
COLUMNS * EXCEPT (_source_system)
STORED AS SCD TYPE 1;

-- EHR quarantine
CREATE OR REFRESH STREAMING TABLE silver.claim_headers_rejects
COMMENT "Quarantined EHR rows failing minimal constraints"
AS
SELECT *
FROM STREAM(bronze.ehr_claims_raw) b
WHERE b.claim_id IS NULL
   OR b.payer_id IS NULL
   OR TRY_CAST(b.as_of_date AS DATE) IS NULL
   OR TRY_CAST(b.billed_amt AS DECIMAL(18,2)) IS NULL
   OR b.patient_id IS NULL;

-- COMMAND ----------

-- 277CA acknowledgements -----------------------------------------------------

-- Staging stream
CREATE OR REFRESH STREAMING TABLE silver.stg_ack_277ca_events
COMMENT "Streaming staging for 277CA acknowledgements"
AS
WITH src AS (
  SELECT
    UPPER(TRIM(ack_id))               AS ack_id,
    UPPER(TRIM(claim_id))             AS claim_id,
    UPPER(TRIM(payer_id))             AS payer_id,
    UPPER(TRIM(patient_id))           AS patient_id,
    TRY_CAST(event_time AS TIMESTAMP) AS event_ts,
    TRIM(status_description)          AS status_description_raw,
    UPPER(TRIM(status_code))          AS status_code_raw,
    current_timestamp()               AS _ingest_ts,
    '277CA'                           AS _source_system
  FROM STREAM(bronze.ack_277ca_raw)
)
SELECT
  s.ack_id, s.claim_id, s.payer_id, s.patient_id, s.event_ts,
  COALESCE(s.status_description_raw, d_by_code.status_description, 'N/A') AS status_description,
  COALESCE(s.status_code_raw,        d_by_desc.status_code,       'N/A') AS status_code,
  s._ingest_ts, s._source_system
FROM src s
LEFT JOIN silver.dim_ack_status d_by_code
  ON s.status_code_raw = d_by_code.status_code
LEFT JOIN silver.dim_ack_status d_by_desc
  ON UPPER(s.status_description_raw) = UPPER(d_by_desc.status_description)
WHERE s.ack_id   IS NOT NULL
  AND s.claim_id IS NOT NULL
  AND s.payer_id IS NOT NULL
  AND s.event_ts IS NOT NULL
  AND s.patient_id IS NOT NULL;

-- Latest-acknowledgement per claim_id
CREATE OR REFRESH STREAMING TABLE silver.ack_277ca_events
COMMENT "277CA ack events; latest per claim (Type-1)";

APPLY CHANGES INTO silver.ack_277ca_events
FROM STREAM(silver.stg_ack_277ca_events)
KEYS (claim_id)
SEQUENCE BY event_ts
COLUMNS * EXCEPT (_source_system)
STORED AS SCD TYPE 1;

-- Quarantine for bad 277 rows -----------------------------------------------
CREATE OR REFRESH STREAMING TABLE silver.ack_277ca_rejects AS
SELECT *
FROM STREAM(bronze.ack_277ca_raw)
WHERE ack_id   IS NULL
   OR claim_id IS NULL
   OR payer_id IS NULL
   OR TRY_CAST(event_time AS TIMESTAMP) IS NULL
   OR patient_id IS NULL;

-- COMMAND ----------

-- 835 payments (line-level events) ------------------------------------------
CREATE OR REFRESH STREAMING TABLE silver.stg_payments_835_events
COMMENT "Streaming staging for 835 payments + denial mapping"
AS
WITH src AS (
  SELECT
    UPPER(TRIM(remit_id))                        AS remit_id,
    UPPER(TRIM(claim_id))                        AS claim_id,
    UPPER(TRIM(payer_id))                        AS payer_id,
    TRY_CAST(payment_date  AS DATE)              AS payment_date,
    TRY_CAST(payment_date  AS TIMESTAMP)         AS posted_ts,
    TRY_CAST(service_date  AS DATE)              AS service_date,
    TRY_CAST(payment_amount    AS DECIMAL(18,2)) AS payment_amount,
    TRY_CAST(adjustment_amount AS DECIMAL(18,2)) AS adjustment_amount,
    UPPER(TRIM(adjustment_reason_code))          AS reason_code,
    UPPER(TRIM(check_or_eft_trace))              AS check_or_eft_trace,
    current_timestamp()                          AS _ingest_ts,
    '835'                                        AS _source_system
  FROM STREAM(bronze.payments_835_raw)
)
SELECT
  f.*,
  CASE WHEN f.reason_code IS NULL THEN 'N/A' ELSE m.reason_category END       AS reason_category,
  CASE WHEN f.reason_code IS NULL THEN 0     ELSE COALESCE(CAST(m.is_denial AS INT), 0) END AS is_denial,
  m.code_type AS code_type
FROM src f
LEFT JOIN silver.dim_denial_reason_map m
  ON m.code_type = 'CARC'
 AND m.code      = f.reason_code
WHERE remit_id IS NOT NULL
  AND claim_id IS NOT NULL
  AND payer_id IS NOT NULL
  AND payment_date IS NOT NULL
  AND service_date IS NOT NULL;


CREATE OR REFRESH STREAMING TABLE silver.payments_835_events
COMMENT "835 events (latest per (remit_id, claim_id)) with denial flags";

APPLY CHANGES INTO silver.payments_835_events
FROM STREAM(silver.stg_payments_835_events)
KEYS (remit_id, claim_id)
SEQUENCE BY posted_ts
COLUMNS * EXCEPT (_source_system)
STORED AS SCD TYPE 1;


CREATE OR REFRESH STREAMING TABLE silver.payments_835_rejects
COMMENT "835 bad rows"
AS
SELECT *
FROM STREAM(bronze.payments_835_raw)
WHERE remit_id IS NULL
  OR claim_id IS NULL
  OR payer_id IS NULL
  OR TRY_CAST(payment_date AS DATE) IS NULL
  OR service_date IS NULL;
