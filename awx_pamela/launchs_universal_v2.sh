#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
AWX_PROMPT="${SCRIPT_DIR}/awx_prompt.sh"

usage() {
    cat <<'USAGE'
Usage:
  script.sh <product> <environment> <region>
  script.sh -h
  script.sh --help

Arguments:
  product:
    apache
    jbosseap
    jdk
    tomcat
    weblogic

  environment:
    PRD
    NonPRD

  region:
    AMER
    APAC
    EMEA

Examples:
  script.sh apache NonPRD AMER
  script.sh jbosseap PRD EMEA
  script.sh jdk NonPRD APAC
  script.sh tomcat PRD AMER
  script.sh weblogic NonPRD EMEA

Notes:
  - Arguments are case-insensitive.
  - Legacy launch_inventory_*.sh scripts are not used.
  - awx_prompt.sh must be located in the same directory as this script.
USAGE
}

run_awx() {
    echo
    echo "Running: awx_prompt.sh $*"

    bash "$AWX_PROMPT" "$@"
    local rc=$?

    if (( rc != 0 )); then
        echo "ERROR: awx_prompt.sh failed with exit code ${rc}." >&2
        exit "$rc"
    fi
}

if [[ $# -eq 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
    usage
    exit 0
fi

if [[ $# -ne 3 ]]; then
    echo "ERROR: Exactly 3 arguments are required." >&2
    echo >&2
    usage >&2
    exit 2
fi

product="${1,,}"
environment="${2,,}"
region="${3,,}"

case "$product" in
    apache|jbosseap|jdk|tomcat|weblogic) ;;
    *)
        echo "ERROR: Invalid product: $1" >&2
        echo >&2
        usage >&2
        exit 2
        ;;
esac

case "$environment" in
    prd)    environment="PRD" ;;
    nonprd) environment="NonPRD" ;;
    *)
        echo "ERROR: Invalid environment: $2" >&2
        echo >&2
        usage >&2
        exit 2
        ;;
esac

case "$region" in
    amer|apac|emea) ;;
    *)
        echo "ERROR: Invalid region: $3" >&2
        echo >&2
        usage >&2
        exit 2
        ;;
esac

if [[ ! -f "$AWX_PROMPT" ]]; then
    echo "ERROR: awx_prompt.sh was not found:" >&2
    echo "  $AWX_PROMPT" >&2
    exit 3
fi

key="${product}:${environment}:${region}"

echo "============================================================"
echo " Product     : ${product}"
echo " Environment : ${environment}"
echo " Region      : ${region^^}"
echo "============================================================"

