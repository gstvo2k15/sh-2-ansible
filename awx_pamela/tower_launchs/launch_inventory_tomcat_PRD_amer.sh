#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting tomcat in AMER on PRD ==="

bash awx_prompt.sh -r AMER -e PRD -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e PRD -p tomcat -l tomcat_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e PRD -p tomcat_ibm -l tomcat_ibm_amer_prd_mzr -u update -g iv2amer -d prod -t false -z MZR

sleep 5
echo -e "\n=== Starting with jboss_ews ===\n"

bash awx_prompt.sh -r AMER -e PRD -p jboss_ews -l jboss_ews_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE

echo -e "\n=== Finished all templates for JDK PRD in AMER region ===\n\n"