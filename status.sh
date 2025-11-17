#!/bin/bash

sudo systemctl list-units 'immich-rclone*'
sudo systemctl list-units 'immich-docker.service'

# Enhanced rclone mount checker with df output

MOUNTS_DIR="mounts"
ALERT_FOUND=false

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to format bytes to human readable
format_size() {
    local size=$1
    if [[ $size == "-" ]]; then
        echo "-"
    else
        echo "$size"
    fi
}

# Check if mounts directory exists
if [ ! -d "$MOUNTS_DIR" ]; then
    echo -e "${RED}ERROR: Directory '$MOUNTS_DIR' does not exist!${NC}"
    exit 1
fi

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              RCLONE MOUNT STATUS & USAGE                  ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo

# Print header
printf "${CYAN}%-15s %-12s %-8s %-8s %-8s %-6s %s${NC}\n" \
    "MOUNT" "STATUS" "SIZE" "USED" "AVAIL" "USE%" "FILESYSTEM"
echo -e "${BLUE}$(printf '%.65s' "$(printf '%*s' 65 '' | tr ' ' '─')")${NC}"

# Loop through all directories in mounts/
for mount_dir in "$MOUNTS_DIR"/*; do
    # Skip if no directories found (glob didn't match)
    [ ! -d "$mount_dir" ] && continue
    
    mount_name=$(basename "$mount_dir")
    
    # Check if directory is mounted
    if mountpoint -q "$mount_dir" 2>/dev/null; then
        # Get df information for mounted directory
        df_info=$(df -h "$mount_dir" | tail -n 1)
        filesystem=$(echo "$df_info" | awk '{print $1}')
        size=$(echo "$df_info" | awk '{print $2}')
        used=$(echo "$df_info" | awk '{print $3}')
        avail=$(echo "$df_info" | awk '{print $4}')
        use_percent=$(echo "$df_info" | awk '{print $5}')
        
        printf "%-15s ${GREEN}%-12s${NC} %-8s %-8s %-8s %-6s %s\n" \
            "$mount_name" "[MOUNTED]" "$size" "$used" "$avail" "$use_percent" "$filesystem"
    else
        printf "%-15s ${RED}%-12s${NC} %-8s %-8s %-8s %-6s %s\n" \
            "$mount_name" "[NOT MOUNTED]" "-" "-" "-" "-" "-"
        ALERT_FOUND=true
    fi
done

echo
echo -e "${BLUE}$(printf '%.65s' "$(printf '%*s' 65 '' | tr ' ' '─')")${NC}"

# Alert if any unmounted directories found
if [ "$ALERT_FOUND" = true ]; then
    echo -e "${RED}🚨 ALERT: One or more rclone mounts are DOWN!${NC}"
    echo -e "${YELLOW}Please check and remount the failed directories.${NC}"
    exit 1
else
    echo -e "${GREEN}✅ All rclone mounts are active and healthy.${NC}"
    exit 0
fi
