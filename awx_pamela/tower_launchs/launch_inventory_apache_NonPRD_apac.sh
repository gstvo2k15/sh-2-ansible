#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting with apache & SSO in APAC on low-environments ==="

echo -e "\n=== Starting with apache_dmzi ===\n\n"

bash awx_prompt.sh -r APAC -e DEV -p apache_dmzi -l apache_dmzi_apac_dev_dmzi -u update -g iv2apac -d prod -t false -z DMZI
bash awx_prompt.sh -r APAC -e STG -p apache_dmzi -l apache_dmzi_apac_stg_dmzi -u update -g iv2apac -d prod -t false -z DMZI

sleep 5
echo -e "\n=== Starting with apache_dmzi_apac ===\n\n"

bash awx_prompt.sh -r APAC -e DEV -p apache_dmzi_apac -l apache_dmzi_apac_apac_dev_dmzi -u update -g iv2apac -d prod -t false -z DMZI
bash awx_prompt.sh -r APAC -e STG -p apache_dmzi_apac -l apache_dmzi_apac_apac_stg_dmzi -u update -g iv2apac -d prod -t false -z DMZI

sleep 5
echo -e "\n=== Starting with apache ===\n\n"

bash awx_prompt.sh -r APAC -e DEV -p apache -l apache_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e STG -p apache -l apache_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE

sleep 5
echo -e "\n=== Starting with dpi_upgraded_apache ===\n\n"

bash awx_prompt.sh -r APAC -e DEV -p dpi_upgraded_apache -l dpi_upgraded_apache_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e STG -p dpi_upgraded_apache -l dpi_upgraded_apache_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE

sleep 5
echo -e "\n=== Starting with sso_as_a_service ===\n\n"

bash awx_prompt.sh -r APAC -e DEV -p sso_as_a_service -l sso_as_a_service_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e STG -p sso_as_a_service -l sso_as_a_service_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE

sleep 5
echo -e "\n=== Starting with dpi_upgraded_sso_as_a_service ===\n\n"

bash awx_prompt.sh -r APAC -e DEV -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e STG -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE

echo -e "\n=== Finished all templates for Apache in APAC region ===\n\n"