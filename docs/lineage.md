# Claims360 Data Lineage

This document describes how data flows through the Lakehouse from ingestion (Bronze) to insights (Gold) and ML.

---

## High-Level Flow

```mermaid
flowchart TD
    L[Landing / Raw Files] --> B[Bronze Tables]
    B --> S[Silver Tables]
    S --> G[Gold Tables]
    G --> M[ML Features & Models]
    G --> D[Dashboards & Alerts]