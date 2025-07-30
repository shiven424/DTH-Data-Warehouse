# DTH Data Warehouse Analytics (SSMS Edition)

A comprehensive data warehouse and analytics platform for Direct-to-Home (DTH) service providers, built for SQL Server Management Studio (SSMS). This repository contains all SQL scripts, sample data, and documentation needed to set up, populate, and analyze a DTH analytics warehouse.


## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Why This Project?](#why-this-project)
- [Architecture](#architecture)
- [Data Model](#data-model)
- [Key Analytics & Reports](#key-analytics--reports)
- [Setup Instructions](#setup-instructions)
- [Usage](#usage)


## Project Overview

DTH providers face challenges in managing and analyzing fragmented data from subscriptions, unsubscriptions, content, and customer engagement. This project delivers a centralized data warehouse that unifies these sources, enabling:

- Multidimensional analytics
- Customer retention strategies
- Personalized content recommendations
- Operational and financial reporting


## Features

- **All-in-One SQL Scripts:** All table creation and analytics queries are in `DW_Tables.sql` and `Queries.sql`, compatible with SSMS.
- **Sample Data Included:** Each table has a corresponding CSV file for easy import and testing.
- **Aggregated Tables:** Some tables are filled using ETL logic within the SQL scripts, based on data from other tables.
- **No Complex Folder Structure:** All files are in the root directory for simplicity—no separate ETL, queries, or schema folders.
- **Visual Documentation:** Diagrams and schema images are provided in the `DWdiagrams` folder.



## Why This Project?

- **Optimize Customer Retention:** Identify churn drivers and implement targeted retention strategies.
- **Enhance Personalization:** Analyze viewing patterns to recommend relevant content and offers.
- **Improve Operational Efficiency:** Unified reporting for marketing, finance, and service teams.
- **Drive Revenue Growth:** Enable cross-sell, upsell, and dynamic pricing based on real usage data.


## Architecture

- **Data Sources:** CSV files for each dimension and fact table.
- **SQL Scripts:** All schema and analytics logic in `DW_Tables.sql` and `Queries.sql`.
- **Aggregated Tables:** Populated using SQL ETL logic after base tables are loaded.
- **Visualization:** Diagrams and schema images in `DWdiagrams`.


## Data Model

### Key Dimension Tables

| Table                  | Description                                 |
|------------------------|---------------------------------------------|
| Customer_dimension     | Subscriber profile and contact details      |
| Plan_dimension         | DTH package details                         |
| Time_dimension         | Calendar hierarchy                          |
| Channel_dimension      | TV channel metadata                         |
| Content_dimension      | Episode/series details                      |
| Reason_dimension       | Churn reasons                               |
| Promotion_dimension    | Marketing campaigns                         |
| Event_dimension        | Special broadcast events                    |
| Ad_exposure_dimension  | Ad impression and skip tracking             |
| Genre_dimension        | Content genres                              |

### Key Fact Tables

| Table                        | Description                                 |
|------------------------------|---------------------------------------------|
| Subscription_fact            | Subscription events and status              |
| Unsubscription_fact          | Churn events and reasons                    |
| Feedback_fact                | Customer feedback and ratings               |
| Customer_engagement_fact     | Viewer interactions and ad exposure         |
| Monthly_aggregate_fact       | Pre-computed monthly metrics                |
| Series_monthly_aggregate_fact| Series-level monthly engagement             |


## Key Analytics & Reports

- **Churn Analysis:** Unsubscription patterns and root causes
- **Engagement Metrics:** Viewing duration, view counts, engagement scores
- **Content Performance:** Top-rated series, busiest channels, genre trends
- **Customer Segmentation:** Loyalty and churn-risk scoring
- **Feedback Sentiment:** Channel and plan-level sentiment analysis
- **Ad Effectiveness:** Engagement lift by ad type
- **Subscription Trends:** Monthly roll-ups and retention cohorts


## Setup Instructions

1. **Clone or Download the Repository**
   - Download or clone the repo to your local machine.

2. **Database Setup in SSMS**
   - Open `DW_Tables.sql` in SQL Server Management Studio.
   - Execute the script to create all tables and relationships.

3. **Import Sample Data**
   - For each table, use the SSMS Import Wizard or `BULK INSERT` to load the corresponding CSV file (e.g., `customer_dimension.csv` for the `Customer_dimension` table).

4. **Populate Aggregated Tables**
   - Some tables (e.g., `Monthly_aggregate_fact`, `Series_monthly_aggregate_fact`) are filled using SQL ETL logic included in `DW_Tables.sql`. Run the relevant insert statements after loading base data.

5. **Run Analytics Queries**
   - Open `Queries.sql` in SSMS.
   - Execute any analytics or reporting queries as needed.

6. **Visualize Schema and Analytics**
   - Refer to images in the `DWdiagrams` folder for schema diagrams and information package visuals.


## Usage

- **Run Analytics Queries:** Use `Queries.sql` to generate reports and insights.
- **Build Dashboards:** Connect BI tools (e.g., Power BI, Tableau) to your SQL Server database for visualization.
- **Customize:** Extend the data model or queries as per your requirements.

