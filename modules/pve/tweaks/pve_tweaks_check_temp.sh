#!/bin/bash
PVE_TWEAKS_CHECK_TEMP_SH_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Verificação de Temperatura ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then 
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1 
fi

echo "Instalando lm-sensors (se necessário)..."
apt install lm-sensors -y

echo ""
echo "Iniciando monitoramento de temperatura com 'watch -n 1 sensors'."
echo "Pressione Ctrl+C para sair do monitoramento e retornar ao menu."
read -n 1 -s -r -p "Pressione uma tecla para iniciar..."

watch -n 1 sensors

echo ""
echo -e "${MENU}=== Monitoramento de temperatura concluído. ===${NORMAL}"
# No "Pressione uma tecla para continuar..." here as 'watch' needs to be exited first.
# The launcher will handle the next menu display.
