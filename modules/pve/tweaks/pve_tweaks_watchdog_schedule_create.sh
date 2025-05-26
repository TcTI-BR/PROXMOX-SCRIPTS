#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Criar Agendamento do Watchdog (10 em 10 minutos) ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

WATCHDOG_SCRIPTS_DIR="/TcTI/SCRIPTS/WATCHDOG" # As per original script logic
CRON_JOB_LINE="*/10 * * * * $WATCHDOG_SCRIPTS_DIR/*.sh" # This will try to run all .sh in that dir

echo -e "${MENU}Esta operação adicionará uma entrada ao crontab do root para executar${NORMAL}"
echo -e "${MENU}scripts no diretório ${YELLOW_TEXT}$WATCHDOG_SCRIPTS_DIR/*.sh${NORMAL} a cada 10 minutos.${NORMAL}"
echo -e "${RED_TEXT}AVISO: Certifique-se que os scripts em $WATCHDOG_SCRIPTS_DIR são seguros e testados.${NORMAL}"
read -r -p "Deseja continuar com a criação do agendamento? (s/N): " CONFIRM

if [[ "$CONFIRM" != [sS] && "$CONFIRM" != [yY] ]]; then
    echo "Criação de agendamento cancelada."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

# Ensure the WATCHDOG_SCRIPTS_DIR exists, as cron job points to it
mkdir -p "$WATCHDOG_SCRIPTS_DIR"
echo "Diretório $WATCHDOG_SCRIPTS_DIR assegurado."

# Add to crontab
# Remove existing identified by the path part to avoid multiple similar general rules, then add new one
(crontab -l 2>/dev/null | grep -v "$WATCHDOG_SCRIPTS_DIR/\*\.sh" ; echo "$CRON_JOB_LINE") | crontab -

if crontab -l | grep -q "$WATCHDOG_SCRIPTS_DIR/\*\.sh"; then
    echo -e "${GREEN}Agendamento do watchdog criado/atualizado com sucesso no crontab do root.${NORMAL}"
    echo "Executará: $CRON_JOB_LINE"
else
    echo -e "${RED_TEXT}Falha ao adicionar o agendamento ao crontab.${NORMAL}"
fi

echo ""
echo -e "${MENU}=== Criação de agendamento do watchdog concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
