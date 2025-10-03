-- Create and use claims360_dev catalog
CREATE CATALOG IF NOT EXISTS claims360_dev;
USE CATALOG claims360_dev;

-- Schemas
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

-- Engineers: manage bronze & silver, read gold
GRANT USAGE ON CATALOG claims360_dev TO r_engineer;
GRANT USAGE ON SCHEMA bronze TO r_engineer;
GRANT SELECT, MODIFY, CREATE TABLE ON SCHEMA bronze TO r_engineer;
GRANT USAGE ON SCHEMA silver TO r_engineer;
GRANT SELECT, MODIFY, CREATE TABLE ON SCHEMA silver TO r_engineer;
GRANT USAGE ON SCHEMA gold TO r_engineer;
GRANT SELECT ON SCHEMA gold TO r_engineer;


-- Analysts: read silver & gold
GRANT USAGE ON CATALOG claims360_dev TO r_analyst;
GRANT USAGE ON SCHEMA silver TO r_analyst;
GRANT SELECT ON SCHEMA silver TO r_analyst;
GRANT USAGE ON SCHEMA gold   TO r_analyst;
GRANT SELECT ON SCHEMA gold   TO r_analyst;

-- Executives: read-only access to gold layer
GRANT USAGE ON CATALOG claims360_dev TO r_executive;
GRANT USAGE ON SCHEMA gold TO r_executive;
GRANT SELECT ON SCHEMA gold TO r_executive;