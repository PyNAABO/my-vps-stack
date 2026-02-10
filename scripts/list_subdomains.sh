#!/bin/bash

# Define colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
APPS_DIR="$SCRIPT_DIR/../apps"

echo -e "${BLUE}🔍 Scanning for configured subdomains in $APPS_DIR...${NC}"
echo "---------------------------------------------------"
printf "%-15s %-25s %-25s\n" "APP" "SUBDOMAIN" "TARGET"
echo "---------------------------------------------------"

# Loop through ingress.yml files
for ingress_file in "$APPS_DIR"/*/ingress.yml; do
    if [ -f "$ingress_file" ]; then
        app_name=$(basename "$(dirname "$ingress_file")")
        
        # Extract hostname and service
        raw_hostname=$(grep "^hostname:" "$ingress_file" | awk '{print $2}')
        raw_service=$(grep "^service:" "$ingress_file" | awk '{print $2}')
        
        # Remove carriage returns using pure bash
        hostname=${raw_hostname//$'\r'/}
        service=${raw_service//$'\r'/}
        
        if [ -n "$hostname" ]; then
            # Use awk for reliable formatting
            echo "$app_name ${hostname}.* -> $service" | awk '{printf "\033[0;32m%-15s\033[0m %-25s \033[0;34m%-25s\033[0m\n", $1, $2, $3 " " $4}'
        fi
    fi
done

echo "---------------------------------------------------"
