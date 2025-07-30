# DTH Data Warehouse Analytics (SQL Server Edition)

This project provides a comprehensive sample data warehouse designed for Direct‑to‑Home (DTH) television service analytics. It includes SQL Server scripts to build a star schema, sample CSV datasets, analytical queries, and diagrams to explore churn analysis, customer engagement, advertising performance, and more.

---

## Table of Contents

1. [Features](#features)
2. [Project Structure](#project-structure)
3. [Data Model](#data-model)
4. [Setup Guide](#setup-guide)
5. [Example Analytics](#example-analytics)
6. [Diagrams](#diagrams)

---

## Features

* **Self-contained SQL Scripts**

  * `DW_Tables.sql` creates all required dimension, fact, and aggregated tables and includes ETL logic for monthly summaries.

* **Sample Data for Instant Use**

  * CSV files aligned with the schema enable direct loading without external data dependencies.

* **Analytics Query Library**

  * `Queries.sql` includes pre-built queries for churn analysis, customer loyalty scoring, content feedback, promotion impact, and cohort-based retention.

* **Presentation & Documentation**

  * ER diagrams, schema images, and a PowerPoint/PDF report describe the overall architecture and information flow.

---

## Project Structure

```
DTH-Data-Warehouse/
├── DW_Tables.sql              # Schema creation & ETL
├── Queries.sql                # Sample analytics queries
├── customer_dimension.csv     # Sample dimension data
├── plan_dimension.csv         # More CSVs for each table
├── DWdiagrams/                # ER diagrams and visuals
├── Schema.png                 # Star schema overview
├── Report_Slides.pdf          # Documentation/presentation
└── README.md                  # This file
```

> All scripts and datasets are placed in the root directory for ease of use.

---

## Data Model

This project uses a **star schema** centered around subscription and engagement activities with rich supporting dimensions.

### 📘 Dimension Tables

| Table Name              | Description                                |
| ----------------------- | ------------------------------------------ |
| `Customer_dimension`    | Subscriber demographics & contact info     |
| `Plan_dimension`        | Plan names, pricing, and included channels |
| `Time_dimension`        | Date hierarchy (day, week, month, quarter) |
| `Channel_dimension`     | Channel metadata and genres                |
| `Content_dimension`     | Program or episode details                 |
| `Reason_dimension`      | Reasons for churn or unsubscription        |
| `Promotion_dimension`   | Promotional campaign metadata              |
| `Event_dimension`       | Major events or seasonal triggers          |
| `Ad_exposure_dimension` | Advertisement details and impressions      |
| `Genre_dimension`       | Genre category mapping                     |

### 📊 Fact Tables

| Table Name                      | Description                              |
| ------------------------------- | ---------------------------------------- |
| `Subscription_fact`             | Subscription records and plan history    |
| `Unsubscription_fact`           | Customer churn details with reasons      |
| `Feedback_fact`                 | Feedback mapped to plans and channels    |
| `Customer_engagement_fact`      | Ad exposure, content viewing, engagement |
| `Monthly_aggregate_fact`        | Pre-computed monthly KPIs                |
| `Series_monthly_aggregate_fact` | Series-level monthly summaries           |

### Sample CSV Structure

Example: `customer_dimension.csv`

```
customer_id, customer_name, customer_email, customer_address, customer_city, customer_zipcode
```

Example: `plan_dimension.csv`

```
plan_id, plan_name, plan_price, channel_package, plan_duration
```

These column structures match insert orders used in the SQL scripts.

---

## Setup Guide

### 1. Clone or Download the Repository

```bash
git clone https://github.com/shiven424/DTH-Data-Warehouse
```

Alternatively, download the ZIP and extract it locally.

---

### 2. Create the Database

* Open **SQL Server Management Studio (SSMS)**.
* Execute `DW_Tables.sql` to:

  * Create all dimension, fact, and aggregate tables.
  * Optionally populate them with sample data.

---

### 3. Load CSV Data

You can load the sample CSVs into their respective tables using:

* **SSMS Import Data Wizard**, or
* `BULK INSERT` statements (included in `DW_Tables.sql`).

Example tables:

* `Customer_dimension`
* `Plan_dimension`
* `Channel_dimension`

---

### 4. Run ETL Logic

Run the ETL section in `DW_Tables.sql` to populate:

* `Monthly_aggregate_fact`
* `Series_monthly_aggregate_fact`

These contain pre-computed KPIs for faster analytics.

---

### 5. Execute Analytics

* Open `Queries.sql` in SSMS.
* Run any of the provided analytical queries.

Example analyses include:

* Churn timing
* Feedback sentiment
* Promotion lift
* Viewer engagement trends

---

### 6. Connect to BI Tools (Optional)

You can connect the database to a BI tool such as:

* **Power BI**
* **Tableau**
* **Google Data Studio**

Use them to create dashboards and visualize key metrics using the sample data.

---

## Example Analytics

**Query: Average Days to Churn by Reason**

```sql
SELECT
  r.reason_category,
  r.reason_description,
  ROUND(AVG(DATEDIFF(day, s.subscription_start_date, u.unsubscription_date)), 1) AS avg_days_to_unsub
FROM Unsubscription_fact u
JOIN Subscription_fact s
  ON u.customer_id = s.customer_id
  AND u.unsubscription_date BETWEEN s.subscription_start_date AND s.subscription_end_date
JOIN Reason_dimension r
  ON u.reason_id = r.reason_id
GROUP BY r.reason_category, r.reason_description
ORDER BY avg_days_to_unsub DESC;
```

Other queries compute:

* Channel loyalty scores
* Promotion effectiveness
* Viewer cohort behavior
* Feedback trends by genre or content

---

## Diagrams

Navigate to the `DWdiagrams/` folder to explore:

* Star schema diagram
* Information package visualizations
* `Schema.png` for a quick overview

These assets assist in understanding relationships and metric derivations.
