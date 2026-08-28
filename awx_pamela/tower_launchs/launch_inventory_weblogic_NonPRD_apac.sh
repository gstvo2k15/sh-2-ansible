#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting weblogic in APAC on low-environments ==="

bash awx_prompt.sh -r APAC -e DEV -p weblogic -l weblogic_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE

echo -e "\n=== Finished all templates for weblogic Non-Prod in APAC ===\n\n\n"