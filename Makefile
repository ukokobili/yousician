#######################################################################################
# dbt commands

docs:
	dbt docs generate && dbt docs serve

gen:
	python code/model_generate.py

#######################################################################################
# git commit, push, and pull requests

push:
	@read -p "Enter branch name: " branch; \
	if git show-ref --verify --quiet refs/heads/$$branch; then \
		echo "Branch '$$branch' exists. Switching to it..."; \
		git checkout $$branch; \
	else \
		echo "Branch '$$branch' does not exist. Creating new branch..."; \
		git checkout -b $$branch; \
	fi; \
	read -p "Enter commit message: " msg; \
	git add .; \
	git commit -m "$$msg"; \
	git push origin $$branch

pull:
	git checkout main && git pull origin main

#######################################################################################
# code formatter
fmt:
	sqlfmt models

#######################################################################################
# Make the env_vars.sh script executable
chmodx:
	chmod +x env_vars.sh 

# Source the env_vars.sh script to set environment variables
script:
	. ./env_vars.sh

# Echo the MOTHERDUCK_TOKEN environment variable
echoes:
	@echo "MOTHERDUCK_TOKEN: $$MOTHERDUCK_TOKEN"

# Run dbt debug after setting up environment variables
debug: chmodx script echoes
	dbt debug