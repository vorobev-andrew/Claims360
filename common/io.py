import json
from pyspark.sql.types import StructType
from pyspark.sql.functions import current_timestamp, input_file_name, lit


def load_schema(path: str) -> StructType:
    """
    Load a schema from a JSON file into a Spark StructType.
    Use for static Bronze schemas checked into git.
    """
    with open(path, "r") as f:
        return StructType.fromJson(json.load(f))


def add_ingest_metadata(df, source_system: str):
    """
    Add standard Bronze ingestion metadata columns:
    - _ingest_ts: current timestamp of ingestion
    - _ingest_file: source file path
    - _source_system: logical system identifier (e.g., '277CA', '835', 'EHR')
    """
    return (
        df.withColumn("_ingest_ts", current_timestamp())
          .withColumn("_ingest_file", input_file_name())
          .withColumn("_source_system", lit(source_system))
    )