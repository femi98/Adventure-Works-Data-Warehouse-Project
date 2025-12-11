Adventure Works Data Warehouse & Analysis Project

📖 Project Overview

This repository documents a comprehensive two-part data engineering and analytics initiative using the AdventureWorks dataset.

The project demonstrates a modern data warehousing approach using the Medallion Architecture to process raw data from CSV files into high-quality business insights, followed by an in-depth Exploratory Data Analysis (EDA) phase.

🏗 Architecture: The Medallion Model

We implemented a Multi-Hop architecture to organize data quality levels progressively.

🥉 1. Bronze Layer (Raw Data)

Purpose: Serves as the landing zone and version control for raw data.

Process: Raw data was ingested directly from multiple CSV source files.

State: Data is kept in its original format without modification to ensure we always have a source of truth.

🥈 2. Silver Layer (Cleaned & Transformed)

Purpose: "Enterprise view" of the data.

Process: SQL transformations were applied to clean, deduplicate, and standardize data types.

State: Missing values handled, dates standardized, and relational integrity checks performed.

🥇 3. Gold Layer (Aggregated & Integrated)

Purpose: Business-level data ready for analytics and reporting.

Process: Data was joined, aggregated, and modeled (Star Schema) to support specific business queries.

State: High-level metrics, KPIs, and integrated dimensions.

📅 Project Phases

Project 1: Data Warehousing

In this phase, we built the foundation using SQL DDL (Data Definition Language).

Ingestion: Created database schemas and bulk-imported data from CSVs into the Bronze layer.

Transformation: Wrote SQL scripts to move data through the Silver and Gold layers.

Result: A fully functional Data Warehouse capable of supporting complex queries.

Project 2: Exploratory Data Analysis (EDA)

Using the Gold layer constructed in Project 1, we performed extensive analysis to understand the business health.

Goal: Uncover surface-level insights and understand the current business situation.

Method: Complex SQL queries, window functions, and aggregations.

Outcome: Actionable insights regarding sales trends, product performance, and customer behavior.

🛠 Tech Stack

Core Language: SQL

Data Source: Multiple CSV Flat Files (AdventureWorks Data)

Database Management: [e.g., SQL Server / PostgreSQL / MySQL]

Architecture Pattern: Medallion (Bronze/Silver/Gold)

📂 Repository Structure

├── data/
│   └── raw_csvs/          # Source files for Bronze layer
├── sql/
│   ├── 01_bronze/         # DDLs for raw table creation & CSV imports
│   ├── 02_silver/         # Cleaning and transformation scripts
│   ├── 03_gold/           # Aggregation and Star Schema logic
│   └── 04_eda/            # Exploratory Data Analysis queries
├── docs/                  # Architecture diagrams
└── README.md


🚀 Key Insights (EDA)

Through the exploratory analysis phase, we uncovered several critical business findings:

Revenue Trends: Identified peak sales periods and seasonal fluctuations.

Customer Segments: Mapped high-value customers versus casual buyers.

Product Performance: Distinguished between high-margin products and slow-moving inventory.

⚙️ Setup & Installation

Initialize Database:

Execute scripts in sql/01_bronze/ to create the database and tables.

Load Data:

Import the CSV files located in data/raw_csvs/ into the Bronze tables.

Run Pipeline:

Run scripts in 02_silver followed by 03_gold to populate the warehouse.

Analyze:

Run the queries in 04_eda to view the insights.

🤝 Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements to the transformation logic or additional EDA queries.

📄 License

This project is open-source and available under the MIT License.
