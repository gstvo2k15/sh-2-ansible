#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting weblogic in EMEA on low-environments ==="

bash awx_prompt.sh -r EMEA -e DEV -p weblogic -l weblogic_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e STG -p weblogic -l weblogic_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

echo -e "\n=== Finished all templates for weblogic Non-Prod in EMEA ===\n\n\n"