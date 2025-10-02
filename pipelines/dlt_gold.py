# Databricks notebook source
import dlt
from pyspark.sql.functions import *

# ============================================
# FACT_CLAIM - Full Refresh Materialized View
# ============================================
@dlt.table(
    name="gold.fact_claim",
    comment="Claim fact table - fully refreshed from silver curated_claims",
    table_properties={
        "pipeline.quality": "gold",
        "pipelines.autoOptimize.managed": "true"
    }
)
def fact_claim():
    """
    Full refresh of claim facts from silver layer.
    Uses batch read to ensure complete consistency.
    """
    return (
        dlt.read("silver.curated_claims")
        .select(
            "claim_id",
            "payer_id",
            "payer_name",
            "patient_id",
            "encounter_id",
            "submission_date",
            "billed_amount",
            "expected_amount",
            "net_paid_to_date",
            "adjustments_to_date",
            "current_balance",
            "has_denial_any",
            "had_277_reject",
            "last_payment_ts"
        )
    )

# COMMAND ----------

# ============================================
# FACT_DENIAL_EVENT - Streaming with APPLY CHANGES (Upsert/SCD Type 1)
# ============================================
dlt.create_streaming_table(
    name="gold.fact_denial_event",
    comment="Denial events with upsert logic - one row per unique denial event",
    table_properties={
        "pipeline.quality": "gold",
        "delta.enableChangeDataFeed": "true"
    }
)

# Prepare the source stream with event_key and enrichment
@dlt.view(
    comment="Enriched denial events with stable event_key for upserts"
)
def denial_events_enriched():
    """
    Create stable event_key and enrich with payer info from fact_claim.
    This is a streaming view that prepares data for APPLY CHANGES.
    """
    events = dlt.read_stream("silver.payments_835_events").filter("is_denial = 1")
    
    # Read fact_claim as a batch table for lookup
    claims = dlt.read("gold.fact_claim").select("claim_id", "payer_id", "payer_name")
    
    return (
        events
        .join(claims, on="claim_id", how="left")
        .withColumn(
            "event_key",
            sha2(
                concat_ws(
                    "|",
                    coalesce(col("remit_id"), lit("")),
                    coalesce(col("claim_id"), lit("")),
                    coalesce(col("posted_ts").cast("string"), lit("")),
                    coalesce(col("reason_code"), lit(""))
                ),
                256
            )
        )
        .select(
            col("event_key"),
            events["claim_id"],
            coalesce(claims["payer_id"], events["payer_id"]).alias("payer_id"),
            coalesce(claims["payer_name"], lit("Unknown")).alias("payer_name"),
            col("posted_ts").alias("event_ts"),
            col("payment_date"),
            col("remit_id"),
            col("check_or_eft_trace"),
            col("payment_amount"),
            col("adjustment_amount"),
            col("reason_code"),
            col("reason_category"),
            col("is_denial"),
            col("posted_ts").alias("_processing_timestamp")  # For sequencing
        )
    )

# Apply changes (upsert) into the target table
dlt.apply_changes(
    target="gold.fact_denial_event",
    source="denial_events_enriched",
    keys=["event_key"],  # Primary key for upsert
    sequence_by="_processing_timestamp",  # Use event timestamp for ordering
    stored_as_scd_type=1  # Type 1 (no history tracking)
)
