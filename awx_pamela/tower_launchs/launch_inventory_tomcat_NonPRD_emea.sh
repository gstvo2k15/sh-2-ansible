#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting tomcat in EMEA on low-environments ==="

bash awx_prompt.sh -r EMEA -e DEV -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e STG -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e DEV -p tomcat -l tomcat_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e STG -p tomcat -l tomcat_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e DEV -p tomcat_ibmcloud_vpc -l tomcat_ibmcloud_vpc_emea_dev_mzr -u update -g MiddlewareFR -d prod -t false -z MZR
bash awx_prompt.sh -r EMEA -e STG -p tomcat_ibmcloud_vpc -l tomcat_ibmcloud_vpc_emea_stg_mzr -u update -g MiddlewareFR -d prod -t false -z MZR

sleep 5
echo -e "\n=== Starting with jboss_ews ===\n"

bash awx_prompt.sh -r EMEA -e DEV -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e STG -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e DEV -p jboss_ews -l jboss_ews_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e STG -p jboss_ews -l jboss_ews_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

echo -e "\n=== Finished all templates for JDK Non-Prod in EMEA region ===\n\n"