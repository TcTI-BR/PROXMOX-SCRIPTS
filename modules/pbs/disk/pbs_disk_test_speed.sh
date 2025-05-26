#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh" # Adjusted path

clear
echo -e "${MENU}=== PBS: Teste de Velocidade de Discos ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

# Ensure hdparm is installed
if ! command -v hdparm &> /dev/null; then
    echo "Comando 'hdparm' não encontrado. Tentando instalar..."
    apt update
    apt install hdparm -y
    if ! command -v hdparm &> /dev/null; then
        echo -e "${RED_TEXT}Falha ao instalar 'hdparm'. Por favor, instale manualmente.${NORMAL}"
        read -n 1 -s -r -p "Pressione uma tecla para continuar..."
        exit 1
    fi
fi

echo "Discos disponíveis:"
lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
echo ""
echo -e "${ENTER_LINE}Qual disco será testado o desempenho? EX: sda / nvme0n1${NORMAL}"
read -r TESTEDISCO

if [ -z "$TESTEDISCO" ]; then
    echo -e "${RED_TEXT}Nenhum disco especificado. Abortando.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

if [ ! -b "/dev/$TESTEDISCO" ]; then
    echo -e "${RED_TEXT}Disco /dev/$TESTEDISCO não encontrado. Verifique o nome e tente novamente.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

clear
echo "Testando desempenho de /dev/$TESTEDISCO..."
hdparm -tT "/dev/$TESTEDISCO"

echo ""
echo -e "${MENU}=== Teste de velocidade PBS concluído. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
