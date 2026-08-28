#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting Tomcat in EMEA on PRD ==="

bash awx_prompt.sh -r EMEA -e PRD -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e PRD -p tomcat -l tomcat_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e PRD -p tomcat_ibmcloud_vpc -l tomcat_ibmcloud_vpc_emea_prd_mzr -u update -g MiddlewareFR -d prod -t false -z MZR

sleep 5
echo -e "\n=== Starting with jboss_ews ===\n"

bash awx_prompt.sh -r EMEA -e PRD -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e PRD -p jboss_ews -l jboss_ews_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE

echo -e "\n=== Finished all templates for Tomcat PRD in EMEA region ===\n\n"