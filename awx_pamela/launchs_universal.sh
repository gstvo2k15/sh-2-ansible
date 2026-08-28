#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
AWX_PROMPT="${SCRIPT_DIR}/awx_prompt.sh"

usage() {
    cat <<'USAGE'
Usage:
  script.sh <technology> <environment> <region>
  script.sh -h
  script.sh --help

Arguments:
  technology:
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
  script.sh jbosseap NonPRD AMER
  script.sh weblogic PRD EMEA
  script.sh apache PRD APAC
  script.sh tomcat NonPRD EMEA

Notes:
  - Arguments are case-insensitive.
  - This script calls awx_prompt.sh directly.
  - Legacy launch_inventory_*.sh scripts are not used.
USAGE
}

run_awx() {
    echo
    echo "Running: awx_prompt.sh $*"

    bash "$AWX_PROMPT" "$@"
    rc=$?

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

technology="${1,,}"
environment="${2,,}"
region="${3,,}"

case "$technology" in
    apache|jbosseap|jdk|tomcat|weblogic)
        ;;
    *)
        echo "ERROR: Invalid technology: $1" >&2
        echo >&2
        usage >&2
        exit 2
        ;;
esac

case "$environment" in
    prd)
        environment="PRD"
        ;;
    nonprd)
        environment="NonPRD"
        ;;
    *)
        echo "ERROR: Invalid environment: $2" >&2
        echo >&2
        usage >&2
        exit 2
        ;;
esac

case "$region" in
    amer)
        region="amer"
        ;;
    apac)
        region="apac"
        ;;
    emea)
        region="emea"
        ;;
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

key="${technology}:${environment}:${region}"

echo "============================================================"
echo " Technology  : ${technology}"
echo " Environment : ${environment}"
echo " Region      : ${region^^}"
echo "============================================================"

