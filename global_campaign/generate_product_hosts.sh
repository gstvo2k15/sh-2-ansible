#!/usr/bin/env bash
#
# generate_apache_hosts.sh
#
# Scan all files matching "apache*" -for example- in the inventory directory,
# extract host names together with region, env and location,
# and write one output file per distinct combination:
#    apache_${REGION}_${ENV}_${LOCATION}
#
# Usage:  ./generate_apache_hosts.sh
#    (run it from the directory that contains the apache* files)

set -euo pipefail

# ------------------------------------------------------------
# Helper: trim leading/trailing whitespace (POSIX-compatible)
trim() {
    local var="$*"
    # shellcheck disable=SC2001
    printf '%s' "$(echo "$var" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
}
# ------------------------------------------------------------

# Temporary associative array to collect hosts per key.
# key = "REGION|ENV|LOCATION"
declare -A hosts_by_key

#search_dir="/apps/mdw-reporting/dpi_reports/inventories"
search_dir="/apps/mdw-reporting/dpi_reports/bitbucket_repos/elastic_inventory/inventories"
#output_dir="/apps/mdw-reporting/dpi_reports/inventories/patch_files"
output_dir="/apps/mdw-reporting/dpi_reports/patching"

date=$(date)                 # Ejemplo: Tue Dec 26 12:34:56 CET 2025

#valid values java apache, tomcat, jbossews, jbossesp, weblogic
if [[ $# -lt 1 ]]; then

    echo "Usage: $0 <product>"
    echo "Product Valids: java apache apache_sso tomcat jbossews jbosseap weblogic"
    exit 1
fi

product=$1

case "$product" in
    java|apache|apache_sso|tomcat|jbossews|jbosseap|weblogic)
        echo "Product is valid"
        ;;
    *)
        echo "product is not valid"
        echo "Product Valids:java apache apache_sso tomcat jbossews jbosseap weblogic"
        exit 1
        ;;
esac

# Process every file that matches the pattern "tomcat*" or "jbossews*" or "jbosseap*" or "weblogic*"
# in case of Java will check all files with  java products: Tomcat, jbossews, jbosseap or Weblogic

if [[ "$product" == java ]]; then
        RESULTS=$(find "$search_dir" -type f -name "tomcat.ini" -o -name "jbossews.ini" -o -name "jbosseap.ini" -o -name "weblogic.ini")
else
        # Un único patrón
        RESULTS=$(find "$search_dir" -type f -name "${product}.ini")
fi


# Process every file that matches the pattern "apache*"
for file in $RESULTS; do
#for file in "$search_dir"/"$product"*; do
    # Skip if the glob didn't match anything (e.g. when no such file)
    [[ -e "$file" ]] || continue

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Remove leading/trailing blanks - ignore completely empty lines
        line=$(trim "$line")
        [[ -z "$line" ]] && continue

        # Split the line into fields; first field is the host name
        # The rest of the line may contain the three key=value pairs in any order
        read -r host rest <<<"$line"

        # Extract the three attributes (region, env, location)
        # Using Bash pattern matching; if any attribute is missing we skip the line
        if [[ "$rest" =~ (^|[[:space:]])region=([a-zA-Z]+)($|[[:space:]]) ]]; then
            region=${BASH_REMATCH[2]}
        else
            continue
        fi

        if [[ "$rest" =~ (^|[[:space:]])env=([a-zA-Z]+)($|[[:space:]]) ]]; then
            env=${BASH_REMATCH[2]}
        else
            continue
        fi

        if [[ "$rest" =~ (^|[[:space:]])location=([a-zA-Z]+)($|[[:space:]]) ]]; then
            location=${BASH_REMATCH[2]}
        else
            continue
        fi

        # Normalise to lower-case (optional - change if you need case-sensitivity)
        region=$(echo "$region" | tr '[:upper:]' '[:lower:]')
        env=$(echo "$env" | tr '[:upper:]' '[:lower:]')
        location=$(echo "$location" | tr '[:upper:]' '[:lower:]')

        # Validate the allowed values (ignore anything else)
        case "$region" in emea|amer|apac) ;; *) continue;; esac
        case "$env"    in dev|stg|prd)    ;; *) continue;; esac
        case "$location" in core|dmzi|ets|mzr) ;; *) continue;; esac

        #Add the name as a key
        filename="$(basename "$file" | cut -d "." -f1)"

        # Build the associative-array key and append the host
        key="${filename}|${region}|${env}|${location}"
        # Preserve insertion order - we keep a space-separated list
        if [[ -z "${hosts_by_key[$key]+x}" ]]; then
            hosts_by_key["$key"]="$host"
        else
            hosts_by_key["$key"]+=$'\n'"$host"
        fi
    done <"$file"
done

# ------------------------------------------------------------
# Write the result files
for key in "${!hosts_by_key[@]}"; do
    IFS='|' read -r FILENAME REGION ENV LOCATION <<<"$key"

    echo $key

    if [[ ${product} == "java" ]]; then
        filename="${output_dir}/${product}_${FILENAME}-${REGION}-${ENV}-${LOCATION}"
    else
        filename="${output_dir}/${product}-${REGION}-${ENV}-${LOCATION}"
    fi

    {
        #echo "#$filename --- $date"
        printf "%s\n" "${hosts_by_key[$key]}"
    } >"$filename"
    echo "Created $filename"
done