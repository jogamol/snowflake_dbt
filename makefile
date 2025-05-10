# Makefile for DBT + Snowflake + SQLFluff + Elementary + dbt-osmosis

PYTHON ?= python3
VENV_NAME ?= venv

.PHONY: venv install lint fmt clean info dbt-run dbt-test dbt-debug

venv:
	@rm -rf $(VENV_NAME)
	@$(PYTHON) -m venv $(VENV_NAME)
	@$(VENV_NAME)/bin/python -m pip install --upgrade pip
	@$(VENV_NAME)/bin/pip install -v -r requirements.txt
	@echo
	@echo "Virtual environment created and requirements installed."
	@echo
	@echo "Use 'source $(VENV_NAME)/bin/activate' to activate your virtualenv"

install: venv
	@echo "Activating virtual environment..."
	@bash --rcfile setup_venv.sh


lint: venv
	$(VENV_NAME)/bin/sqlfluff lint models/

clean:
	@rm -rf $(VENV_NAME)

info:
	@echo "Run 'source $(VENV_NAME)/bin/activate' to activate the virtualenv"
