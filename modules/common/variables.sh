#!/bin/bash
VARIABLES_SH_VERSION="1.0"

# -----------------VARIAVEIS DE SISTEMA----------------------
version="V003.R001.Modular" # Added version variable
dnstesthost="google.com.br"
pve_log_folder="/var/log/pve/tasks/"
proxmoxlib="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"
distribution=$(. /etc/*-release;echo $VERSION_CODENAME)
execdir=$(dirname $0)
hostname=$(hostname)
date=$(date +%Y_%m_%d-%H_%M_%S)

# ---------------FIM DAS VARIAVEIS DE SISTEMA-----------------

# ---------------VARIAVEIS DE COR DO TERMINAL-----------------
NORMAL='\033[m'
MENU='\033[36m'      # Azul
NUMBER='\033[33m'    # Amarelo
FGRED='\033[41m'
RED_TEXT='\033[31m'
ENTER_LINE='\033[33m'
# -------------FIM VARIAVEIS DE COR DO TERMINAL---------------
