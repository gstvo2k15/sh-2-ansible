#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting JbossEAP in AMER on PRD environment ==="

echo -e "\n=== Starting with jbosseap ===\n"

bash awx_prompt.sh -r AMER -e PRD -p jbosseap -l jbosseap_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE

echo -e "\n=== Finished all templates for JbossEAP PRD in AMER region ===\n\n"