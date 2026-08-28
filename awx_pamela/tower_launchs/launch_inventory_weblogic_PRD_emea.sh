#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting weblogic in EMEA on PRD ==="

bash awx_prompt.sh -r EMEA -e PRD -p weblogic -l weblogic_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE

echo -e "\n=== Finished all templates for weblogic PRD in EMEA ===\n\n\n"