#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting with apache & SSO in EMEA on PRD ===\n\n"

bash awx_prompt.sh -r EMEA -e PRD -p apache_dmzi -l apache_dmzi_emea_prd_dmzi -u update -g MiddlewareFR -d prod -t false -z DMZI
bash awx_prompt.sh -r EMEA -e PRD -p apache_dmzi_emea -l apache_dmzi_emea_emea_prd_dmzi -u update -g MiddlewareFR -d prod -t false -z DMZI
bash awx_prompt.sh -r EMEA -e PRD -p apache -l apache_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e PRD -p apache -l apache_emea_prd_ets -u update -g MiddlewareFR -d prod -t false -z ETS
bash awx_prompt.sh -r EMEA -e PRD -p apache_wsgi -l apache_wsgi_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e PRD -p csa_imported_apache_dmzi_emea -l csa_imported_apache_dmzi_emea_emea_prd_dmzi -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e PRD -p dpi_upgraded_apache -l dpi_upgraded_apache_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e PRD -p dpi_upgraded_apache -l dpi_upgraded_apache_emea_prd_ets -u update -g MiddlewareFR -d prod -t false -z ETS
bash awx_prompt.sh -r EMEA -e PRD -p sso_as_a_service -l sso_as_a_service_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e PRD -p sso_as_a_service -l sso_as_a_service_ibm_dmzr_emea_prd_mzr -u update -g MiddlewareFR -d prod -t false -z MZR
bash awx_prompt.sh -r EMEA -e PRD -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
bash awx_prompt.sh -r EMEA -e PRD -p apache_ibmcloud_vpc -l apache_ibmcloud_vpc_emea_prd_mzr -u update -g MiddlewareFR -d prod -t false -z CORE