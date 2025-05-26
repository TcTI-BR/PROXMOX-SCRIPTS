#!/bin/bash
MODULE_VERSION="1.1" # Incremented version

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== PVE: Desinstalar Script Proxmox Toolkit NG de Execução no Login ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

PROFILE_SCRIPT_PATH="/etc/profile.d/proxmox-toolkit-launcher.sh" # New name, must match install script

echo -e "${MENU}Este script removerá o arquivo:${NORMAL}"
echo -e "${YELLOW_TEXT}$PROFILE_SCRIPT_PATH${NORMAL}"
echo -e "${MENU}que faz o Proxmox Toolkit NG iniciar automaticamente no login do root.${NORMAL}"
read -r -p "Deseja continuar com a desinstalação? (s/N): " CONFIRM

if [[ "$CONFIRM" != [sS] && "$CONFIRM" != [yY] ]]; then
    echo "Desinstalação cancelada pelo usuário."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

if [ -f "$PROFILE_SCRIPT_PATH" ]; then
    rm -f "$PROFILE_SCRIPT_PATH"
    if [ ! -f "$PROFILE_SCRIPT_PATH" ]; then
        echo -e "${GREEN_TEXT}Script $PROFILE_SCRIPT_PATH removido com sucesso.${NORMAL}"
        echo "O Proxmox Toolkit NG não será mais iniciado automaticamente no login do root."
    else
        echo -e "${RED_TEXT}Falha ao remover $PROFILE_SCRIPT_PATH. Verifique as permissões.${NORMAL}"
    fi
else
    echo -e "${YELLOW_TEXT}Script $PROFILE_SCRIPT_PATH não encontrado. Nenhuma ação realizada.${NORMAL}"
fi

echo ""
echo -e "${MENU}=== Desinstalação de script no login PVE concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
