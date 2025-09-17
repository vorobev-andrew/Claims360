-- Create catalog
CREATE CATALOG IF NOT EXISTS claims360_dev
COMMENT 'Development catalog for Claims360 project';
USE CATALOG claims360_dev;

-- Schemas
CREATE SCHEMA IF NOT EXISTS claims360_dev.bronze COMMENT 'Raw/landing + minimally parsed';
CREATE SCHEMA IF NOT EXISTS claims360_dev.silver COMMENT 'Standardized, deduped, quality checked';
CREATE SCHEMA IF NOT EXISTS claims360_dev.gold COMMENT 'De-identified business-ready KPIs & aggregates';
CREATE SCHEMA IF NOT EXISTS claims360_dev.ops COMMENT 'Runtime artifacts - checkpoints, logs, temp';

-- Volumes
CREATE VOLUME IF NOT EXISTS claims360_dev.bronze.raw;
CREATE VOLUME IF NOT EXISTS claims360_dev.bronze.ingestion;
CREATE VOLUME IF NOT EXISTS claims360_dev.silver.curated;
CREATE VOLUME IF NOT EXISTS claims360_dev.gold.publish;