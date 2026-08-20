#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting with apache & SSO in AMER on PRD===\n\n"


bash awx_prompt.sh -r AMER -e PRD -p apache_dmzi -l apache_dmzi_amer_prd_dmzi -u update -g iv2amer -d prod -t false -z DMZI
bash awx_prompt.sh -r AMER -e PRD -p apache_dmzi_amer -l apache_dmzi_amer_amer_prd_dmzi -u update -g iv2amer -d prod -t false -z DMZI
bash awx_prompt.sh -r AMER -e PRD -p apache -l apache_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e PRD -p apache -l apache_amer_prd_ets -u update -g iv2amer -d prod -t false -z ETS
bash awx_prompt.sh -r AMER -e PRD -p dpi_upgraded_apache -l dpi_upgraded_apache_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e PRD -p sso_as_a_service -l sso_as_a_service_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e PRD -p sso_as_a_service_ibm_vdc -l sso_as_a_service_ibm_vdc_amer_prd_intranet -u update -g iv2amer -d prod -t false -z DMZI
bash awx_prompt.sh -r AMER -e PRD -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE
bash awx_prompt.sh -r AMER -e PRD -p apache_ibm -l apache_ibm_amer_prd_mzr -u update -g iv2amer -d prod -t false -z MZR