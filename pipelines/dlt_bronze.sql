-- Databricks notebook source
-- EHR
CREATE OR REFRESH STREAMING TABLE bronze.ehr_claims_raw
COMMENT "Bronze Auto Loader ingest of EHR claim files (JSON)"
TBLPROPERTIES ("pipeline.quality" = "bronze")
AS
SELECT *
FROM cloud_files(
  '/Volumes/claims360_dev/bronze/raw/ehr',
  'json',
  map(
    'cloudFiles.inferColumnTypes',        'true',
    'cloudFiles.schemaLocation',          '/Volumes/claims360_dev/bronze/ingestion/_schemas/ehr',
    'cloudFiles.schemaEvolutionMode',     'addNewColumns',
    'rescuedDataColumn',                  '_rescued_data',
    'multiLine',                          'true'
  )
);

-- 277CA
CREATE OR REFRESH STREAMING TABLE bronze.ack_277ca_raw
COMMENT "Bronze Auto Loader ingest of 277CA ack files (JSON)"
TBLPROPERTIES ("pipeline.quality" = "bronze")
AS
SELECT *
FROM cloud_files(
  '/Volumes/claims360_dev/bronze/raw/ca_277',
  'json',
  map(
    'cloudFiles.inferColumnTypes',        'true',
    'cloudFiles.schemaLocation',          '/Volumes/claims360_dev/bronze/ingestion/_schemas/ca_277',
    'cloudFiles.schemaEvolutionMode',     'addNewColumns',
    'rescuedDataColumn',                  '_rescued_data',
    'multiLine',                          'true'
  )
);

-- 835
CREATE OR REFRESH STREAMING TABLE bronze.payments_835_raw
COMMENT "Bronze Auto Loader ingest of 835 remit files (JSON)"
TBLPROPERTIES ("pipeline.quality" = "bronze")
AS
SELECT *
FROM cloud_files(
  '/Volumes/claims360_dev/bronze/raw/remit_835',
  'json',
  map(
    'cloudFiles.inferColumnTypes',        'true',
    'cloudFiles.schemaLocation',          '/Volumes/claims360_dev/bronze/ingestion/_schemas/remit_835',
    'cloudFiles.schemaEvolutionMode',     'addNewColumns',
    'rescuedDataColumn',                  '_rescued_data',
    'multiLine',                          'true'
  )
);
