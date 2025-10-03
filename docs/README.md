# Claims360 – Real-Time Revenue Cycle Analytics

> **Unifying healthcare billing data into a single source of truth**

A production-grade Lakehouse analytics pipeline that transforms fragmented revenue cycle data into actionable insights. By consolidating **EHR submissions**, **payer acknowledgements**, and **remittance denials** into a unified governed platform, Claims360 delivers the real-time visibility that health systems desperately need but rarely achieve.

Built with **Databricks Lakeflow Declarative Pipelines**, **Auto Loader**, **Delta Lake**, and **Unity Catalog**, this pipeline enables healthcare organizations to monitor critical KPIs—first-pass yield, denial rates, revenue leakage, and payment velocity—with unprecedented speed and accuracy.

**The impact:** Accelerated reimbursement cycles, reduced denial rates, and data-driven payer negotiations accessible to engineers, analysts, and executives through a single governed platform.

---

## 🎯 The Business Problem

Healthcare revenue cycle management faces a fundamental data fragmentation challenge. Critical billing information lives in disconnected silos:

- **EHR systems** house clinical information and claim submission information
- **Clearinghouses** return claim acknowledgement files (277CA) separately  
- **Payers** send denial and payment details via remittance files (835)

Each system maintains its own version of truth. The result? Finance teams spend days reconciling spreadsheet exports. Analysts can't answer basic questions like "Which payer denies claims most frequently?" without manual data wrangling. Executives make strategic decisions on yesterday's data—or last week's.

### What health systems actually need:

✅ **Unified view** of the complete claim lifecycle  
✅ **Real-time insights** that don't wait for overnight batch processes  
✅ **Governed collaboration** enabling technical and business teams to work from the same data  
✅ **Streaming + batch** capability to handle both scheduled EHR drops and continuous payer feeds  

This is precisely the problem the **Lakehouse architecture** was designed to solve.

---

## 💡 Why This Matters

As a **Technical Solutions Engineer** specializing in revenue cycle applications at Epic, I've witnessed firsthand how data fragmentation cripples decision-making. Health systems lose millions annually to preventable denials, yet they can't identify patterns because their data infrastructure wasn't built for cross-system analytics.

Traditional approaches force uncomfortable tradeoffs:
- Data warehouses require rigid ETL pipelines that can't adapt to schema changes
- Data lakes become ungoverned swamps where business users can't find reliable data
- Real-time streaming and historical batch analysis live in separate worlds

The Lakehouse eliminates these compromises, enabling the kind of agile, governed analytics that revenue cycle teams need to compete in value-based care models.

---

## 🏗️ The Solution: Medallion Architecture within the Lakehouse

Claims360 implements a **Lakeflow Declarative Pipeline (DLT)** that orchestrates the complete data lifecycle through the medallion architecture:

![Claims360 Pipeline Architecture](./claims360_data_flow.png)  
<sub>*Architecture diagram source: [claims360_data_flow.mmd](./claims360_data_flow.mmd)*</sub>

**🥉 Bronze (Streaming Ingestion)**
- **Auto Loader** continuously ingests raw EHR, 277CA, and 835 JSON files
- Schema evolution handled automatically—no pipeline breaks when payers add fields
- All source data preserved in Delta format with full lineage

**🥈 Silver (Cleansed & Enriched)**
- Standardized, validated tables with comprehensive data quality checks
- **Quarantine pattern**: Bad rows aren't silently dropped—they're isolated for investigation
- Business-critical transformations applied: date parsing, amount normalization, status standardization
- **Curated Silver (materialized view)**: One row per claim, enriched with payer mappings, financial balances, and outcome flags

**🥇 Gold (Analytics-Ready Facts)**
- `fact_claim`: Complete claim lifecycle view, consistently rebuilt from curated silver
- `fact_denial_event`: Streaming upsert pattern using `APPLY CHANGES INTO` for exactly-once denial processing
- Pre-aggregated KPIs optimized for dashboard consumption

### 🎨 Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| **Materialized view in Silver** | Persists complex joins (claims + payments + acknowledgements) for consistent, fast queries across all downstream consumers |
| **`APPLY CHANGES` in Gold** | Enables continuous upserts for denial events without full table rebuilds—critical for real-time KPIs |
| **Reject tables retained** | Provides transparency and audit trail; operations teams can investigate malformed claims without reopening source files |
| **Unity Catalog governance** | Engineers manage bronze/silver, analysts query gold, executives consume dashboards—all with appropriate access controls |

