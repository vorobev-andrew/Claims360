-- Databricks notebook source
-- First-Pass Yield (FPY) - claims paid in full first time they're submitted, no denials or rejections
-- (padded to ensure each month has a value)

CREATE OR REPLACE VIEW gold.v_first_pass_yield AS
WITH bounds AS (
  SELECT
    date_trunc('month', MIN(submission_date)) AS start_m,
    date_trunc('month', MAX(submission_date)) AS end_m
  FROM gold.fact_claim
),
months AS (
  SELECT explode(sequence(start_m, end_m, interval 1 month)) AS month
  FROM bounds
),
payers AS (
  SELECT DISTINCT payer_name FROM gold.fact_claim
),
calendar AS (
  SELECT m.month, p.payer_name
  FROM months m CROSS JOIN payers p
),
fpy AS (
  SELECT
    date_trunc('month', submission_date) AS month,
    payer_name,
    SUM(CASE WHEN current_balance <= 0
               AND has_denial_any = 0
               AND had_277_reject = 0
             THEN 1 ELSE 0 END) AS fpy_claims,
    COUNT(*) AS submitted_claims
  FROM gold.fact_claim
  GROUP BY 1, payer_name
)
SELECT
  c.month,
  c.payer_name,
  COALESCE(f.fpy_claims, 0)        AS fpy_claims,
  COALESCE(f.submitted_claims, 0)  AS submitted_claims,
  CASE
    WHEN COALESCE(f.submitted_claims, 0) = 0 THEN 0
    ELSE CAST( COALESCE(f.fpy_claims, 0) * 100.0
             / COALESCE(f.submitted_claims, 0) AS DECIMAL(18,2) )
  END AS fpy_pct
FROM calendar c
LEFT JOIN fpy f
  ON f.month = c.month AND f.payer_name = c.payer_name;

-- COMMAND ----------

-- Top Denial Categories

CREATE OR REPLACE VIEW gold.v_top_denial_categories AS
SELECT
  COALESCE(p.payer_name, 'Unknown') AS payer_name,
  COALESCE(e.reason_category, 'Unmapped') AS denial_category,
  COUNT(DISTINCT e.claim_id) AS claims_with_category,
  SUM(-1 * COALESCE(e.adjustment_amount, 0)) AS denial_amount
FROM gold.fact_denial_event e
LEFT JOIN gold.fact_claim p
  ON p.claim_id = e.claim_id
WHERE e.reason_category <> 'N/A'
GROUP BY COALESCE(p.payer_name, 'Unknown'), COALESCE(e.reason_category, 'Unmapped')
ORDER BY denial_amount DESC;

-- COMMAND ----------

-- Denial Rate by Month (padded to ensure each month has a value)

CREATE OR REPLACE VIEW gold.v_denial_rate_by_month AS
WITH bounds AS (
  SELECT
    date_trunc('month', MIN(submission_date)) AS start_m,
    date_trunc('month', MAX(submission_date)) AS end_m
  FROM gold.fact_claim
),
months AS (
  SELECT explode(sequence(start_m, end_m, interval 1 month)) AS month
  FROM bounds
),
payers AS (
  SELECT DISTINCT COALESCE(payer_name, 'Unknown') AS payer_name
  FROM gold.fact_claim
),
calendar AS (
  SELECT m.month, p.payer_name
  FROM months m CROSS JOIN payers p
),
month_claims AS (
  SELECT
    date_trunc('month', submission_date)              AS month,
    COALESCE(payer_name, 'Unknown')                   AS payer_name,
    COUNT(*)                                          AS submitted_claims,
    SUM(CASE WHEN has_denial_any = 1 THEN 1 ELSE 0 END) AS claims_with_denials
  FROM gold.fact_claim
  GROUP BY 1, 2
)
SELECT
  c.month,
  c.payer_name,
  COALESCE(mc.submitted_claims, 0)        AS submitted_claims,
  COALESCE(mc.claims_with_denials, 0)     AS claims_with_denials,
  CASE
    WHEN COALESCE(mc.submitted_claims, 0) = 0 THEN 0
    ELSE CAST(
      COALESCE(mc.claims_with_denials, 0) * 100.0
      / COALESCE(mc.submitted_claims, 0) AS DECIMAL(18,2)
    )
  END AS denial_rate_pct
FROM calendar c
LEFT JOIN month_claims mc
  ON mc.month = c.month AND mc.payer_name = c.payer_name
ORDER BY c.month, c.payer_name;
