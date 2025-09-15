-- Create catalog
CREATE CATALOG IF NOT EXISTS claims360_dev
COMMENT 'Development catalog for Claims360 project';

-- Schemas
CREATE SCHEMA IF NOT EXISTS claims360_dev.bronze COMMENT 'Raw/landing + minimally parsed';
CREATE SCHEMA IF NOT EXISTS claims360_dev.silver COMMENT 'Standardized, deduped, quality checked';
CREATE SCHEMA IF NOT EXISTS claims360_dev.gold COMMENT 'De-identified business-ready KPIs & aggregates';
CREATE SCHEMA IF NOT EXISTS claims360_dev.ops COMMENT 'Runtime artifacts - checkpoints, logs, temp';

-- External location, edit storage credential to your specifications
CREATE EXTERNAL LOCATION IF NOT EXISTS claims360_external
URL 'abfss://external-storage@claims360.dfs.core.windows.net/'
WITH (STORAGE CREDENTIAL `avo_databricks_mi`);

-- Volumes; using external storage. Point to your storage container

CREATE EXTERNAL VOLUME claims360_dev.bronze.raw
LOCATION 'abfss://external-storage@claims360.dfs.core.windows.net/claims360/bronze/raw/';
CREATE EXTERNAL VOLUME claims360_dev.silver.curated
LOCATION 'abfss://external-storage@claims360.dfs.core.windows.net/claims360/silver/curated/';
CREATE EXTERNAL VOLUME claims360_dev.gold.publish
LOCATION 'abfss://external-storage@claims360.dfs.core.windows.net/claims360/gold/publish/';
CREATE EXTERNAL VOLUME claims360_dev.ops.logs
LOCATION 'abfss://external-storage@claims360.dfs.core.windows.net/claims360/ops/logs/';
CREATE EXTERNAL VOLUME claims360_dev.ops.checkpoints
LOCATION 'abfss://external-storage@claims360.dfs.core.windows.net/claims360/ops/checkpoints/';