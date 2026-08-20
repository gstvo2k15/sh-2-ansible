#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting with apache & SSO in EMEA on low-environments ==="

echo -e "\n=== Starting with apache_dmzi ===\n\n"

bash awx_prompt.sh -r EMEA -e DEV -p apache_dmzi -l apache_dmzi_emea_dev_dmzi -u update -g MiddlewareFR -d prod -t false -z DMZI
bash awx_prompt.sh -r EMEA -e STG -p apache_dmzi -l apache_dmzi_emea_stg_dmzi -u update -g MiddlewareFR -d prod -t false -z DMZI

sleep 5
echo -e "\n=== Starting with apache_dmzi_emea ===\n\n"

bash awx_prompt.sh -r EMEA -e DEV -p apache_dmzi_emea -l apache_dmzi_emea_emea_dev_dmzi -u update -g MiddlewareFR -d prod -t false -z DMZI
bash awx_prompt.sh -r EMEA -e STG -p apache_dmzi_emea -l apache_dmzi_emea_emea_stg_dmzi -u update -g MiddlewareFR -d prod -t false -z DMZI

sleep 5
echo -e "\n=== Starting with apache ===\n\n"

bash awx_prompt.sh -r EMEA -e DEV -p apache -l apache_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e STG -p apache -l apache_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

sleep 5
echo -e "\n=== Starting with apache_wsgi ===\n\n"

bash awx_prompt.sh -r EMEA -e DEV -p apache_wsgi -l apache_wsgi_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e STG -p apache_wsgi -l apache_wsgi_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

sleep 5
echo -e "\n=== Starting with csa_imported_apache_dmzi_emea ===\n\n"

bash awx_prompt.sh -r EMEA -e STG -p csa_imported_apache_dmzi_emea -l csa_imported_apache_dmzi_emea_emea_stg_dmzi -u update -g MiddlewareFR -d prod -t false -z DMZI
bash awx_prompt.sh -r EMEA -e PRD -p csa_imported_apache_dmzi_emea -l csa_imported_apache_dmzi_emea_emea_prd_dmzi -u update -g MiddlewareFR -d prod -t false -z DMZI

sleep 5
echo -e "\n=== Starting with dpi_upgraded_apache ===\n\n"

bash awx_prompt.sh -r EMEA -e DEV -p dpi_upgraded_apache -l dpi_upgraded_apache_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e STG -p dpi_upgraded_apache -l dpi_upgraded_apache_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE


sleep 5
echo -e "\n=== Starting with sso_as_a_service ===\n\n"

bash awx_prompt.sh -r EMEA -e DEV -p sso_as_a_service -l sso_as_a_service_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e STG -p sso_as_a_service -l sso_as_a_service_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

sleep 5
echo -e "\n=== Starting with sso_as_a_service ===\n\n"

bash awx_prompt.sh -r EMEA -e DEV -p sso_as_a_service -l sso_as_a_service_ibm_dmzr_emea_dev_mzr -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e STG -p sso_as_a_service -l sso_as_a_service_ibm_dmzr_emea_stg_mzr -u update -g MiddlewareFR -d prod -t false -z CORE

sleep 5
echo -e "\n=== Starting with dpi_upgraded_sso_as_a_service ===\n\n"

bash awx_prompt.sh -r EMEA -e DEV -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e STG -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

sleep 5
echo -e "\n=== Starting with apache_ibmcloud_vpc ===\n\n"

bash awx_prompt.sh -r EMEA -e DEV -p apache_ibmcloud_vpc -l apache_ibmcloud_vpc_emea_dev_mzr -u update -g MiddlewareFR -d prod -t false -z MZR
bash awx_prompt.sh -r EMEA -e STG -p apache_ibmcloud_vpc -l apache_ibmcloud_vpc_emea_stg_mzr -u update -g MiddlewareFR -d prod -t false -z MZR

echo -e "\n=== Finished all Templates for Apache in EMEA region ===\n\n"
