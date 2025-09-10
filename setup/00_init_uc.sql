-- Create catalog
CREATE CATALOG IF NOT EXISTS claims360_dev
COMMENT 'Development catalog for Claims360 project';

-- Schemas
CREATE SCHEMA IF NOT EXISTS claims360_dev.bronze COMMENT 'Raw/landing + minimally parsed';
CREATE SCHEMA IF NOT EXISTS claims360_dev.silver COMMENT 'Standardized, deduped, quality checked';
CREATE SCHEMA IF NOT EXISTS claims360_dev.gold COMMENT 'De-identified business-ready KPIs & aggregates';
CREATE SCHEMA IF NOT EXISTS claims360_dev.ops COMMENT 'Runtime artifacts - checkpoints, logs, temp';

-- Volumes; managed storage
CREATE VOLUME IF NOT EXISTS claims360_dev.bronze.raw COMMENT 'Raw files (landing, rescued records, checkpoints)';
CREATE VOLUME IF NOT EXISTS claims360_dev.silver.curated COMMENT 'Intermediate curated exports/checkpoints';
CREATE VOLUME IF NOT EXISTS claims360_dev.gold.publish COMMENT 'Exported analytics artifacts (csv/parquet for sharing)';
CREATE VOLUME IF NOT EXISTS claims360_dev.ops.logs COMMENT 'Runtime logs';
CREATE VOLUME IF NOT EXISTS claims360_dev.ops.checkpoints COMMENT 'Checkpoints';