case "$key" in
    #
    # APACHE
    #

    apache:NonPRD:amer)
        echo -e "\n=== Starting with apache & SSO in AMER on low-environments ==="

        echo -e "\n=== Starting with apache_dmzi ===\n\n"

        run_awx -r AMER -e STG -p apache_dmzi -l apache_dmzi_amer_stg_dmzi -u update -g iv2amer -d prod -t false -z DMZI

        sleep 5
        echo -e "\n=== Starting with apache_dmzi_amer ===\n\n"

        run_awx -r AMER -e STG -p apache_dmzi_amer -l apache_dmzi_amer_amer_stg_dmzi -u update -g iv2amer -d prod -t false -z DMZI

        sleep 5
        echo -e "\n=== Starting with apache ===\n\n"

        run_awx -r AMER -e DEV -p apache -l apache_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e STG -p apache -l apache_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with dpi_upgraded_apache ===\n\n"

        run_awx -r AMER -e DEV -p dpi_upgraded_apache -l dpi_upgraded_apache_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e STG -p dpi_upgraded_apache -l dpi_upgraded_apache_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with sso_as_a_service ===\n\n"

        run_awx -r AMER -e DEV -p sso_as_a_service -l sso_as_a_service_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e STG -p sso_as_a_service -l sso_as_a_service_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with sso_as_a_service_ibm_vdc ===\n\n"

        run_awx -r AMER -e DEV -p sso_as_a_service_ibm_vdc -l sso_as_a_service_ibm_vdc_amer_dev_intranet -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e DEV -p sso_as_a_service_ibm_vdc -l sso_as_a_service_ibm_vdc_amer_stg_intranet -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e DEV -p sso_as_a_service_ibm_vdc -l sso_as_a_service_ibm_vdc_amer_prd_intranet -u update -g iv2amer -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with dpi_upgraded_sso_as_a_service ===\n\n"

        run_awx -r AMER -e DEV -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e STG -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with apache_ibm ===\n\n"

        run_awx -r AMER -e STG -p apache_ibm -l apache_ibm_amer_stg_mzr -u update -g iv2amer -d prod -t false -z MZR

        echo -e "\n=== Finished all templates for Apache in AMER region ===\n\n"
        ;;

    apache:NonPRD:apac)
        echo -e "\n=== Starting with apache & SSO in APAC on low-environments ==="

        echo -e "\n=== Starting with apache_dmzi ===\n\n"

        run_awx -r APAC -e DEV -p apache_dmzi -l apache_dmzi_apac_dev_dmzi -u update -g iv2apac -d prod -t false -z DMZI
        run_awx -r APAC -e STG -p apache_dmzi -l apache_dmzi_apac_stg_dmzi -u update -g iv2apac -d prod -t false -z DMZI

        sleep 5
        echo -e "\n=== Starting with apache_dmzi_apac ===\n\n"

        run_awx -r APAC -e DEV -p apache_dmzi_apac -l apache_dmzi_apac_apac_dev_dmzi -u update -g iv2apac -d prod -t false -z DMZI
        run_awx -r APAC -e STG -p apache_dmzi_apac -l apache_dmzi_apac_apac_stg_dmzi -u update -g iv2apac -d prod -t false -z DMZI

        sleep 5
        echo -e "\n=== Starting with apache ===\n\n"

        run_awx -r APAC -e DEV -p apache -l apache_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e STG -p apache -l apache_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with dpi_upgraded_apache ===\n\n"

        run_awx -r APAC -e DEV -p dpi_upgraded_apache -l dpi_upgraded_apache_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e STG -p dpi_upgraded_apache -l dpi_upgraded_apache_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with sso_as_a_service ===\n\n"

        run_awx -r APAC -e DEV -p sso_as_a_service -l sso_as_a_service_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e STG -p sso_as_a_service -l sso_as_a_service_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with dpi_upgraded_sso_as_a_service ===\n\n"

        run_awx -r APAC -e DEV -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e STG -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for Apache in APAC region ===\n\n"
        ;;

    apache:NonPRD:emea)
        echo -e "\n=== Starting with apache & SSO in EMEA on low-environments ==="

        echo -e "\n=== Starting with apache_dmzi ===\n\n"

        run_awx -r EMEA -e DEV -p apache_dmzi -l apache_dmzi_emea_dev_dmzi -u update -g MiddlewareFR -d prod -t false -z DMZI
        run_awx -r EMEA -e STG -p apache_dmzi -l apache_dmzi_emea_stg_dmzi -u update -g MiddlewareFR -d prod -t false -z DMZI

        sleep 5
        echo -e "\n=== Starting with apache_dmzi_emea ===\n\n"

        run_awx -r EMEA -e DEV -p apache_dmzi_emea -l apache_dmzi_emea_emea_dev_dmzi -u update -g MiddlewareFR -d prod -t false -z DMZI
        run_awx -r EMEA -e STG -p apache_dmzi_emea -l apache_dmzi_emea_emea_stg_dmzi -u update -g MiddlewareFR -d prod -t false -z DMZI

        sleep 5
        echo -e "\n=== Starting with apache ===\n\n"

        run_awx -r EMEA -e DEV -p apache -l apache_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p apache -l apache_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with apache_wsgi ===\n\n"

        run_awx -r EMEA -e DEV -p apache_wsgi -l apache_wsgi_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p apache_wsgi -l apache_wsgi_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with csa_imported_apache_dmzi_emea ===\n\n"

        run_awx -r EMEA -e STG -p csa_imported_apache_dmzi_emea -l csa_imported_apache_dmzi_emea_emea_stg_dmzi -u update -g MiddlewareFR -d prod -t false -z DMZI
        run_awx -r EMEA -e PRD -p csa_imported_apache_dmzi_emea -l csa_imported_apache_dmzi_emea_emea_prd_dmzi -u update -g MiddlewareFR -d prod -t false -z DMZI

        sleep 5
        echo -e "\n=== Starting with dpi_upgraded_apache ===\n\n"

        run_awx -r EMEA -e DEV -p dpi_upgraded_apache -l dpi_upgraded_apache_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p dpi_upgraded_apache -l dpi_upgraded_apache_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with sso_as_a_service ===\n\n"

        run_awx -r EMEA -e DEV -p sso_as_a_service -l sso_as_a_service_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p sso_as_a_service -l sso_as_a_service_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with sso_as_a_service ===\n\n"

        run_awx -r EMEA -e DEV -p sso_as_a_service -l sso_as_a_service_ibm_dmzr_emea_dev_mzr -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p sso_as_a_service -l sso_as_a_service_ibm_dmzr_emea_stg_mzr -u update -g MiddlewareFR -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with dpi_upgraded_sso_as_a_service ===\n\n"

        run_awx -r EMEA -e DEV -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with apache_ibmcloud_vpc ===\n\n"

        run_awx -r EMEA -e DEV -p apache_ibmcloud_vpc -l apache_ibmcloud_vpc_emea_dev_mzr -u update -g MiddlewareFR -d prod -t false -z MZR
        run_awx -r EMEA -e STG -p apache_ibmcloud_vpc -l apache_ibmcloud_vpc_emea_stg_mzr -u update -g MiddlewareFR -d prod -t false -z MZR

        echo -e "\n=== Finished all templates for Apache in EMEA region ===\n\n"
        ;;

    apache:PRD:amer)
        echo -e "\n=== Starting with apache & SSO in AMER on PRD===\n\n"

        run_awx -r AMER -e PRD -p apache_dmzi -l apache_dmzi_amer_prd_dmzi -u update -g iv2amer -d prod -t false -z DMZI
        run_awx -r AMER -e PRD -p apache_dmzi_amer -l apache_dmzi_amer_amer_prd_dmzi -u update -g iv2amer -d prod -t false -z DMZI
        run_awx -r AMER -e PRD -p apache -l apache_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e PRD -p apache -l apache_amer_prd_ets -u update -g iv2amer -d prod -t false -z ETS
        run_awx -r AMER -e PRD -p dpi_upgraded_apache -l dpi_upgraded_apache_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e PRD -p sso_as_a_service -l sso_as_a_service_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e PRD -p sso_as_a_service_ibm_vdc -l sso_as_a_service_ibm_vdc_amer_prd_intranet -u update -g iv2amer -d prod -t false -z DMZI
        run_awx -r AMER -e PRD -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e PRD -p apache_ibm -l apache_ibm_amer_prd_mzr -u update -g iv2amer -d prod -t false -z MZR
        ;;

    apache:PRD:apac)
        echo -e "\n=== Starting with apache & SSO in APAC on PRD===\n\n"

        run_awx -r APAC -e PRD -p apache_dmzi -l apache_dmzi_apac_prd_dmzi -u update -g iv2apac -d prod -t false -z DMZI
        run_awx -r APAC -e PRD -p apache -l apache_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e PRD -p apache_dmzi_apac -l apache_dmzi_apac_apac_prd_dmzi -u update -g iv2apac -d prod -t false -z DMZI
        run_awx -r APAC -e PRD -p apache -l apache_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e PRD -p dpi_upgraded_apache -l dpi_upgraded_apache_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e PRD -p sso_as_a_service -l sso_as_a_service_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e PRD -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE
        ;;

    apache:PRD:emea)
        echo -e "\n=== Starting with apache & SSO in EMEA on PRD ===\n\n"

        run_awx -r EMEA -e PRD -p apache_dmzi -l apache_dmzi_emea_prd_dmzi -u update -g MiddlewareFR -d prod -t false -z DMZI
        run_awx -r EMEA -e PRD -p apache_dmzi_emea -l apache_dmzi_emea_emea_prd_dmzi -u update -g MiddlewareFR -d prod -t false -z DMZI
        run_awx -r EMEA -e PRD -p apache -l apache_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e PRD -p apache -l apache_emea_prd_ets -u update -g MiddlewareFR -d prod -t false -z ETS
        run_awx -r EMEA -e PRD -p apache_wsgi -l apache_wsgi_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e PRD -p csa_imported_apache_dmzi_emea -l csa_imported_apache_dmzi_emea_emea_prd_dmzi -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e PRD -p dpi_upgraded_apache -l dpi_upgraded_apache_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e PRD -p dpi_upgraded_apache -l dpi_upgraded_apache_emea_prd_ets -u update -g MiddlewareFR -d prod -t false -z ETS
        run_awx -r EMEA -e PRD -p sso_as_a_service -l sso_as_a_service_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e PRD -p sso_as_a_service -l sso_as_a_service_ibm_dmzr_emea_prd_mzr -u update -g MiddlewareFR -d prod -t false -z MZR
        run_awx -r EMEA -e PRD -p dpi_upgraded_sso_as_a_service -l dpi_upgraded_sso_as_a_service_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e PRD -p apache_ibmcloud_vpc -l apache_ibmcloud_vpc_emea_prd_mzr -u update -g MiddlewareFR -d prod -t false -z CORE
        ;;

    #
    # JBOSSEAP
    #

    jbosseap:NonPRD:amer)
        echo -e "\n=== Starting JbossEAP in AMER on low-environments ==="

        echo -e "\n=== Starting with jbosseap ===\n"

        run_awx -r AMER -e DEV -p jbosseap -l jbosseap_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e STG -p jbosseap -l jbosseap_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for JbossEAP Non-Prod in AMER region ===\n\n"
        ;;

    jbosseap:NonPRD:apac)
        echo -e "\n=== Starting JbossEAP in APAC on low-environments ==="

        echo -e "\n=== Starting with jbosseap ===\n"

        run_awx -r APAC -e DEV -p jbosseap -l jbosseap_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e STG -p jbosseap -l jbosseap_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for JbossEAP Non-Prod in APAC region ===\n\n"
        ;;

    jbosseap:NonPRD:emea)
        echo -e "\n=== Starting JbossEAP in EMEA on low-environments ==="

        echo -e "\n=== Starting with jbosseap ===\n"

        run_awx -r EMEA -e DEV -p jbosseap -l jbosseap_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p jbosseap -l jbosseap_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for JbossEAP Non-Prod in EMEA region ===\n\n"
        ;;

    jbosseap:PRD:amer)
        echo -e "\n=== Starting JbossEAP in AMER on PRD environment ==="

        echo -e "\n=== Starting with jbosseap ===\n"

        run_awx -r AMER -e PRD -p jbosseap -l jbosseap_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for JbossEAP PRD in AMER region ===\n\n"
        ;;

    jbosseap:PRD:apac)
        echo -e "\n=== Starting JbossEAP in APAC on PRD environment ==="

        echo -e "\n=== Starting with jbosseap ===\n"

        run_awx -r APAC -e PRD -p jbosseap -l jbosseap_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for JbossEAP PRD in APAC region ===\n\n"
        ;;

    jbosseap:PRD:emea)
        echo -e "\n=== Starting JbossEAP in EMEA on PRD environment ==="

        echo -e "\n=== Starting with jbosseap ===\n"

        run_awx -r EMEA -e PRD -p jbosseap -l jbosseap_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for JbossEAP PRD in EMEA region ===\n\n"
        ;;

    #
    # JDK
    #

    jdk:NonPRD:amer)
        echo -e "\n=== Starting JDK in AMER on low-environments ==="

        echo -e "\n=== Starting with jbosseap ===\n"

        run_awx -r AMER -e DEV -p jbosseap -l jbosseap_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e STG -p jbosseap -l jbosseap_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with tomcat ===\n"

        run_awx -r AMER -e DEV -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e STG -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e DEV -p tomcat -l tomcat_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e STG -p tomcat -l tomcat_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e DEV -p tomcat_ibm -l tomcat_ibm_amer_dev_mzr -u update -g iv2amer -d prod -t false -z MZR
        run_awx -r AMER -e STG -p tomcat_ibm -l tomcat_ibm_amer_stg_mzr -u update -g iv2amer -d prod -t false -z MZR

        sleep 5
        echo -e "\n=== Starting with weblogic ===\n"

        run_awx -r AMER -e DEV -p weblogic -l weblogic_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with jboss_ews ===\n"

        run_awx -r AMER -e DEV -p jboss_ews -l jboss_ews_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e STG -p jboss_ews -l jboss_ews_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for JDK Non-Prod in AMER region ===\n\n"
        ;;

    jdk:NonPRD:apac)
        echo -e "\n=== Starting JDK in APAC on low-environments ==="

        echo -e "\n=== Starting with jbosseap ===\n"

        run_awx -r APAC -e DEV -p jbosseap -l jbosseap_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e STG -p jbosseap -l jbosseap_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with tomcat ===\n"

        run_awx -r APAC -e DEV -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e STG -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e DEV -p tomcat -l tomcat_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e STG -p tomcat -l tomcat_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with weblogic ===\n"

        run_awx -r APAC -e DEV -p weblogic -l weblogic_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e STG -p weblogic -l weblogic_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with jboss_ews ===\n"

        run_awx -r APAC -e DEV -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e STG -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e DEV -p jboss_ews -l jboss_ews_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e STG -p jboss_ews -l jboss_ews_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for JDK Non-Prod in APAC region ===\n\n"
        ;;

    jdk:NonPRD:emea)
        echo -e "\n=== Starting JDK in EMEA on low-environments ==="

        echo -e "\n=== Starting with jbosseap ===\n"

        run_awx -r EMEA -e DEV -p jbosseap -l jbosseap_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p jbosseap -l jbosseap_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with tomcat ===\n"

        run_awx -r EMEA -e DEV -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e DEV -p tomcat -l tomcat_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p tomcat -l tomcat_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e DEV -p tomcat_ibmcloud_vpc -l tomcat_ibmcloud_vpc_emea_dev_mzr -u update -g MiddlewareFR -d prod -t false -z MZR
        run_awx -r EMEA -e STG -p tomcat_ibmcloud_vpc -l tomcat_ibmcloud_vpc_emea_stg_mzr -u update -g MiddlewareFR -d prod -t false -z MZR

        sleep 5
        echo -e "\n=== Starting with weblogic ===\n"

        run_awx -r EMEA -e DEV -p weblogic -l weblogic_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p weblogic -l weblogic_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with jboss_ews ===\n"

        run_awx -r EMEA -e DEV -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e DEV -p jboss_ews -l jboss_ews_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p jboss_ews -l jboss_ews_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for JDK Non-Prod in EMEA region ===\n\n"
        ;;

    jdk:PRD:amer)
        echo -e "\n=== Starting JDK in AMER on PRD environments ==="

        echo -e "\n=== Starting with jbosseap ===\n"

        run_awx -r AMER -e DEV -p jbosseap -l jbosseap_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e STG -p jbosseap -l jbosseap_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with tomcat ===\n"

        run_awx -r AMER -e PRD -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e PRD -p tomcat -l tomcat_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e PRD -p tomcat_ibm -l tomcat_ibm_amer_prd_mzr -u update -g iv2amer -d prod -t false -z MZR

        sleep 5
        echo -e "\n=== Starting with weblogic ===\n"

        run_awx -r AMER -e PRD -p weblogic -l weblogic_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with jboss_ews ===\n"

        run_awx -r AMER -e PRD -p jboss_ews -l jboss_ews_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for JDK PRD in AMER region ===\n\n"
        ;;

    jdk:PRD:apac)
        echo -e "\n=== Starting JDK in APAC on PRD environments ==="

        echo -e "\n=== Starting with jbosseap ===\n"

        run_awx -r APAC -e PRD -p jbosseap -l jbosseap_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with tomcat ===\n"

        run_awx -r APAC -e PRD -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e PRD -p tomcat -l tomcat_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with weblogic ===\n"

        run_awx -r APAC -e PRD -p weblogic -l weblogic_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with jboss_ews ===\n"

        run_awx -r APAC -e PRD -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e PRD -p jboss_ews -l jboss_ews_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for JDK PRD in APAC region ===\n\n"
        ;;

    jdk:PRD:emea)
        echo -e "\n=== Starting JDK in EMEA on PRD environments ==="

        echo -e "\n=== Starting with jbosseap ===\n"

        run_awx -r EMEA -e PRD -p jbosseap -l jbosseap_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with tomcat ===\n"

        run_awx -r EMEA -e PRD -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e PRD -p tomcat -l tomcat_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e PRD -p tomcat_ibmcloud_vpc -l tomcat_ibmcloud_vpc_emea_prd_mzr -u update -g MiddlewareFR -d prod -t false -z MZR

        sleep 5
        echo -e "\n=== Starting with weblogic ===\n"

        run_awx -r EMEA -e PRD -p weblogic -l weblogic_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with jboss_ews ===\n"

        run_awx -r EMEA -e PRD -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e PRD -p jboss_ews -l jboss_ews_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for JDK PRD in EMEA region ===\n\n"
        ;;

    #
    # TOMCAT
    #

    tomcat:NonPRD:amer)
        echo -e "\n=== Starting JDK in AMER on low-environments ==="

        echo -e "\n=== Starting with jbosseap ===\n"

        run_awx -r AMER -e DEV -p jbosseap -l jbosseap_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e STG -p jbosseap -l jbosseap_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with tomcat ===\n"

        run_awx -r AMER -e DEV -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e STG -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e DEV -p tomcat -l tomcat_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e STG -p tomcat -l tomcat_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e DEV -p tomcat_ibm -l tomcat_ibm_amer_dev_mzr -u update -g iv2amer -d prod -t false -z MZR
        run_awx -r AMER -e STG -p tomcat_ibm -l tomcat_ibm_amer_stg_mzr -u update -g iv2amer -d prod -t false -z MZR

        sleep 5
        echo -e "\n=== Starting with weblogic ===\n"

        run_awx -r AMER -e DEV -p weblogic -l weblogic_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with jboss_ews ===\n"

        run_awx -r AMER -e DEV -p jboss_ews -l jboss_ews_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e STG -p jboss_ews -l jboss_ews_amer_stg_core -u update -g iv2amer -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for JDK Non-Prod in AMER region ===\n\n"
        ;;

    tomcat:NonPRD:apac)
        echo -e "\n=== Starting tomcat in APAC on low-environments ==="

        sleep 5
        echo -e "\n=== Starting with tomcat ===\n"

        run_awx -r APAC -e DEV -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e STG -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e DEV -p tomcat -l tomcat_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e STG -p tomcat -l tomcat_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with jboss_ews ===\n"

        run_awx -r APAC -e DEV -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e STG -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e DEV -p jboss_ews -l jboss_ews_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e STG -p jboss_ews -l jboss_ews_apac_stg_core -u update -g iv2apac -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for JDK Non-Prod in APAC region ===\n\n"
        ;;

    tomcat:NonPRD:emea)
        echo -e "\n=== Starting tomcat in EMEA on low-environments ==="

        run_awx -r EMEA -e DEV -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e DEV -p tomcat -l tomcat_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p tomcat -l tomcat_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e DEV -p tomcat_ibmcloud_vpc -l tomcat_ibmcloud_vpc_emea_dev_mzr -u update -g MiddlewareFR -d prod -t false -z MZR
        run_awx -r EMEA -e STG -p tomcat_ibmcloud_vpc -l tomcat_ibmcloud_vpc_emea_stg_mzr -u update -g MiddlewareFR -d prod -t false -z MZR

        sleep 5
        echo -e "\n=== Starting with jboss_ews ===\n"

        run_awx -r EMEA -e DEV -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e DEV -p jboss_ews -l jboss_ews_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p jboss_ews -l jboss_ews_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for JDK Non-Prod in EMEA region ===\n\n"
        ;;

    tomcat:PRD:amer)
        echo -e "\n=== Starting tomcat in AMER on PRD ==="

        run_awx -r AMER -e PRD -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e PRD -p tomcat -l tomcat_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE
        run_awx -r AMER -e PRD -p tomcat_ibm -l tomcat_ibm_amer_prd_mzr -u update -g iv2amer -d prod -t false -z MZR

        sleep 5
        echo -e "\n=== Starting with jboss_ews ===\n"

        run_awx -r AMER -e PRD -p jboss_ews -l jboss_ews_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for JDK PRD in AMER region ===\n\n"
        ;;

    tomcat:PRD:apac)
        echo -e "\n=== Starting tomcat in APAC on PRD ==="

        run_awx -r APAC -e PRD -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e PRD -p tomcat -l tomcat_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE

        sleep 5
        echo -e "\n=== Starting with jboss_ews ===\n"

        run_awx -r APAC -e PRD -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE
        run_awx -r APAC -e PRD -p jboss_ews -l jboss_ews_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for tomcat PRD in APAC region ===\n\n"
        ;;

    tomcat:PRD:emea)
        echo -e "\n=== Starting Tomcat in EMEA on PRD ==="

        run_awx -r EMEA -e PRD -p dpi_upgraded_tomcat -l dpi_upgraded_tomcat_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e PRD -p tomcat -l tomcat_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e PRD -p tomcat_ibmcloud_vpc -l tomcat_ibmcloud_vpc_emea_prd_mzr -u update -g MiddlewareFR -d prod -t false -z MZR

        sleep 5
        echo -e "\n=== Starting with jboss_ews ===\n"

        run_awx -r EMEA -e PRD -p dpi_upgraded_jboss_ews -l dpi_upgraded_jboss_ews_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e PRD -p jboss_ews -l jboss_ews_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for Tomcat PRD in EMEA region ===\n\n"
        ;;

    #
    # WEBLOGIC
    #

    weblogic:NonPRD:amer)
        echo -e "\n=== Starting weblogic in AMER on low-environments ==="

        run_awx -r AMER -e DEV -p weblogic -l weblogic_amer_dev_core -u update -g iv2amer -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for weblogic Non-Prod in AMER ===\n\n\n"
        ;;

    weblogic:NonPRD:apac)
        echo -e "\n=== Starting weblogic in APAC on low-environments ==="

        run_awx -r APAC -e DEV -p weblogic -l weblogic_apac_dev_core -u update -g iv2apac -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for weblogic Non-Prod in APAC ===\n\n\n"
        ;;

    weblogic:NonPRD:emea)
        echo -e "\n=== Starting weblogic in EMEA on low-environments ==="

        run_awx -r EMEA -e DEV -p weblogic -l weblogic_emea_dev_core -u update -g MiddlewareFR -d prod -t false -z CORE
        run_awx -r EMEA -e STG -p weblogic -l weblogic_emea_stg_core -u update -g MiddlewareFR -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for weblogic Non-Prod in EMEA ===\n\n\n"
        ;;

    weblogic:PRD:amer)
        echo -e "\n=== Starting weblogic in AMER on PRD ==="

        run_awx -r AMER -e PRD -p weblogic -l weblogic_amer_prd_core -u update -g iv2amer -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for weblogic PRD in AMER ===\n\n\n"
        ;;

    weblogic:PRD:apac)
        echo -e "\n=== Starting weblogic in EMEA on PRD in APAC ==="

        run_awx -r APAC -e PRD -p weblogic -l weblogic_apac_prd_core -u update -g iv2apac -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for weblogic PRD in APAC ===\n\n\n"
        ;;

    weblogic:PRD:emea)
        echo -e "\n=== Starting weblogic in EMEA on PRD ==="

        run_awx -r EMEA -e PRD -p weblogic -l weblogic_emea_prd_core -u update -g MiddlewareFR -d prod -t false -z CORE

        echo -e "\n=== Finished all templates for weblogic PRD in EMEA ===\n\n\n"
        ;;

    *)
        echo "ERROR: Unsupported combination: ${product} ${environment} ${region^^}" >&2
        exit 4
        ;;
esac

echo
echo "Completed successfully: ${product} ${environment} ${region^^}"
