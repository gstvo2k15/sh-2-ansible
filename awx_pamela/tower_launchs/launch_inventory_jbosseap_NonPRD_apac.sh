#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting JbossEAP in APAC on low-environments ==="

echo -e "\n=== Starting with jbosseap ===\n"

bash awx_prompt.sh -r APAC -e DEV -p jbosseap -l jbosseap_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e STG -p jbosseap -l jbosseap_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE

echo -e "\n=== Finished all templates for JbossEAP Non-Prod in APAC region ===\n\n"