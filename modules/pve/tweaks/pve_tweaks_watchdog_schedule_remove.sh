#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Remover Agendamento do Watchdog ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

WATCHDOG_SCRIPTS_DIR_PATTERN="/TcTI/SCRIPTS/WATCHDOG" # Pattern to search for in crontab

echo -e "${MENU}Esta operação removerá as entradas de agendamento do watchdog${NORMAL}"
echo -e "${MENU}que correspondem ao padrão ${YELLOW_TEXT}$WATCHDOG_SCRIPTS_DIR_PATTERN/\*\.sh${NORMAL} do crontab do root.${NORMAL}"
read -r -p "Deseja continuar com a remoção do agendamento? (s/N): " CONFIRM

if [[ "$CONFIRM" != [sS] && "$CONFIRM" != [yY] ]]; then
    echo "Remoção de agendamento cancelada."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

# Remove from crontab
if crontab -l 2>/dev/null | grep -q "$WATCHDOG_SCRIPTS_DIR_PATTERN"; then
    (crontab -l 2>/dev/null | grep -v "$WATCHDOG_SCRIPTS_DIR_PATTERN/\*\.sh") | crontab -
    if ! crontab -l 2>/dev/null | grep -q "$WATCHDOG_SCRIPTS_DIR_PATTERN"; then
        echo -e "${GREEN}Agendamento do watchdog removido com sucesso do crontab do root.${NORMAL}"
    else
        echo -e "${RED_TEXT}Falha ao remover completamente o agendamento do crontab. Verifique manualmente.${NORMAL}"
    fi
else
    echo -e "${YELLOW_TEXT}Nenhum agendamento do watchdog correspondente encontrado no crontab do root.${NORMAL}"
fi


echo ""
echo -e "${MENU}=== Remoção de agendamento do watchdog concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
