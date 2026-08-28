#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting JbossEAP in AMER on low-environments ==="

echo -e "\n=== Starting with jbosseap ===\n"

bash awx_prompt.sh -r AMER -e DEV -p jbosseap -l jbosseap_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e STG -p jbosseap -l jbosseap_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE

echo -e "\n=== Finished all templates for JbossEAP Non-Prod in AMER region ===\n\n"