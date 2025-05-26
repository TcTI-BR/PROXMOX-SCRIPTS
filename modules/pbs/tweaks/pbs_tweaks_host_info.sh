#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh" # Adjusted path
# Uses: NORMAL, MENU, NUMBER, RED_TEXT, ENTER_LINE from variables.sh
# Uses: date (dynamic), hostname (dynamic) from variables.sh

clear
echo -e "${MENU}=== PBS: Informações do Host ===${NORMAL}"

# No root check needed for displaying information.

GREEN_TEXT=${GREEN:-$MENU} # Use GREEN if defined in variables.sh, else default to MENU color

current_date_info=$(date) # Use current date from execution
system_load=$(cat /proc/loadavg | awk '{print $1}')
memory_usage=$(free -m | awk '/Mem:/ { total=$2; used=$3 } END { printf("%3.1f%%", used/total*100)}')
logged_in_users=$(users | wc -w)
system_uptime=$(uptime | grep -ohe 'up .*' | sed 's/,/\ hours/g' | awk '{ printf $2" "$3 }')
running_processes=$(ps aux | wc -l)
host_ip=$(hostname -I | awk '{print $1}') # Main IP
root_fs_usage=$(df -h / | awk '/\// {print $(NF-1)}')
root_fs_free_space=$(df -h / | awk '/\// {print $(NF-4)}')


echo -e "${GREEN_TEXT}System information as of: ${NORMAL}$current_date_info"
echo ""
printf "${RED_TEXT}%-18s${NORMAL}: %s\t${RED_TEXT}%-18s${NORMAL}: %s\n" "System Load" "$system_load" "IP Address" "$host_ip"
printf "${RED_TEXT}%-18s${NORMAL}: %s\t${RED_TEXT}%-18s${NORMAL}: %s\n" "Memory Usage" "$memory_usage" "System Uptime" "$system_uptime"
printf "${RED_TEXT}%-18s${NORMAL}: %s\t${RED_TEXT}%-18s${NORMAL}: %s\n" "Local Users" "$logged_in_users" "Processes" "$running_processes"
echo ""
echo -e "${GREEN_TEXT}Disk information as of: ${NORMAL}$current_date_info"
echo ""
printf "${RED_TEXT}%-18s${NORMAL}: %s\t${RED_TEXT}%-18s${NORMAL}: %s\n" "Usage On /" "$root_fs_usage" "Free On /" "$root_fs_free_space"
echo ""

echo -e "${MENU}=== Exibição de informações PBS concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
