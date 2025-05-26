#!/bin/bash
MODULE_VERSION="1.0" # This script itself is versioned

# Source shared variables - not strictly needed for this script as it's standalone setup
# but good for consistency if we ever add common functions here.
# source modules/common/variables.sh # Assuming it might be run from repo root

# Define colors directly for this standalone script
NORMAL='\033[m'
MENU='\033[36m'
NUMBER='\033[33m'
FGRED='\033[41m'
RED_TEXT='\033[31m'
ENTER_LINE='\033[33m'
GREEN_TEXT='\033[32m' # Added Green for success messages
YELLOW_TEXT='\033[33m' # Added Yellow for warnings

clear
echo -e "${MENU}=== Configuração da Nova Estrutura de Diretórios para Proxmox Toolkit NG ===${NORMAL}"

# Ensure script is run as root for creating directories in /
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    # No read prompt here, script should just exit.
    exit 1
fi

BASE_DIR="/TcTI/PROXMOX_TOOLKIT"
MODULES_DIR="$BASE_DIR/modules"
PVE_MODULES_DIR="$MODULES_DIR/pve"
PBS_MODULES_DIR="$MODULES_DIR/pbs"
VERSIONS_DIR="$BASE_DIR/versions"

PVE_SUBDIRS=("update" "disk" "backup" "email" "tweaks" "network" "info")
PBS_SUBDIRS=("update" "disk" "email" "tweaks" "network")

echo -e "${MENU}Criando diretório base: $BASE_DIR${NORMAL}"
mkdir -p "$BASE_DIR" || { echo -e "${RED_TEXT}Falha ao criar $BASE_DIR. Abortando.${NORMAL}"; exit 1; }

echo -e "${MENU}Criando diretório de módulos comuns: $MODULES_DIR/common${NORMAL}"
mkdir -p "$MODULES_DIR/common" || { echo -e "${RED_TEXT}Falha ao criar $MODULES_DIR/common. Abortando.${NORMAL}"; exit 1; }

echo -e "${MENU}Criando subdiretórios de módulos PVE...${NORMAL}"
for subdir in "${PVE_SUBDIRS[@]}"; do
    mkdir -p "$PVE_MODULES_DIR/$subdir" || { echo -e "${RED_TEXT}Falha ao criar $PVE_MODULES_DIR/$subdir. Abortando.${NORMAL}"; exit 1; }
done

echo -e "${MENU}Criando subdiretórios de módulos PBS...${NORMAL}"
for subdir in "${PBS_SUBDIRS[@]}"; do
    mkdir -p "$PBS_MODULES_DIR/$subdir" || { echo -e "${RED_TEXT}Falha ao criar $PBS_MODULES_DIR/$subdir. Abortando.${NORMAL}"; exit 1; }
done

echo -e "${MENU}Criando diretório de versões: $VERSIONS_DIR${NORMAL}"
mkdir -p "$VERSIONS_DIR" || { echo -e "${RED_TEXT}Falha ao criar $VERSIONS_DIR. Abortando.${NORMAL}"; exit 1; }

echo ""
echo -e "${MENU}Simulando download do proxmox-launcher.sh...${NORMAL}"
# In a real scenario, this would be:
# wget -O "$BASE_DIR/proxmox-launcher.sh" "https://raw.githubusercontent.com/TcTI-BR/PROXMOX-SCRIPTS/main/proxmox-launcher.sh"
if cp "$(dirname "$0")/proxmox-launcher.sh" "$BASE_DIR/proxmox-launcher.sh"; then
    echo -e "${GREEN_TEXT}proxmox-launcher.sh copiado para $BASE_DIR/proxmox-launcher.sh${NORMAL}"
    chmod +x "$BASE_DIR/proxmox-launcher.sh"
    echo -e "${GREEN_TEXT}Permissão de execução concedida para $BASE_DIR/proxmox-launcher.sh${NORMAL}"
else
    echo -e "${RED_TEXT}Falha ao copiar proxmox-launcher.sh. Certifique-se que 'cria-estrutura-NG.sh' está no mesmo diretório que 'proxmox-launcher.sh'.${NORMAL}"
    # exit 1 # Optionally exit if critical files are missing
fi

echo ""
echo -e "${MENU}Simulando download do versions/manifest.txt...${NORMAL}"
# In a real scenario, this would be:
# wget -O "$VERSIONS_DIR/manifest.txt" "https://raw.githubusercontent.com/TcTI-BR/PROXMOX-SCRIPTS/main/versions/manifest.txt"
if cp "$(dirname "$0")/versions/manifest.txt" "$VERSIONS_DIR/manifest.txt"; then
    echo -e "${GREEN_TEXT}manifest.txt copiado para $VERSIONS_DIR/manifest.txt${NORMAL}"
else
    echo -e "${RED_TEXT}Falha ao copiar versions/manifest.txt. Certifique-se que 'versions/manifest.txt' existe no diretório de origem.${NORMAL}"
    # exit 1 # Optionally exit
fi

# Note: The local_manifest.txt will be created by proxmox-launcher.sh on its first run if not present.
# No need to copy it here. The launcher will also "download" all modules on first run.

echo ""
echo -e "${GREEN_TEXT}=== Estrutura de Diretórios NG Criada com Sucesso! ===${NORMAL}"
echo ""
echo -e "${YELLOW_TEXT}Para iniciar o Proxmox Toolkit NG, execute:${NORMAL}"
echo -e "${GREEN_TEXT}sudo $BASE_DIR/proxmox-launcher.sh${NORMAL}"
echo ""
echo "Este script ('cria-estrutura-NG.sh') pode ser removido após a execução bem-sucedida."
read -n 1 -s -r -p "Pressione uma tecla para finalizar..."
echo ""
