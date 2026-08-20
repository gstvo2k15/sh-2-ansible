#!/bin/bash


cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting JDK in APAC on low-environments ==="

echo -e "\n=== Starting with jbosseap ===\n"

bash awx_prompt.sh -r APAC -e DEV -p jbosseap -l jbosseap_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e STG -p jbosseap -l jbosseap_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE


sleep 5
echo -e "\n=== Starting with tomcat ===\n"

bash awx_prompt.sh -r APAC -e DEV -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e STG -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e DEV -p tomcat -l tomcat_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e STG -p tomcat -l tomcat_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE


sleep 5
echo -e "\n=== Starting with weblogic ===\n"

bash awx_prompt.sh -r APAC -e DEV -p weblogic -l weblogic_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e STG -p weblogic -l weblogic_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE


sleep 5
echo -e "\n=== Starting with jboss_ews ===\n"

bash awx_prompt.sh -r APAC -e DEV -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e STG -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e DEV -p jboss_ews -l jboss_ews_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e STG -p jboss_ews -l jboss_ews_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE



echo -e "\n=== Finished all templates for JDK Non-Prod in APAC region ===\n\n"