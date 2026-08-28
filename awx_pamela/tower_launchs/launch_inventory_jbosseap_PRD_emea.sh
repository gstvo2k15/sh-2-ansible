#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting JbossEAP in EMEA on PRD environment ==="

echo -e "\n=== Starting with jbosseap ===\n"

bash awx_prompt.sh -r EMEA -e PRD -p jbosseap -l jbosseap_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE

echo -e "\n=== Finished all templates for JbossEAP PRD in EMEA region ===\n\n"