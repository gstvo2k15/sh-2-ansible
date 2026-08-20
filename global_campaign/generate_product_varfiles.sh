#!/usr/bin/env bash
#
# generate_product_varfiles.sh
#
# Scan all files matching "apache*" or other procduct in the current directory,
# apache_amer_dev_core, apache_apac_prd_dmzi, apache_emea_dev_mzr,........
#
# Usage:  ./generate_product_varfiles.sh
#    (run it from the directory that contains the apache* files)

set -euo pipefail


#valid values Java,Apache, tomcat, jbossews..
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <product> <CHANGE>"
    echo "valid <product>:java, apache, apache_sso, tomcat, jbossews, jbosseap, weblogic"
    exit 1
fi

product=$1
change=$2

# ------------------------------------------------------------
# ------------------------------------------------------------

# Directory where to check the files
#search_dir="/apps/mdw-reporting/dpi_reports/inventories/patch_files"
search_dir="/apps/mdw-reporting/dpi_reports/patching"
echo "$search_dir/$product"


# Process every file that matches the pattern "apache*"
for file in "$search_dir/$product"*; do
    # Skip if the glob didn't match anything (e.g. when no such file)
    [[ -e "$file" ]] || continue

    fileName="$(basename "$file")"

    if [[ "$product" == java ]]; then
        REST="${fileName#java*_}"
    else REST="${fileName#$product-}"        # → "amer-dev-core"
    fi

    echo $REST
    # ---------------------------------------------
    #    Strip the static prefix “tomcat_”
    # ---------------------------------------------
    #    REST="${fileName#$product_}"        # → "amer-dev-core"
    #    Split the three components using “_”
    # ---------------------------------------------
    IFS='_' read -r REGION ENVIRONMENT LOCATION <<< "$REST"

    # ---------------------------------------------
    #    Convert the **values** to upper-case
    # ---------------------------------------------
    REGION="${REGION^^}"                 # amer → AMER
    ENVIRONMENT="${ENVIRONMENT^^}"       # dev → DEV
    LOCATION="${LOCATION^^}"             # core → CORE
    printf "REGION      = %s\n" "$REGION"
    printf "ENVIRONMENT = %s\n" "$ENVIRONMENT"
    printf "LOCATION    = %s\n" "$LOCATION"

    #if LOCATION is MZR the force LOCATION to CORE
    if [[ $LOCATION == "MZR" ]]; then LOCATION="CORE"; fi
    echo $LOCATION


    #launch the generate_varfile.sh previous to lauch the patching activity
    /apps/patching/plat/generate_varfile.sh -file $file -location $LOCATION -patch_product $product
    echo ""
done

FLD=/apps/patching/plat/vars
if [[ "$product" == apache_sso ]]; then
        sed -i 's/apache_sso/apache/g' $FLD/apache_sso-*
fi

# ------------------------------------------------------------
echo "All done."
