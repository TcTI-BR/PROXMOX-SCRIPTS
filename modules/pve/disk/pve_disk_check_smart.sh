#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Verificação de Status S.M.A.R.T. ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then 
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1 
fi

echo "Discos disponíveis:"
lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
echo ""
echo -e "${ENTER_LINE}Qual disco será verificado o status do SMART? EX: sda / nvme0n1${NORMAL}"
read -r TESTESMART

if [ -z "$TESTESMART" ]; then
    echo -e "${RED_TEXT}Nenhum disco especificado. Abortando.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

if [ ! -b "/dev/$TESTESMART" ]; then
    echo -e "${RED_TEXT}Disco /dev/$TESTESMART não encontrado. Verifique o nome e tente novamente.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

# Check if smartmontools is installed
if ! command -v smartctl &> /dev/null; then
    echo "smartmontools não está instalado. Tentando instalar..."
    apt update
    apt install smartmontools -y
    if ! command -v smartctl &> /dev/null; then
        echo -e "${RED_TEXT}Falha ao instalar smartmontools. Verifique manualmente.${NORMAL}"
        read -n 1 -s -r -p "Pressione uma tecla para continuar..."
        exit 1
    fi
fi

clear
echo "Verificando SMART para /dev/$TESTESMART..."
smartctl -a "/dev/$TESTESMART"

echo ""
echo -e "${MENU}=== Verificação SMART concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
