#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting JbossEAP in APAC on PRD environment ==="

echo -e "\n=== Starting with jbosseap ===\n"

bash awx_prompt.sh -r APAC -e PRD -p jbosseap -l jbosseap_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE

echo -e "\n=== Finished all templates for JbossEAP PRD in APAC region ===\n\n"