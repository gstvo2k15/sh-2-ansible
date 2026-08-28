#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting weblogic in AMER on PRD ==="

bash awx_prompt.sh -r AMER -e PRD -p weblogic -l weblogic_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE

echo -e "\n=== Finished all templates for weblogic PRD in AMER ===\n\n\n"