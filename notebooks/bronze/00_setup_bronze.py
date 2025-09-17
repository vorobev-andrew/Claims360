# Make sure the directories exist

paths = [
  "dbfs:/Volumes/claims360_dev/bronze/raw/remit_835",
  "dbfs:/Volumes/claims360_dev/bronze/raw/ca_277",
  "dbfs:/Volumes/claims360_dev/bronze/raw/ehr",
  "dbfs:/Volumes/claims360_dev/bronze/ingestion/_schemas/ca_277",
  "dbfs:/Volumes/claims360_dev/bronze/ingestion/_checkpoints/ca_277",
  "dbfs:/Volumes/claims360_dev/bronze/ingestion/_schemas/ehr",
  "dbfs:/Volumes/claims360_dev/bronze/ingestion/_checkpoints/ehr",
  "dbfs:/Volumes/claims360_dev/bronze/ingestion/_schemas/remit_835",
  "dbfs:/Volumes/claims360_dev/bronze/ingestion/_checkpoints/remit_835"
]

for p in paths:
  dbutils.fs.mkdirs(p)