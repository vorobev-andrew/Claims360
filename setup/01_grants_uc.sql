-- Assumed workspace groups (you can create/assign in the admin console):
--   claims360_engineers
--   claims360_analysts
--   claims360_jobs

-------------------------
-- CATALOG-LEVEL GRANTS
-------------------------
GRANT USAGE ON CATALOG claims360_dev TO claims360_engineers;
GRANT USAGE ON CATALOG claims360_dev TO claims360_analysts;
GRANT USAGE ON CATALOG claims360_dev TO claims360_jobs;

------------------------
-- SCHEMA-LEVEL GRANTS
------------------------
-- Bronze: lock down to jobs + engineers (analysts should not see PHI/raw)
GRANT USAGE, SELECT, MODIFY, CREATE TABLE, CREATE VIEW, CREATE FUNCTION ON SCHEMA claims360_dev.bronze TO `claims360_engineers`;
GRANT USAGE, SELECT, MODIFY, CREATE TABLE, CREATE VIEW, CREATE FUNCTION ON SCHEMA claims360_dev.bronze TO `claims360_jobs`;

-- Silver: lock down to jobs + engineers (analysts should not see PHI)
GRANT USAGE, SELECT, MODIFY, CREATE TABLE, CREATE VIEW, CREATE FUNCTION ON SCHEMA claims360_dev.silver TO `claims360_engineers`;
GRANT USAGE, SELECT, MODIFY, CREATE TABLE, CREATE VIEW, CREATE FUNCTION ON SCHEMA claims360_dev.silver TO `claims360_jobs`;

-- Gold: broad read for analysts; jobs write; engineers build/debug
GRANT USAGE, SELECT, MODIFY, CREATE TABLE, CREATE VIEW ON SCHEMA claims360_dev.gold TO `claims360_engineers`;
GRANT USAGE, SELECT, MODIFY, CREATE TABLE, CREATE VIEW ON SCHEMA claims360_dev.gold TO `claims360_jobs`;
GRANT USAGE, SELECT ON SCHEMA claims360_dev.gold TO `claims360_analysts`;

-------------------------
-- VOLUME-LEVEL GRANTS
-------------------------
-- Volumes control file access for landing/exports/checkpoints.
GRANT READ VOLUME  ON VOLUME claims360_dev.bronze.raw     TO `claims360_engineers`;
GRANT READ VOLUME  ON VOLUME claims360_dev.bronze.raw     TO `claims360_jobs`;
GRANT WRITE VOLUME ON VOLUME claims360_dev.bronze.raw     TO `claims360_jobs`; 
GRANT READ VOLUME  ON VOLUME claims360_dev.silver.curated TO `claims360_engineers`;
GRANT READ VOLUME  ON VOLUME claims360_dev.silver.curated TO `claims360_jobs`;
GRANT WRITE VOLUME ON VOLUME claims360_dev.silver.curated TO `claims360_jobs`;
GRANT READ VOLUME  ON VOLUME claims360_dev.gold.publish   TO `claims360_engineers`;
GRANT READ VOLUME  ON VOLUME claims360_dev.gold.publish   TO `claims360_jobs`;
GRANT READ VOLUME  ON VOLUME claims360_dev.gold.publish   TO `claims360_analysts`;
GRANT WRITE VOLUME ON VOLUME claims360_dev.gold.publish   TO `claims360_jobs`;