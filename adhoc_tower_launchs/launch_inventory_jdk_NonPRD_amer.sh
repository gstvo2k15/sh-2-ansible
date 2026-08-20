#!/bin/bash


cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting JDK in AMER on low-environments ==="

echo -e "\n=== Starting with jbosseap ===\n"

bash awx_prompt.sh -r AMER -e DEV -p jbosseap -l jbosseap_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e STG -p jbosseap -l jbosseap_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE


sleep 5
echo -e "\n=== Starting with tomcat ===\n"

bash awx_prompt.sh -r AMER -e DEV -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e STG -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e DEV -p tomcat -l tomcat_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e STG -p tomcat -l tomcat_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e DEV -p tomcat_ibm -l tomcat_ibm_amer_dev_mzr -u update -g iv2amer -d prod -t false -z MZR
bash awx_prompt.sh -r AMER -e STG -p tomcat_ibm -l tomcat_ibm_amer_stg_mzr -u update -g iv2amer -d prod -t false -z MZR


sleep 5
echo -e "\n=== Starting with weblogic ===\n"

bash awx_prompt.sh -r AMER -e DEV -p weblogic -l weblogic_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE


sleep 5
echo -e "\n=== Starting with jboss_ews ===\n"

bash awx_prompt.sh -r AMER -e DEV -p jboss_ews -l jboss_ews_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e STG -p jboss_ews -l jboss_ews_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE



echo -e "\n=== Finished all templates for JDK Non-Prod in AMER region ===\n\n"