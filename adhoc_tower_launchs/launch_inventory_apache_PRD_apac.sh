#!/bin/bash

cd /apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/schedule_awx

echo -e "\n=== Starting with apache & SSO in APAC on PRD===\n\n"

bash awx_prompt.sh -r APAC -e PRD -p apache_dmzi -l apache_dmzi_apac_prd_dmzi -u update -g iv2apac -d prod -t false -z DMZI
bash awx_prompt.sh -r APAC -e PRD -p apache -l apache_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e PRD -p apache_dmzi_apac -l apache_dmzi_apac_apac_prd_dmzi -u update -g iv2apac -d prod -t false -z DMZI
bash awx_prompt.sh -r APAC -e PRD -p apache -l apache_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e PRD -p dpi_upgraded_apache -l dpi_upgraded_apache_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e PRD -p sso_as_a_service -l sso_as_a_service_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE
bash awx_prompt.sh -r APAC -e PRD -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE
