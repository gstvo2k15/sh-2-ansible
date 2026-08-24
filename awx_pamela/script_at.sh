#!/bin/bash
# ------------------------------------------------------------
# Script name : script_at.sh
# Version     : 1.8
# Description :
#   • Reads a CHANGE id (argument or interactive)
#   • Asks for the product (java, tomcat, jbossews or jbosseap or apache) - only one at a time
#   • Asks for the target environment (NonPRD i.e. DEV|STG - PRD is not allowed)
#   • Lets the user choose which regions to process (EMEA, APAC, AMER or ALL)
#   • Requests the date-time for the first at job
#   • Lets the user pick the interval between successive jobs (15, 30, 45 or 60 min)
#   • Shows a summary and asks for final confirmation before scheduling
#   • For each matching *.yml file schedules the patch command with at
#   • All actions are logged to /apps/patching/plat/logs/run-patch-linux-$(date).log
#   • Provides a "--help" option that prints usage information.
# ------------------------------------------------------------

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    cat <<EOF
Usage: $(basename "$0") [CHANGE_ID]

    If CHANGE_ID is not supplied it will be requested interactively.

    The script will then:
      1) Ask for the product (java, tomcat, jbossews or jbosseap or apache)
      2) Ask for the environment to target (NonPRD (equals to DEV|STG) or PRD (require validate confirmation))
      3) Ask which regions to include (EMEA, APAC, AMER or ALL)
      4) Ask for the first execution time (format: HH:MM DD.MM.YYYY)
      5) Ask for the interval between jobs (15, 30, 45 or 60 minutes)
      6) Show a summary and ask for final confirmation
      7) Schedule a patch command for each matching *.yml file with 'at'
      8) Write a detailed log under /apps/patching/plat/logs/

    Options:
      --help, -h   Show this help message and exit

    Version: 2.2
EOF
    exit 0
fi

if [[ -n $1 ]]; then
    CHANGE=$1
else
    read -p "Enter CHANGE identifier: " CHANGE
fi

PATH_FILES="/apps/patching/plat/vars"

CHECK_CHANGE=$(
    ls -ltr "$PATH_FILES" \
    | grep "$CHANGE"
)

if [[ -z $CHECK_CHANGE ]]; then
    echo "Error: Incorrect change $CHANGE parsed! Does not exist in vars path in yml files."
    exit 1
fi


while true; do
    read -p "Enter product to include (java, tomcat, jbossews or jbosseap or apache): " PRODUCT_CHOICE
    case "$PRODUCT_CHOICE" in
        java|tomcat|jbossews|jbosseap|apache) break ;;
        *) echo "Invalid product. Choose java, tomcat, jbossews or jbosseap or apache." ;;
    esac
done


while true; do
    read -p "Select environment (NonPRD or PRD [PRD requires confirmation]): " ENV_CHOICE
    case "${ENV_CHOICE,,}" in
        nonprd)
            ENV_GREP="DEV|STG"
            break
            ;;
        prd)
            read -p "You selected PRD. Are you really sure? (yes/no): " CONFIRM
            if [[ "${CONFIRM,,}" == "yes" ]]; then
                ENV_GREP="PRD"
                break
            else
                echo "PRD not confirmed - please choose the environment again."
            fi
            ;;
        *)
            echo "Invalid choice. Type exactly NonPRD or PRD."
            ;;
    esac
done


read -p "Enter regions to include (comma separated, e.g. EMEA,APAC or AMER): " REG_INPUT

if [[ "$REG_INPUT" =~ ^[Aa][Ll][Ll]$ ]]; then
    REG_LIST=("EMEA" "APAC" "AMER")
