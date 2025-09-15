# Make sure the data directories exist
dbutils.fs.mkdirs("dbfs:/Volumes/claims360_dev/bronze/raw/remit_835")
dbutils.fs.mkdirs("dbfs:/Volumes/claims360_dev/bronze/raw/ca_277")
dbutils.fs.mkdirs("dbfs:/Volumes/claims360_dev/bronze/raw/ehr")