---

## 📈 What Stakeholders Get

### For Finance Leaders
- **Revenue leakage visibility**: Dollar amount lost to adjustments caused by denials by category and payer
- **Payment velocity metrics**: Average days to first payment, identifying slow payers
- **Payer scorecards**: First-pass yield and denial rates enabling data-driven contract negotiations

### For Revenue Cycle Analysts
- **Trend analysis**: FPY and denial rate evolution over time by payer
- **Root cause analysis**: Top denial reason codes ranked by financial impact
- **Balance reconciliation**: Billed vs. paid vs. outstanding amounts per payer with drill-down capability

### For Data Engineering Teams
- **Self-service governance model**: Clear ownership and access patterns via Unity Catalog
- **Operational visibility**: Monitoring dashboards for pipeline health and data quality
- **Extensibility**: Medallion architecture supports easy addition of new payer feeds or internal systems

---

## 🔢 Core Metrics & Calculations

**Total Submitted Claims**  
Count of all claims sent to payers (denominator for percentage KPIs)

**First-Pass Yield (FPY)**  
```
Claims fully paid without denials or rejections on the first submission / Total submitted claims
```
*Industry benchmark: 85-95% for high-performing organizations*

**Denial Rate**  
```
Claims with any associated denial flag / Total submitted claims
```
*Target: <5% for most service lines*

**Days to First Payment**  
```
MIN(payment_posted_timestamp) - claim_submission_date
```
*Tracked per payer to identify payment velocity issues*

**Denial Impact ($)**  
```
SUM(negative adjustments) grouped by denial category
```
*Quantifies revenue at risk from specific denial patterns*

---

## 🆚 Why Not Just Use EHR Dashboards?

Native EHR reporting tools fall short for strategic analytics:

| EHR Dashboards | Claims360 Lakehouse |
|----------------|---------------------|
| Overnight refresh cycles | Near real-time streaming updates |
| Siloed claims vs. denials views | Unified claim lifecycle from submission to payment |
| Vendor-locked reporting logic | Open SQL models that analysts can extend |
| Limited historical depth | Unlimited retention with Delta Lake time travel |
| No cross-system joins | Native integration of EHR + clearinghouse + payer data |
| Rigid access controls | Flexible Unity Catalog governance for collaboration |

The Lakehouse approach doesn't replace the EHR—it **unlocks** the value of EHR data by combining it with external signals that tell the complete revenue story.

---

## 🏛️ Architecture Overview

**Technology Stack:**
- **Databricks Lakehouse Platform**: Unified analytics and governance
- **Delta Lake**: ACID transactions, time travel, schema evolution
- **Lakeflow DLT**: Declarative pipeline orchestration
- **Auto Loader**: Incremental, resilient file ingestion
- **Unity Catalog**: Fine-grained access control and data lineage
- **SQL** for bronze/silver layers, **python** for gold layer

---

## 🚀 Business Outcomes

This pipeline directly addresses the most critical revenue cycle pain points:

✅ **Faster reimbursement** through early identification of claim issues  
✅ **Reduced denial rates** via proactive pattern detection  
✅ **Improved payer relationships** with data-backed performance discussions  
✅ **Cross-functional collaboration** between technical and business teams  
✅ **Regulatory compliance** through comprehensive audit trails  

By moving from fragmented, delayed reporting to unified, real-time analytics, healthcare organizations can reclaim millions in denied revenue and accelerate cash flow—making the Lakehouse investment self-funding within quarters, not years.

---

## 👨‍💻 About This Project

Claims360 represents the convergence of my healthcare domain expertise and passion for using the capabilities of modern data platforms to solve critical business problems. Having implemented and supported Epic revenue cycle products and worked directly with hospital operations and C-suite, I understand the operational realities that make or break analytics adoption. This project demonstrates how thoughtful architecture—not just technology—solves real business problems.

**Skills demonstrated:**
- Lakehouse architecture and medallion design patterns
- Streaming and batch data ingestion strategies  
- Data quality and governance implementation
- Stakeholder-driven KPI design