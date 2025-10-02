-- Databricks notebook source
-- MAGIC %md
-- MAGIC
-- MAGIC # Claims360 – One-Click Environment Init
-- MAGIC
-- MAGIC Run this notebook to initialize the project.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Prerequisites
-- MAGIC - Workspace admin has granted you permissions on your `CATALOG` (you can adjust the name below).
-- MAGIC - You have set up a cluster capable of running notebooks.

-- COMMAND ----------

-- MAGIC %md
-- MAGIC
-- MAGIC ## 1) Unity Catalog objects (catalog, schemas, volumes)

-- COMMAND ----------

-- Catalog & Schemas ----------------------------------------------------------
CREATE CATALOG IF NOT EXISTS claims360_dev
  COMMENT 'Development catalog for Claims360 project';
USE CATALOG claims360_dev;

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

-- Volumes used by Auto Loader ------------------------------------------------
-- Raw landing area for source files
CREATE VOLUME IF NOT EXISTS bronze.raw;

-- For Auto Loader schema checkpointing
CREATE VOLUME IF NOT EXISTS bronze.ingestion;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Bronze layer setup

-- COMMAND ----------

-- MAGIC %python
-- MAGIC
-- MAGIC # Ensure the "raw" subfolders exist
-- MAGIC
-- MAGIC paths = [
-- MAGIC   "dbfs:/Volumes/claims360_dev/bronze/raw/remit_835",
-- MAGIC   "dbfs:/Volumes/claims360_dev/bronze/raw/ca_277",
-- MAGIC   "dbfs:/Volumes/claims360_dev/bronze/raw/ehr"
-- MAGIC ]
-- MAGIC
-- MAGIC for p in paths:
-- MAGIC
-- MAGIC   dbutils.fs.mkdirs(p)

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Silver layer setup

-- COMMAND ----------

-- Map denial reason codes to reason categories, whether they are a denial or not

CREATE TABLE IF NOT EXISTS silver.dim_denial_reason_map (
  code_type       STRING,          -- 'CARC' or 'RARC'
  code            STRING,          -- e.g. 'CO45'
  reason_category STRING,          -- normalized bucket
  is_denial       BOOLEAN,         -- true if this should count as a denial
  notes           STRING
);

-- - Count CO29 (Timely Filing) and PI* clinical/policy edits as denials.
-- - Treat CO45/CO97/OA23/PR1 as non-denial adjustments (common practice).
-- - Set family catch-alls to false to avoid overcounting; refine over time.

INSERT OVERWRITE TABLE silver.dim_denial_reason_map VALUES
-- Adjustments (not denials)
('CARC','CO45','Pricing/Contractual',      false, 'Contractual reduction; fee schedule/maximum'),
('CARC','CO97','Bundled/Included',         false, 'Included in allowance for another service'),
('CARC','OA23','Coordination of Benefits', false, 'Impact of prior payer adjudication'),
('CARC','PR1', 'Patient Responsibility',   false, 'Patient deductible'),

-- True denials
('CARC','CO29','Timely Filing',            true,  'Time limit for filing expired'),
('CARC','PI204','Policy/Clinical Edit',    true,  'Service included in another procedure'),

-- Family catch-alls 
('CARC','CO',   'Contractual/Other',       false, 'Other CO family (default false)'),
('CARC','PR',   'Patient Responsibility',  false, 'Other PR family (default false)'),
('CARC','PI',   'Policy/Clinical Edit',    true,  'Other PI family (often denial edits; default true is acceptable for demo)'),

('CARC','OA',   'Other Adjustment',        false, 'Other OA family (default false)');

-- COMMAND ----------

-- Map claim acknowledgement description to status code
CREATE TABLE IF NOT EXISTS silver.dim_ack_status (
  status_description  STRING,  
  status_code         STRING
);

INSERT OVERWRITE TABLE silver.dim_ack_status VALUES
('Accepted with Note', 'A1'),
('Accepted',           'A2'),
('Rejected',           'A7');

-- COMMAND ----------

-- Map payer id to name and type
CREATE TABLE IF NOT EXISTS silver.dim_payer (
  payer_id   STRING NOT NULL,
  payer_name STRING NOT NULL,
  payer_type STRING NOT NULL
);

INSERT OVERWRITE TABLE silver.dim_payer VALUES
  ('PAYER001', 'Aetna',            'Commercial'),
  ('PAYER002', 'Anthem BCBS',      'Commercial'),
  ('PAYER003', 'Cigna',            'Commercial'),
  ('PAYER004', 'UnitedHealthcare', 'Commercial'),
  ('PAYER005', 'Humana',           'Commercial'),
  ('PAYER006', 'Kaiser',           'Commercial'),
  ('PAYER007', 'Medicare',         'Government'),
  ('PAYER008', 'Medicaid',         'Government');

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Done
-- MAGIC
-- MAGIC If everything ran without errors, your catalog, schemas, volumes, and baseline data structures for bronze/silver/gold are ready.
-- MAGIC
-- MAGIC - To re-run idempotently, just run all cells again.
-- MAGIC - To target a different catalog, change `DEFAULT_CATALOG` at the top and re-run.
