#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting tomcat in APAC on PRD ==="

bash awx_prompt.sh -r APAC -e PRD -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e PRD -p tomcat -l tomcat_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE

sleep 5
echo -e "\n=== Starting with jboss_ews ===\n"

bash awx_prompt.sh -r APAC -e PRD -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e PRD -p jboss_ews -l jboss_ews_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE

echo -e "\n=== Finished all templates for tomcat PRD in APAC region ===\n\n"