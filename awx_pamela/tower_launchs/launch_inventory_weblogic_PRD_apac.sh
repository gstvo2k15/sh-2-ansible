#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting weblogic in EMEA on PRD in APAC ==="

bash awx_prompt.sh -r APAC -e PRD -p weblogic -l weblogic_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE

echo -e "\n=== Finished all templates for weblogic PRD in APAC ===\n\n\n"