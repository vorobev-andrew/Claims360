# Claims360: Unified Claims Management with Databricks Lakehouse  

### Theme  
Leveraging the Databricks Lakehouse platform to integrate siloed healthcare reimbursement data into a governed **medallion architecture pipeline**, providing real-time visibility and predictive insights that extend beyond individual data sources' native capabilities.  

---

## Business Need  
Healthcare billing teams face persistent challenges with **delays and denials** due to data siloes across EHR exports, clearinghouse responses, and payer remittance files. Even as EHRs improve their payer integrations and reporting and denial dashboards, key gaps remain:  

- **Limited scope**: Dashboards reflect only what the EHR ingests, not the entire claims ecosystem.  
- **Latency**: Reports refresh on a nightly basis, without support for data streaming and real-time visibility.  
- **Siloed operations**: Clearinghouse feeds, payer portals, and call center data remain disconnected.  
- **Rigid modeling**: Difficult to extend the EHR’s data model for novel KPIs or predictive use cases.  
- **Governance limitations**: Controls are clinical/operational but not built for analytics across teams or organizations.  

As a result, finance and operations teams lack the **timely, multi-source insights** needed to reduce denials, accelerate appeals, and improve margins.  

---

## Project Goals: Differentiated Value Beyond the EHR  

This project demonstrates how Databricks can extend impact beyond individual data sources by delivering a Lakehouse-based claims pipeline that is:  

1. **Integrated**  
   - Unify EHR denial/correspondence records with raw clearinghouse 277CA (acknowledgments) and 835 (remittance advice) feeds.  
   - Reconcile mismatches faster than built-in EHR logic.  

2. **Predictive**  
   - Train an MLflow model to flag high-risk claims (by payer, specialty, CPT code).  
   - Prioritize proactive interventions before claims are submitted.  

3. **Benchmark-Driven**  
   - Create Gold tables comparing denial metrics across payers and specialties.  
   - Simulate cross-org benchmarking outside EHR reports.  

4. **Operationally Aware**  
   - Correlate claim timelines with non-EHR datasets (staffing schedules, call center response times).  
   - Deliver insights such as “Friday staffing shortages → longer appeals → slower cash flow.”  

5. **Real-Time**  
   - Use Auto Loader + Delta Live Tables (DLT) streaming for near-real-time denial alerts as payer responses arrive.  
   - Close the latency gap compared to batch-refreshed Epic dashboards.  

6. **Governed & Secure**  
   - Apply Unity Catalog row/column security to mask PHI while enabling payer benchmarking.  
   - Provide an **audit-ready governance layer** that is extensible across organizations.  

---

## Technical Architecture  

The pipeline follows a **Bronze → Silver → Gold** medallion architecture:  

- **Bronze**  
  - Ingest diverse sources:  
    - Clearinghouse CSVs (277CA)  
    - Payer JSON responses (835)  
    - Data exports from the EHR  
  - Streaming ingestion with Auto Loader.  

- **Silver**  
  - Normalize schema (patient_id, claim_id, payer, denial_code, paid_amount).  
  - Apply DLT expectations for quality enforcement (valid IDs, date ranges, required fields).  

- **Gold**  
  - Curated, query-optimized tables to report on past denials:  
    - Denials by root cause and payer  
    - Time-to-payment trends
    - Likelihood of payment calculated with mlflow
  - And future trends:
    - Cash flow forecasting  
    - MLflow model predictions of denial probability  

- **Governance & Optimization**  
  - Unity Catalog for fine-grained permissions.  
  - Liquid Clustering or Z-ORDERing on payer/claim_id for faster queries.  

---

## Architecture (Mermaid)

```mermaid
flowchart TD
  %% Sources
  subgraph External_Sources["External & Operational Sources"]
    A1["EHR exports"]
    A2["Clearinghouse 277CA (CSV)"]
    A3["Payer 835 (JSON)"]
    A4["Ops data: staffing, call center, workqueues"]
  end

  %% Ingestion / Governance
  U["Unity Catalog (RBAC, masking, lineage)"]
  AL["Auto Loader (streaming ingest)"]
  DLT["Delta Live Tables (ETL + expectations)"]

  %% Medallion Layers
  subgraph Bronze["Bronze (raw, append-only)"]
    BZ["claim_events_raw (Delta)"]
  end
  subgraph Silver["Silver (cleaned, conformed)"]
    SV1["claims_enriched (Delta)"]
    SV2["denials_normalized (Delta)"]
  end
  subgraph Gold["Gold (curated, served)"]
    GD1["denial_kpis_by_payer (Delta)"]
    GD2["time_to_payment_trends (Delta)"]
    GD3["cash_flow_forecast (Delta)"]
    GD4["denial_risk_scored (Delta)"]
  end

  %% ML / Serving
  ML["MLflow model (denial risk UDF)"]
  DBSQL["Dashboards/BI (DBSQL, Power BI)"]
  ALERTS["Real-time alerts (ops channels)"]

  %% Edges
  A1 --> AL
  A2 --> AL
  A3 --> AL
  A4 --> AL
  AL --> BZ
  BZ --> DLT --> SV1
  BZ --> DLT --> SV2
  SV1 --> GD1
  SV2 --> GD1
  SV1 --> GD2
  SV1 --> GD3
  SV2 --> ML --> GD4

  %% Governance applies across layers
  U --- A1
  U --- A2
  U --- A3
  U --- A4
  U --- BZ
  U --- SV1
  U --- SV2
  U --- GD1
  U --- GD2
  U --- GD3
  U --- GD4

  %% Serving paths
  GD1 --> DBSQL
  GD2 --> DBSQL
  GD3 --> DBSQL
  GD4 --> DBSQL
  GD4 --> ALERTS