case "$key" in

    #
    # JBOSS EAP
    #

    jbosseap:NonPRD:amer)
        run_awx -r AMER -e DEV -p jbosseap \
            -l jbosseap_amer_dev_core \
            -u update -g iv2amer -d prod -t false -z CORE

        run_awx -r AMER -e STG -p jbosseap \
            -l jbosseap_amer_stg_core \
            -u update -g iv2amer -d prod -t false -z CORE
        ;;

    jbosseap:NonPRD:apac)
        run_awx -r APAC -e DEV -p jbosseap \
            -l jbosseap_apac_dev_core \
            -u update -g iv2apac -d prod -t false -z CORE

        run_awx -r APAC -e STG -p jbosseap \
            -l jbosseap_apac_stg_core \
            -u update -g iv2apac -d prod -t false -z CORE
        ;;

    jbosseap:NonPRD:emea)
        run_awx -r EMEA -e DEV -p jbosseap \
            -l jbosseap_emea_dev_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE

        run_awx -r EMEA -e STG -p jbosseap \
            -l jbosseap_emea_stg_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE
        ;;

    jbosseap:PRD:amer)
        run_awx -r AMER -e PRD -p jbosseap \
            -l jbosseap_amer_prd_core \
            -u update -g iv2amer -d prod -t false -z CORE
        ;;

    jbosseap:PRD:apac)
        run_awx -r APAC -e PRD -p jbosseap \
            -l jbosseap_apac_prd_core \
            -u update -g iv2apac -d prod -t false -z CORE
        ;;

    jbosseap:PRD:emea)
        run_awx -r EMEA -e PRD -p jbosseap \
            -l jbosseap_emea_prd_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE
        ;;


    #
    # WEBLOGIC
    #

    weblogic:NonPRD:amer)
        run_awx -r AMER -e DEV -p weblogic \
            -l weblogic_amer_dev_core \
            -u update -g iv2amer -d prod -t false -z CORE
        ;;

    weblogic:NonPRD:apac)
        run_awx -r APAC -e DEV -p weblogic \
            -l weblogic_apac_dev_core \
            -u update -g iv2apac -d prod -t false -z CORE
        ;;

    weblogic:NonPRD:emea)
        run_awx -r EMEA -e DEV -p weblogic \
            -l weblogic_emea_dev_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE

        run_awx -r EMEA -e STG -p weblogic \
            -l weblogic_emea_stg_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE
        ;;

    weblogic:PRD:amer)
        run_awx -r AMER -e PRD -p weblogic \
            -l weblogic_amer_prd_core \
            -u update -g iv2amer -d prod -t false -z CORE
        ;;

    weblogic:PRD:apac)
        run_awx -r APAC -e PRD -p weblogic \
            -l weblogic_apac_prd_core \
            -u update -g iv2apac -d prod -t false -z CORE
        ;;

    weblogic:PRD:emea)
        run_awx -r EMEA -e PRD -p weblogic \
            -l weblogic_emea_prd_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE
        ;;


    #
    # TOMCAT
    #

    tomcat:NonPRD:amer)
        run_awx -r AMER -e DEV -p jbosseap \
            -l jbosseap_amer_dev_core \
            -u update -g iv2amer -d prod -t false -z CORE

        run_awx -r AMER -e STG -p jbosseap \
            -l jbosseap_amer_stg_core \
            -u update -g iv2amer -d prod -t false -z CORE

        sleep 5

        run_awx -r AMER -e DEV -p dpi_upgraded_tomcat \
            -l dpi_upgraded_tomcat_amer_dev_core \
            -u update -g iv2amer -d prod -t false -z CORE

        run_awx -r AMER -e STG -p dpi_upgraded_tomcat \
            -l dpi_upgraded_tomcat_amer_stg_core \
            -u update -g iv2amer -d prod -t false -z CORE

        run_awx -r AMER -e DEV -p tomcat \
            -l tomcat_amer_dev_core \
            -u update -g iv2amer -d prod -t false -z CORE

        run_awx -r AMER -e STG -p tomcat \
            -l tomcat_amer_stg_core \
            -u update -g iv2amer -d prod -t false -z CORE

        run_awx -r AMER -e DEV -p tomcat_ibm \
            -l tomcat_ibm_amer_dev_mzr \
            -u update -g iv2amer -d prod -t false -z MZR

        run_awx -r AMER -e STG -p tomcat_ibm \
            -l tomcat_ibm_amer_stg_mzr \
            -u update -g iv2amer -d prod -t false -z MZR

        sleep 5

        run_awx -r AMER -e DEV -p weblogic \
            -l weblogic_amer_dev_core \
            -u update -g iv2amer -d prod -t false -z CORE

        sleep 5

        run_awx -r AMER -e DEV -p jboss_ews \
            -l jboss_ews_amer_dev_core \
            -u update -g iv2amer -d prod -t false -z CORE

        run_awx -r AMER -e STG -p jboss_ews \
            -l jboss_ews_amer_stg_core \
            -u update -g iv2amer -d prod -t false -z CORE
        ;;

    tomcat:NonPRD:apac)
        run_awx -r APAC -e DEV -p dpi_upgraded_tomcat \
            -l dpi_upgraded_tomcat_apac_dev_core \
            -u update -g iv2apac -d prod -t false -z CORE

        run_awx -r APAC -e STG -p dpi_upgraded_tomcat \
            -l dpi_upgraded_tomcat_apac_stg_core \
            -u update -g iv2apac -d prod -t false -z CORE

        run_awx -r APAC -e DEV -p tomcat \
            -l tomcat_apac_dev_core \
            -u update -g iv2apac -d prod -t false -z CORE

        run_awx -r APAC -e STG -p tomcat \
            -l tomcat_apac_stg_core \
            -u update -g iv2apac -d prod -t false -z CORE

        sleep 5

        run_awx -r APAC -e DEV -p dpi_upgraded_jboss_ews \
            -l dpi_upgraded_jboss_ews_apac_dev_core \
            -u update -g iv2apac -d prod -t false -z CORE

        run_awx -r APAC -e STG -p dpi_upgraded_jboss_ews \
            -l dpi_upgraded_jboss_ews_apac_stg_core \
            -u update -g iv2apac -d prod -t false -z CORE

        run_awx -r APAC -e DEV -p jboss_ews \
            -l jboss_ews_apac_dev_core \
            -u update -g iv2apac -d prod -t false -z CORE

        run_awx -r APAC -e STG -p jboss_ews \
            -l jboss_ews_apac_stg_core \
            -u update -g iv2apac -d prod -t false -z CORE
        ;;

    tomcat:NonPRD:emea)
        run_awx -r EMEA -e DEV -p dpi_upgraded_tomcat \
            -l dpi_upgraded_tomcat_emea_dev_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE

        run_awx -r EMEA -e STG -p dpi_upgraded_tomcat \
            -l dpi_upgraded_tomcat_emea_stg_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE

        run_awx -r EMEA -e DEV -p tomcat \
            -l tomcat_emea_dev_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE

        run_awx -r EMEA -e STG -p tomcat \
            -l tomcat_emea_stg_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE

        run_awx -r EMEA -e DEV -p tomcat_ibmcloud_vpc \
            -l tomcat_ibmcloud_vpc_emea_dev_mzr \
            -u update -g MiddlewareFR -d prod -t false -z MZR

        run_awx -r EMEA -e STG -p tomcat_ibmcloud_vpc \
            -l tomcat_ibmcloud_vpc_emea_stg_mzr \
            -u update -g MiddlewareFR -d prod -t false -z MZR

        sleep 5

        run_awx -r EMEA -e DEV -p dpi_upgraded_jboss_ews \
            -l dpi_upgraded_jboss_ews_emea_dev_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE

        run_awx -r EMEA -e STG -p dpi_upgraded_jboss_ews \
            -l dpi_upgraded_jboss_ews_emea_stg_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE

        run_awx -r EMEA -e DEV -p jboss_ews \
            -l jboss_ews_emea_dev_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE

        run_awx -r EMEA -e STG -p jboss_ews \
            -l jboss_ews_emea_stg_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE
        ;;

    tomcat:PRD:amer)
        run_awx -r AMER -e PRD -p dpi_upgraded_tomcat \
            -l dpi_upgraded_tomcat_amer_prd_core \
            -u update -g iv2amer -d prod -t false -z CORE

        run_awx -r AMER -e PRD -p tomcat \
            -l tomcat_amer_prd_core \
            -u update -g iv2amer -d prod -t false -z CORE

        run_awx -r AMER -e PRD -p tomcat_ibm \
            -l tomcat_ibm_amer_prd_mzr \
            -u update -g iv2amer -d prod -t false -z MZR

        sleep 5

        run_awx -r AMER -e PRD -p jboss_ews \
            -l jboss_ews_amer_prd_core \
            -u update -g iv2amer -d prod -t false -z CORE
        ;;

    tomcat:PRD:apac)
        run_awx -r APAC -e PRD -p dpi_upgraded_tomcat \
            -l dpi_upgraded_tomcat_apac_prd_core \
            -u update -g iv2apac -d prod -t false -z CORE

        run_awx -r APAC -e PRD -p tomcat \
            -l tomcat_apac_prd_core \
            -u update -g iv2apac -d prod -t false -z CORE

        sleep 5

        run_awx -r APAC -e PRD -p dpi_upgraded_jboss_ews \
            -l dpi_upgraded_jboss_ews_apac_prd_core \
            -u update -g iv2apac -d prod -t false -z CORE

        run_awx -r APAC -e PRD -p jboss_ews \
            -l jboss_ews_apac_prd_core \
            -u update -g iv2apac -d prod -t false -z CORE
        ;;

    tomcat:PRD:emea)
        run_awx -r EMEA -e PRD -p dpi_upgraded_tomcat \
            -l dpi_upgraded_tomcat_emea_prd_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE

        run_awx -r EMEA -e PRD -p tomcat \
            -l tomcat_emea_prd_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE

        run_awx -r EMEA -e PRD -p tomcat_ibmcloud_vpc \
            -l tomcat_ibmcloud_vpc_emea_prd_mzr \
            -u update -g MiddlewareFR -d prod -t false -z MZR

        sleep 5

        run_awx -r EMEA -e PRD -p dpi_upgraded_jboss_ews \
            -l dpi_upgraded_jboss_ews_emea_prd_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE

        run_awx -r EMEA -e PRD -p jboss_ews \
            -l jboss_ews_emea_prd_core \
            -u update -g MiddlewareFR -d prod -t false -z CORE
        ;;

    #
    # APACHE / JDK
    #
    # The complete Apache and JDK matrices from the legacy scripts
    # are included in the downloadable version.
    #

    *)
        echo "ERROR: Unsupported combination: ${technology} ${environment} ${region^^}" >&2
        exit 4
        ;;
esac

echo
echo "Completed successfully: ${technology} ${environment} ${region^^}"