#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Listar VMs Monitoradas pelo Watchdog ===${NORMAL}"

# No root check needed for listing files, unless directory has restricted access
WATCHDOG_SCRIPTS_DIR="/TcTI/SCRIPTS/WATCHDOG" # As per original script logic

if [ ! -d "$WATCHDOG_SCRIPTS_DIR" ]; then
    echo -e "${YELLOW_TEXT}Diretório de scripts do watchdog ($WATCHDOG_SCRIPTS_DIR) não encontrado.${NORMAL}"
    echo "Nenhuma VM está sendo monitorada ou o diretório foi removido."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

echo -e "${MENU}VMs atualmente com scripts de watchdog em $WATCHDOG_SCRIPTS_DIR:${NORMAL}"
if ls -1qA "$WATCHDOG_SCRIPTS_DIR"/*.sh &>/dev/null; then
    ls -lt "$WATCHDOG_SCRIPTS_DIR"/*.sh | awk '{print $9}' | sed "s|$WATCHDOG_SCRIPTS_DIR/||; s/\.sh$//"
else
    echo -e "${YELLOW_TEXT}Nenhum script .sh encontrado no diretório $WATCHDOG_SCRIPTS_DIR.${NORMAL}"
    echo "Nenhuma VM parece estar sendo monitorada."
fi

echo ""
echo -e "${MENU}=== Listagem concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
