#!/bin/bash


cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting with apache & SSO in AMER on low-environments ==="

echo -e "\n=== Starting with apache_dmzi ===\n\n"

bash awx_prompt.sh -r AMER -e STG -p apache_dmzi -l apache_dmzi_amer_stg_dmzi -u update -g iv2amer -d prod -t false -z DMZI

sleep 5
echo -e "\n=== Starting with apache_dmzi_amer ===\n\n"

bash awx_prompt.sh -r AMER -e STG -p apache_dmzi_amer -l apache_dmzi_amer_amer_stg_dmzi -u update -g iv2amer -d prod -t false -z DMZI

sleep 5
echo -e "\n=== Starting with apache ===\n\n"

bash awx_prompt.sh -r AMER -e DEV -p apache -l apache_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e STG -p apache -l apache_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE

sleep 5
echo -e "\n=== Starting with dpi_upgraded_apache ===\n\n"

bash awx_prompt.sh -r AMER -e DEV -p dpi_upgraded_apache -l dpi_upgraded_apache_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e STG -p dpi_upgraded_apache -l dpi_upgraded_apache_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE

sleep 5
echo -e "\n=== Starting with sso_as_a_service ===\n\n"

bash awx_prompt.sh -r AMER -e DEV -p sso_as_a_service -l sso_as_a_service_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e STG -p sso_as_a_service -l sso_as_a_service_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE

sleep 5
echo -e "\n=== Starting with sso_as_a_service_ibm_vdc ===\n\n"

bash awx_prompt.sh -r AMER -e DEV -p sso_as_a_service_ibm_vdc -l sso_as_a_service_ibm_vdc_amer_dev_intranet -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e DEV -p sso_as_a_service_ibm_vdc -l sso_as_a_service_ibm_vdc_amer_stg_intranet -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e DEV -p sso_as_a_service_ibm_vdc -l sso_as_a_service_ibm_vdc_amer_prd_intranet -u update -g iv2amer -d prod -t false -z CORE

sleep 5
echo -e "\n=== Starting with dpi_upgraded_sso_as_a_service ===\n\n"

bash awx_prompt.sh -r AMER -e DEV -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e STG -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE

sleep 5
echo -e "\n=== Starting with apache_ibm ===\n\n"

bash awx_prompt.sh -r AMER -e STG -p apache_ibm -l apache_ibm_amer_stg_mzr -u update -g iv2amer -d prod -t false -z MZR

echo -e "\n=== Finished all templates for Apache in AMER region ===\n\n"
