#!/usr/bin/env bash

# ------------------------------------------------------------
# run_product_scripts.sh
#
# Calls:
#   1️⃣ generate_product_hosts.sh   → arguments: <product>
#   2️⃣ generate_product_varfiles.sh → argument:   <product> <change>
#
# Usage:
#   ./run_product_scripts.sh <product> <change>
# ------------------------------------------------------------

# ---- Paths to the scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOSTS_SCRIPT="${SCRIPT_DIR}/generate_product_hosts.sh"
VARFILES_SCRIPT="${SCRIPT_DIR}/generate_product_varfiles.sh"


# ---- Argument validation ------------------------------------
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <product> <change>"
    echo "Product Valids:java apache apache_sso tomcat jbossews jbosseap"
    exit 1
fi

PRODUCT=$1
CHANGE=$2

#Validation of products
case "$PRODUCT" in
    java|apache|apache_sso|tomcat|jbossews|jbosseap)
        echo "Product is valid"
        ;;
    *)
        echo "product is not valid"
        echo "Product Valids: apache apache_sso tomcat jbossews jbosseap"
        exit 1
        ;;
esac


# ---- Verify that the scripts exist and are executable --------
if [[ ! -x "$HOSTS_SCRIPT" ]]; then
    echo "Error: $HOSTS_SCRIPT not found or not executable"
    exit 2
fi

if [[ ! -x "$VARFILES_SCRIPT" ]]; then
    echo "Error: $VARFILES_SCRIPT not found or not executable"
    exit 3
fi

# ---- Run generate_product_hosts.sh ---------------------------
echo "Running $HOSTS_SCRIPT with product='$PRODUCT' and change='$CHANGE'..."
"$HOSTS_SCRIPT" "$PRODUCT"
HOSTS_EXIT=$?

if [[ $HOSTS_EXIT -ne 0 ]]; then
    echo "Script $HOSTS_SCRIPT exited with error (code $HOSTS_EXIT)."
    exit $HOSTS_EXIT
fi

# ---- Run generate_product_varfiles.sh ------------------------
echo "Running $VARFILES_SCRIPT with product='$PRODUCT'..."
"$VARFILES_SCRIPT" "$PRODUCT" "$CHANGE"
VARFILES_EXIT=$?

if [[ $VARFILES_EXIT -ne 0 ]]; then
    echo "Script $VARFILES_SCRIPT exited with error (code $VARFILES_EXIT)."
    echo ""
    exit $VARFILES_EXIT
fi


echo "Both scripts completed successfully."
exit 0