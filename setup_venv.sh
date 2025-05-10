#!/bin/zsh

set -e  # Stop on error

# Activate the virtual environment
source venv/bin/activate

[ ! -f .env ] || export $(grep -v '^#' .env | xargs)

# Run your dbt setup commands
echo "Running dbt setup commands..."
dbt deps
dbt seed

# Now enter interactive shell with venv activated (for zsh users)
if [ -n "$ZSH_VERSION" ]; then
  echo "Starting zsh interactive shell inside virtualenv"
  exec zsh -l # For zsh users
else
  echo "Starting bash interactive shell inside virtualenv"
  exec bash  # For bash users
fi