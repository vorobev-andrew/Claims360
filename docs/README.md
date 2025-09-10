# Claims360: Healthcare Reimbursement Analytics on the Lakehouse 

## Overview  
Hospitals face major financial risk from claim denials and delayed reimbursements.
Core claim lifecycle data is spread across siloed systems:

- 277CA acknowledgments (clearinghouse → hospital)

- 835 remittance advices (payer → hospital)

- HL7/FHIR events (EHR)

---

The Claims360 Lakehouse unifies these feeds into an end-to-end analytics and ML pipeline, connecting formerly siloed teams within a single platform.  
This enables **denial prevention, payer benchmarking, and cash flow forecasting**, improving hospitals' net  reimbursement.

---

## Architecture (Medallion)  
- Bronze → Raw ingestion with schema enforcement + checkpoints.
- Silver → Standardized, deduplicated, quarantined (expectations applied).
- Gold → De-identified KPIs, risk scores, dashboards.
- ML → Denial-risk model scored back into Gold.
- Governance → Unity Catalog security + PHI masking.

--- 

## Repo Structure

| Folder / File           | Description                                                                                 |
|--------------------------|---------------------------------------------------------------------------------------------|
| `data/`                 | Synthetic datasets (277CA, 835, HL7/FHIR, staffing)                                         |
| `notebooks/`            | PySpark notebooks: Bronze ingestion, Silver transforms, Gold aggregates, ML training        |
| `pipelines/`            | Delta Live Tables / Lakeflow SQL pipeline definitions                                       |
| `ml/`                   | Feature engineering queries, training scripts, batch scoring UDF, and model card            |
| `dashboards/`           | DBSQL dashboard queries and alert logic                                                     |
| `setup/`                | Unity Catalog setup scripts, governance grants, sample data seeding, and cluster configs    |
| `schemas/`              | Schema contracts (e.g., 277CA.json, 835.json, hl7.json)                                     |
| `tests/`                | Unit tests (pytest) and fixtures for validating transforms and expectations                 |
| `configs/`              | Environment-specific configs (dev, qa, prod) for pipelines and jobs                         |
| `docs/`                 | Documentation (data dictionary, expectations, lineage, diagrams, architecture)              |
| `.github/workflows/`    | CI/CD workflows (Python linting, SQL validation, unit tests)                                |

Project Phases (MVP)  
1. Foundations – Unity Catalog, env setup, PHI policy.
2. Synthetic Data – Generate 277CA & 835 JSON/CSV with realistic noise.
3. Bronze – Auto Loader ingestion, schema enforcement, rescue rows.
4. Silver – Deduplication, normalization, expectations + quarantine.
5. Gold – Incremental KPIs (denial rates, time-to-payment).
6. ML – One denial-risk classification model, batch scored into Gold.
7. Dashboards – DBSQL dashboard + basic alerts.

##### Note: add HL7/FHIR streaming, staffing dataset, second ML model, CI/CD

## Tech Stack
- Databricks Lakehouse (Lakeflow, Unity Catalog, DBSQL)
- Delta Lake (Auto Loader, CDF, OPTIMIZE, liquid clusering)
- MLflow (model registry, batch scoring)
- GitHub Actions (CI: linting, tests, SQL checks)

## Business Impact

By unifying **clearinghouse acknowledgments (277CA), payer remittances (835), and clinical events (HL7/FHIR)**, hospitals can:
1. Detect claim rejections earlier
2. Monitor payer denial patterns
3. Forecast reimbursement risk
4. Benchmark operational performance
