#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Verificação de Setores Defeituosos ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then 
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1 
fi

echo "Discos disponíveis:"
lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
echo ""
echo -e "${ENTER_LINE}Qual disco será testado os setores? EX: sda / nvme0n1${NORMAL}"
read -r TESTESETORES

if [ -z "$TESTESETORES" ]; then
    echo -e "${RED_TEXT}Nenhum disco especificado. Abortando.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

if [ ! -b "/dev/$TESTESETORES" ]; then
    echo -e "${RED_TEXT}Disco /dev/$TESTESETORES não encontrado. Verifique o nome e tente novamente.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

clear
echo -e "${RED_TEXT}AVISO: A verificação de setores pode ser demorada e intensiva em I/O.${NORMAL}"
read -r -p "Deseja continuar com a verificação em /dev/$TESTESETORES? (s/N): " CONFIRM
if [[ "$CONFIRM" != [sS] && "$CONFIRM" != [yY] ]]; then
    echo "Verificação cancelada pelo usuário."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

echo "Verificando setores em /dev/$TESTESETORES (pode levar muito tempo)..."
badblocks -sv -c 10240 "/dev/$TESTESETORES" # -c 10240 is from original script

echo ""
echo -e "${MENU}=== Verificação de setores concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
