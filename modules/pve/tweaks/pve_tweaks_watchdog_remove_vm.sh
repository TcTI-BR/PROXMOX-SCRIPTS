#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Remover VM do Monitoramento do Watchdog ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

WATCHDOG_SCRIPTS_DIR="/TcTI/SCRIPTS/WATCHDOG" # As per original script logic

if [ ! -d "$WATCHDOG_SCRIPTS_DIR" ]; then
    echo -e "${YELLOW_TEXT}Diretório de scripts do watchdog ($WATCHDOG_SCRIPTS_DIR) não encontrado.${NORMAL}"
    echo "Nenhuma VM parece estar configurada para monitoramento."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

echo "Scripts de watchdog existentes (VM IDs):"
if ! ls -1qA "$WATCHDOG_SCRIPTS_DIR"/*.sh &>/dev/null; then
     echo -e "${YELLOW_TEXT}Nenhum script .sh encontrado no diretório $WATCHDOG_SCRIPTS_DIR.${NORMAL}"
     read -n 1 -s -r -p "Pressione uma tecla para continuar..."
     exit 0
fi
ls -1 "$WATCHDOG_SCRIPTS_DIR"/*.sh | sed "s|$WATCHDOG_SCRIPTS_DIR/||; s/\.sh$//"
echo ""

echo -e "${ENTER_LINE}Qual ID da VM (nome do script sem .sh) a ser removida do monitoramento?${NORMAL}"
read -r WATCHDOGVMIDDEL
if [ -z "$WATCHDOGVMIDDEL" ]; then
    echo -e "${RED_TEXT}Nenhum ID de VM especificado. Abortando.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

VM_WATCHDOG_SCRIPT="$WATCHDOG_SCRIPTS_DIR/$WATCHDOGVMIDDEL.sh"

if [ -f "$VM_WATCHDOG_SCRIPT" ]; then
    read -r -p "Tem certeza que deseja remover o script $VM_WATCHDOG_SCRIPT? (s/N): " CONFIRM
    if [[ "$CONFIRM" == [sS] || "$CONFIRM" == [yY] ]]; then
        rm -f "$VM_WATCHDOG_SCRIPT"
        if [ ! -f "$VM_WATCHDOG_SCRIPT" ]; then
            echo -e "${GREEN}Script de watchdog $VM_WATCHDOG_SCRIPT removido com sucesso.${NORMAL}"
        else
            echo -e "${RED_TEXT}Falha ao remover o script $VM_WATCHDOG_SCRIPT. Verifique as permissões.${NORMAL}"
        fi
    else
        echo "Remoção cancelada pelo usuário."
    fi
else
    echo -e "${YELLOW_TEXT}Script de watchdog $VM_WATCHDOG_SCRIPT não encontrado.${NORMAL}"
fi

echo ""
echo -e "${MENU}=== Remoção de VM do watchdog concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
