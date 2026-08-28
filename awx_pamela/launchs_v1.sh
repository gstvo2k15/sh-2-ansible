#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LAUNCH_DIR="${SCRIPT_DIR}/tower_launchs"

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
USAGE
}

# Display help
if [[ $# -eq 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
    usage
    exit 0
fi

# Validate number of arguments
if [[ $# -ne 3 ]]; then
    echo "ERROR: Exactly 3 arguments are required." >&2
    echo >&2
    usage >&2
    exit 2
fi

technology="${1,,}"
environment="${2,,}"
region="${3,,}"

# Validate technology
case "$technology" in
    apache)
        technology_file="apache"
        ;;
    jbosseap)
        technology_file="jbosseap"
        ;;
    jdk)
        technology_file="jdk"
        ;;
    tomcat)
        technology_file="tomcat"
        ;;
    weblogic)
        technology_file="weblogic"
        ;;
    *)
        echo "ERROR: Invalid technology: $1" >&2
        echo >&2
        usage >&2
        exit 2
        ;;
esac

# Validate environment
case "$environment" in
    prd)
        environment_file="PRD"
        ;;
    nonprd)
        environment_file="NonPRD"
        ;;
    *)
        echo "ERROR: Invalid environment: $2" >&2
        echo >&2
        usage >&2
        exit 2
        ;;
esac

# Validate region
case "$region" in
    amer)
        region_file="amer"
        ;;
    apac)
        region_file="apac"
        ;;
    emea)
        region_file="emea"
        ;;
    *)
        echo "ERROR: Invalid region: $3" >&2
        echo >&2
        usage >&2
        exit 2
        ;;
esac

target="${LAUNCH_DIR}/launch_inventory_${technology_file}_${environment_file}_${region_file}.sh"

# Validate launch directory
if [[ ! -d "$LAUNCH_DIR" ]]; then
    echo "ERROR: Launch directory does not exist:" >&2
    echo "  $LAUNCH_DIR" >&2
    exit 3
fi

# Validate target script
if [[ ! -f "$target" ]]; then
    echo "ERROR: Target script does not exist:" >&2
    echo "  $target" >&2
    exit 3
fi

if [[ ! -r "$target" ]]; then
    echo "ERROR: Target script is not readable:" >&2
    echo "  $target" >&2
    exit 3
fi

echo "============================================================"
echo " Technology  : $technology_file"
echo " Environment : $environment_file"
echo " Region      : ${region_file^^}"
echo " Script      : $(basename "$target")"
echo "============================================================"

exec bash "$target"