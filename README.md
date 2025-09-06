# Claims360: Unified Claims Management with Databricks Lakehouse  

### Theme  
Using the Databricks Lakehouse platform to integrate siloed healthcare reimbursement data into a governed **medallion architecture pipeline**, enabling real-time visibility and predictive insights beyond the limits of individual source systems.  

---

## Business Need  
Healthcare billing teams face persistent challenges with **delays and denials** due to siloed data across EHR exports, clearinghouse responses, and payer remittance files. Even as EHRs improve integrations and reporting, key gaps remain:  

- **Limited scope**: Dashboards reflect only what resides in the EHR, not the full claims ecosystem.  
- **Latency**: Reports refresh nightly, with no streaming capability.  
- **Disconnected operations**: Clearinghouse feeds, payer portals, and operational datasets are not unified.  
- **Rigid models**: Extending EHR schemas for new KPIs or predictive analytics is difficult.  
- **Governance constraints**: Controls are clinical/operational, not designed for enterprise analytics.  

As a result, Finance and Operations lack the **timely, multi-source insights** needed to reduce denials, accelerate appeals, and improve margins.  

---

## Project Goals: Value Beyond the EHR  

This project demonstrates how Databricks can extend impact across the claims lifecycle by delivering a Lakehouse pipeline that is:  

1. **Integrated**  
   - Combine EHR denial/correspondence records with clearinghouse 277CA (acknowledgments) and 835 (remittance advice) feeds.  
   - Parse X12 EDI to JSON/Parquet and reconcile mismatches faster than built-in EHR logic.  

2. **Predictive**  
   - Use MLflow models to:  
     - Flag claims at high risk of denial (by payer, specialty, CPT code).  
     - Estimate likelihood of payment from historical denial patterns.  
   - Enable proactive action on high-impact claims.  

3. **Benchmark-Driven**  
   - Build Gold tables for denial metrics across payers and specialties.  
   - Provide benchmarking independent of EHR reporting.  

4. **Operationally Aware**  
   - Correlate claim timelines with non-EHR data (e.g., staffing schedules).  
   - Generate insights such as: “Friday staffing shortages → longer appeals → slower cash flow.”  

5. **Real-Time**  
   - Use Auto Loader + Lakeflow Declarative Pipelines (DLT) to ingest new files in near-real-time.  
   - Close the latency gap compared to batch-refreshed dashboards.  

6. **Governed & Secure**  
   - Apply Unity Catalog policies and dynamic views to mask PHI while enabling analytics.  
   - Maintain **separate schemas for Bronze, Silver, and Gold** layers with audit-ready lineage.  

---

## Technical Architecture  

### Data Sources  
- Epic Caboodle exports (batch)  
- Epic HL7 exports (streaming)  
- Clearinghouse 277CA/835 files (X12 → JSON/Parquet)  
- Operational datasets (e.g., staffing schedules)  

---

### Ingestion & Governance  
- **Auto Loader** ingests structured and semi-structured data with schema evolution and checkpointing.  
- **Unity Catalog** enforces access control, lineage, and governance across layers.  
- **Lakeflow Declarative Pipelines / DLT** orchestrate ETL, applying expectations and routing invalid records to quarantine tables.  

---

### Medallion Layers  

- **Bronze (raw)**  
  - `claim_events_raw` — unprocessed claim and denial events.  

- **Silver (clean/conformed)**  
  - `claims_enriched` — standardized and deduplicated claims (idempotent merges with `claim_id` + `event_ts`).  
  - `denials_normalized` — normalized denial events with CDC handling.  
  - Quarantine tables capture failed quality checks.  

- **Gold (curated/aggregated)**  
  - `denial_kpis_by_payer` — payer-level KPIs.  
  - `time_to_payment_trends` — payment timeliness metrics.  
  - `cash_flow_forecast` — forecasting cash flow.  
  - `denial_lop` — likelihood of payment (MLflow).  
  - `denial_risk_scored` — risk of denial (MLflow).  
  - Optimized with **Liquid Clustering** on payer/claim_id for query performance.  

---

### Machine Learning & Reporting  
- **MLflow + Unity Catalog Model Registry** — train, version, and serve models for denial risk and payment likelihood.  
- **Model Serving or batch UDF scoring** to apply predictions in Gold.  
- **Dashboards** (DBSQL, Power BI) for KPI tracking, trends, and forecasts.  
- **Real-Time Alerts** triggered by high-risk claims from risk-scored tables.  

---

### Data Flow  
1. External sources → Cloud storage → Auto Loader → **Bronze**.  
2. Bronze → Cleaning, deduplication, expectations → **Silver** (with quarantine).  
3. Silver → Incremental upserts via CDF → **Gold** (KPIs, forecasts, risk scores).  
4. Gold + ML outputs → Dashboards and Alerts.  
5. **Unity Catalog** governs all layers with schema separation and PHI masking.  
