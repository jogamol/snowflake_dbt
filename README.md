Welcome to your snowflake dbt project!

prerequisites:
- Snowflake account with access to TPCH_SF1 sample data
- Snowflake databse created
- Add credentials to [in the env](.env) file
- make sure you have python3.10 installed

Try running the following commands:
- make install
- dbt debug 
- dbt run
- dbt test
- make lint
- edr report

Technologies used:

- dbt for data transformation
- snowflake for data warehousing
- python for virtual environment management
- make for task automation
- dbt-osmosis for yaml generation and managment
- bash for shell scripting
- elementary for data quality testing



### Project Structure

```
snowflake-dbt-project/
├── .github
│   └── workflows/       # GitHub Actions workflows
├── analysis/            # dbt analysis files
├── macros/              # dbt macros
├── models/              # dbt models
│   ├── staging/
│   ├── marts/
│   └── core/
├── profiles/            # dbt profiles
├── seeds/               # dbt seeds
├── snapshots/           # dbt snapshots
├── tests/               # dbt tests  
├── .gitignore           # Git ignore file
├── .sqlfluff            # SQLFluff configuration
├── README.md
├── dbt_project.yml      # dbt project configuration
├── elementary_config.yml        # Elementary configuration
├── makefile             # Makefile for task automation
├── packages.yml         # dbt packages
├── requirements.txt     # Python dependencies
├── setup_venv.sh        # Shell script to set up virtual environment
└── .env          # Environment variables
```


## Business Questions the Data Mart Can Answer

The Customer 360° Data Mart design enables answering sophisticated business questions across multiple domains:

### Customer Acquisition & Profiling

#### Customer Demographics Analysis
- What is the geographic distribution of our customer base?
- Which market segments have the most customers?
- How does customer distribution vary by region?

#### Customer Acquisition Trends
- How is our customer base growing over time?
- Which regions are showing the fastest customer growth?
- What is our customer acquisition cost by segment?

### Customer Value & Segmentation

#### Value-Based Segmentation
- Who are our top 20% most valuable customers?
- What percentage of revenue comes from each customer segment?
- How does lifetime value distribute across different market segments?

#### Behavioral Patterns
- What is the typical purchase frequency for each customer segment?
- How does order size correlate with purchase frequency?
- Which customer segments show the highest product category loyalty?


## Orchestration Recommendations

### Development Environment
- **GitHub Actions** for CI/CD

### Production Environment
- **Airflow** for orchestration
- Orchestration can be done 2 ways
  - **Parse Manifest.json**: Parse manifest.json to build the DAG and run the models
  - **Run one layer at a time**: Run one layer at a time and use the `--select` flag to run the models in the correct order

### Scheduling Cadence
- **Full refresh**: Daily at low-usage hours
- **Incremental updates**: 
  - Every 4 hours during business hours, 
  - if frequent data is not needed then ETL can be scheduled at midnight
