Welcome to your snowflake dbt project!
### Using the starter project

prerequisites:
- make sure you have python3 installed
- Add credentials to [in the env](.env) file

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
├── profiles/           # dbt profiles
├── seeds/               # dbt seeds
├── snapshots/           # dbt snapshots
├── tests/               # dbt tests  
├── .gitignore           # Git ignore file
├── .sqlfluff            # SQLFluff configuration
├── README.md
├── dbt_project.yml    # dbt project configuration
├── elementary_config.yml        # Elementary configuration
├── makefile             # Makefile for task automation
├── packages.yml             # dbt packages
├── requirements.txt     # Python dependencies
├── setup_venv.sh        # Shell script to set up virtual environment
├── .env                 # Environment variables
