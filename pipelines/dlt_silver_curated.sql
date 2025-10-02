-- Databricks notebook source
-- MAGIC %md
-- MAGIC **Curation logic**:  
-- MAGIC Only keep claim acknowledgements / payments if they appear in the EHR claim headers (real-world use-case)

-- COMMAND ----------

CREATE OR REFRESH MATERIALIZED VIEW silver.curated_claims
COMMENT "One row per claim with payer + simple rollups for downstream gold"
TBLPROPERTIES ("pipeline.quality" = "silver")
AS
WITH hdr AS (
  SELECT
    claim_id,
    payer_id,
    patient_id,
    encounter_id,
    submission_date,
    billed_amount,
    expected_amount
  FROM silver.claim_headers
),
pmt AS (
  SELECT
    claim_id,
    SUM(COALESCE(payment_amount, 0)) AS paid_to_date,
    SUM(COALESCE(adjustment_amount, 0)) AS adjustments_to_date,
    MAX(posted_ts) AS last_payment_ts,
    MAX(CASE WHEN is_denial = 1 THEN 1 ELSE 0 END) AS has_denial_any
  FROM silver.payments_835_events
  GROUP BY claim_id
),
ack AS (
  SELECT
    claim_id,
    MAX(CASE WHEN status_description ILIKE 'Reject%' THEN 1 ELSE 0 END) AS had_277_reject,
    MAX(status_code) AS last_ack_status_code,
    MAX(status_description) AS last_ack_status_description
  FROM silver.ack_277ca_events
  GROUP BY claim_id
)
SELECT
  h.claim_id,
  h.payer_id,
  dp.payer_name,
  dp.payer_group,
  h.patient_id,
  h.encounter_id,
  h.submission_date,
  h.billed_amount,
  h.expected_amount,
  COALESCE(p.paid_to_date, 0) AS net_paid_to_date,
  COALESCE(p.adjustments_to_date, 0) AS adjustments_to_date,
  (h.billed_amount - COALESCE(p.paid_to_date, 0) + COALESCE(p.adjustments_to_date, 0)) AS current_balance,
  COALESCE(p.has_denial_any, 0) AS has_denial_any,
  COALESCE(a.had_277_reject, 0) AS had_277_reject,
  a.last_ack_status_code,
  a.last_ack_status_description,
  p.last_payment_ts
FROM hdr h
LEFT JOIN pmt p USING (claim_id)
LEFT JOIN ack a USING (claim_id)
LEFT JOIN silver.dim_payer dp ON dp.payer_id = h.payer_id;
