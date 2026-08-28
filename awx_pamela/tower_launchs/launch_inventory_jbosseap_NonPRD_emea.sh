#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting JbossEAP in EMEA on low-environments ==="

echo -e "\n=== Starting with jbosseap ===\n"

bash awx_prompt.sh -r EMEA -e DEV -p jbosseap -l jbosseap_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e STG -p jbosseap -l jbosseap_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

echo -e "\n=== Finished all templates for JbossEAP Non-Prod in EMEA region ===\n\n"