else
    IFS=',' read -ra REG_ARR <<<"$REG_INPUT"
    REG_LIST=()
    for r in "${REG_ARR[@]}"; do
        r=$(echo "$r" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
        case "$r" in
            EMEA|APAC|AMER) REG_LIST+=("$r") ;;
            *) echo "Region $r not recognised - it will be ignored" ;;
        esac
    done
    if [[ ${#REG_LIST[@]} -eq 0 ]]; then
        echo "No valid region entered - aborting."
        exit 1
    fi
fi

REGION_PATTERN=""

for region in "${REG_LIST[@]}"; do
    region=$(printf '%s' "$region" | tr '[:upper:]' '[:lower:]')

    if [[ -z "$REGION_PATTERN" ]]; then
        REGION_PATTERN="$region"
    else
        REGION_PATTERN+="${REGION_PATTERN:+|}${region}"
    fi
done


LOG_FOLD="/apps/patching/plat/logs"
mkdir -p "$LOG_FOLD"
logfile="$LOG_FOLD/run-patch-linux-$(date +%Y-%d-%m_%Hh%M).log"

read -p "Enter first execution time (HH:MM): " AT_TIME
read -p "Enter first execution date (DD.MM.YYYY): " AT_DATE
day=$(echo "$AT_DATE" | cut -d. -f1)
month=$(echo "$AT_DATE" | cut -d. -f2)
year=$(echo "$AT_DATE" | cut -d. -f3)
date_string="${year}-${month}-${day} ${AT_TIME}"
first_ts=$(date -d "$date_string" +%s 2>/dev/null) || {
    echo "Invalid date/time format - tried to parse '$date_string'"
    exit 1
}

echo "Select interval between successive jobs:"
echo "1) 15 minutes"
echo "2) 30 minutes"
echo "3) 45 minutes"
echo "4) 60 minutes"
read -p "Option [1-4]: " INT_OPT
case "$INT_OPT" in
    1) interval=$((15*60)); interval_min=15 ;;
    2) interval=$((30*60)); interval_min=30 ;;
    3) interval=$((45*60)); interval_min=45 ;;
    4) interval=$((60*60)); interval_min=60 ;;
    *) echo "Invalid option - defaulting to 15 minutes" ; interval=$((15*60)); interval_min=15 ;;
esac


if [[ "$PRODUCT_CHOICE" == java ]]; then
    CHECK=$(
        ls -1 "$PATH_FILES" \
        | grep -F "$CHANGE" \
        | grep -i -E "^${PRODUCT_CHOICE}_(jbosseap|jbossews|tomcat|weblogic)-(${REGION_PATTERN})-(${ENV_GREP})" \
        | sort -u
    )
else CHECK=$(
        ls -1 "$PATH_FILES" \
        | grep -F "$CHANGE" \
        | grep -i -E "^${PRODUCT_CHOICE}-(${REGION_PATTERN})-(${ENV_GREP})" \
        | sort -u
    )
fi


if [[ -z $CHECK ]]; then
    echo "Error: no files found for the combination you provided."
    exit 1
fi


# ------------------------------------------------------------
#   Build an array that holds “file | scheduled-time” for every file
# ------------------------------------------------------------
sched=()
cnt=0
for file in $CHECK; do
    ((cnt++))
    # epoch for this file = first execution + (cnt-1) * interval
    exec_ts=$((first_ts + (cnt-1)*interval))
    at_time=$(date -d "@$exec_ts" +"%H:%M %d.%m.%Y")
    sched+=(" $file|$at_time")
done

# ------------------------------------------------------------
#   Show the **full** summary (file + time)
# ------------------------------------------------------------
echo
echo "==================== SUMMARY ===================="
echo "CHANGE          : $CHANGE"
echo "PRODUCT         : $PRODUCT_CHOICE"
echo "ENVIRONMENT     : $ENV_CHOICE ($ENV_GREP)"
echo "REGIONS         : ${REG_LIST[*]}"
echo "First execution : $AT_TIME $AT_DATE"
echo "Interval        : $interval_min minute(s)"
echo "Files to be scheduled (${#sched[@]}):"

for entry in "${sched[@]}"; do
    f=${entry%%|*}          # part before the '|'
    t=${entry##*|}          # part after the '|'
    printf "  %-70s %s\n" "$f" "$t"
done
echo "================================================="
read -p "Proceed with scheduling the above jobs? (yes/no): " CONFIRM_ALL
if [[ "$CONFIRM_ALL" != "yes" ]]; then
    echo "Aborted by user."
    exit 0
fi

# ------------------------------------------------------------
#   Actually submit the jobs - reuse the same array
# ------------------------------------------------------------
for entry in "${sched[@]}"; do
    f=${entry%%|*}
    t=${entry##*|}

    cmd="cd /apps/patching/plat && /apps/patching/plat/run_patch_template.sh -varfile $PATH_FILES/$f"
    {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Scheduling $f at $t"
        echo "$cmd" | at "$t"
        if [[ $? -eq 0 ]]; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $f scheduled"
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: scheduling $f failed"
            exit 1
        fi
    } >>"$logfile" 2>&1
done

echo -e "\nAll jobs have been scheduled. Details are in $logfile"

exit 0