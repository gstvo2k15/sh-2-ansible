#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting weblogic in AMER on low-environments ==="

bash awx_prompt.sh -r AMER -e DEV -p weblogic -l weblogic_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE

echo -e "\n=== Finished all templates for weblogic Non-Prod in AMER ===\n\n\n"