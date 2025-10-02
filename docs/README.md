# Claims360 – Real-time Billing & Denials Analytics

> **Business purpose:** In revenue cycle, one of the hardest challenges is reconciling multiple sources of truth — EHR submissions, payer acknowledgements, and remittance denials — across systems that don’t naturally talk to each other. This project shows how a **Lakehouse pipeline** unifies those data streams into a single view of claim health, enabling operations and analytics teams to cut through silos and directly measure payer performance.

---

## Why this matters

In my role as a **Technical Solutions Engineer at a major EHR company (revenue cycle apps)**, I’ve seen how health systems struggle with fragmented data:
- Claim submissions live in the EHR,
- Payer acknowledgements come back from clearinghouses,
- Payment and denial details arrive separately in 835s.

Analysts want **first-pass yield, denial rates, days to first payment, and $ at risk**, but they waste hours reconciling exports instead of answering business questions.  

The **business need** is clear:  
➡️ **Store all relevant claim lifecycle data in one unified platform**.  
➡️ **Support both batch (EHR drops) and streaming (payer feeds)**.  
➡️ **Empower engineers, analysts, and ops** to collaborate on the *same platform* with governed access.  

This is exactly where the **Lakehouse** comes in.

---

## The Lakehouse Solution

This project builds a **Delta Live Tables (DLT) pipeline** that mirrors the realities of healthcare billing:

- **Bronze**: Raw streaming ingestion of claims, 277CA, and 835 files via Auto Loader.  
- **Silver**: Cleaned and curated tables with bad-row quarantine (so ops can inspect rejects instead of silently losing them).  
- **Curated silver claim (materialized view)**: One row per claim with payer mappings, balances, and flags — the “single source of truth” analysts and leadership need.  
- **Gold facts**:
  - `fact_claim`: Full view of claim balances and statuses, refreshed in sync with silver.  
  - `fact_denial_event`: Streaming, upserted denials with stable event keys (so we don’t double-count adjustments).  

### Key design choices

- **Materialized view in silver**: Ensures cross-stream joins (EHR + 277 + 835) stay performant and reliable for downstream analytics.  
- **Streaming with `APPLY CHANGES` in gold**: Captures denial events exactly once and continuously updates fact tables without batch rebuilds.  
- **Reject tables kept**: Transparency — analysts and engineers can inspect “bad rows” (missing claim IDs, bad amounts) instead of discarding them.  

---

## What leaders & analysts get

- **KPIs**: Total claims, first-pass yield %, denial rate %, adjustment $ impact.  
- **Trends**: FPY% and denial% per payer over time.  
- **Breakdowns**: Billed vs paid vs balance, avg days to first payment, top denial categories.  
- **Governed access**: Engineers prep bronze/silver; analysts self-serve in gold.  

---

## Why it’s different from EHR dashboards

EHR dashboards refresh overnight and silo claims vs denials. With the Lakehouse:  
- We see payer trends **in near-real-time**.  
- We unify claims + acks + denials in a **single SQL model**.  
- We add governance + role-based access, while still letting analysts create their own dashboards on gold data.  

---

This pipeline shows how **the Lakehouse solves a real business problem in healthcare revenue cycle**: faster cash, fewer denials, and unified collaboration across technical and business teams.