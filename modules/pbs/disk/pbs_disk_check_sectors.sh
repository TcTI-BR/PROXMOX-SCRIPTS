#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh" # Adjusted path

clear
echo -e "${MENU}=== PBS: Verificação de Setores Defeituosos ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

# Ensure badblocks is installed (it's usually part of e2fsprogs, which should be present)
if ! command -v badblocks &> /dev/null; then
    echo "Comando 'badblocks' não encontrado. Tentando instalar e2fsprogs..."
    apt update
    apt install e2fsprogs -y
    if ! command -v badblocks &> /dev/null; then
        echo -e "${RED_TEXT}Falha ao instalar 'e2fsprogs' (que contém badblocks). Por favor, instale manualmente.${NORMAL}"
        read -n 1 -s -r -p "Pressione uma tecla para continuar..."
        exit 1
    fi
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
echo -e "${RED_TEXT}AVISO: A verificação de setores pode ser DEMORADA e intensiva em I/O.${NORMAL}"
echo -e "${RED_TEXT}É recomendado executar em discos sem dados importantes ou desmontados, se possível.${NORMAL}"
read -r -p "Deseja continuar com a verificação em /dev/$TESTESETORES? (s/N): " CONFIRM
if [[ "$CONFIRM" != [sS] && "$CONFIRM" != [yY] ]]; then
    echo "Verificação cancelada pelo usuário."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

echo "Verificando setores em /dev/$TESTESETORES (pode levar muito tempo)..."
# -s: show progress, -v: verbose, -c 10240: blocks at a time (from original script)
# Using a non-destructive read-only test by default. Add -w for write test (destructive).
badblocks -sv -c 10240 "/dev/$TESTESETORES"

echo ""
echo -e "${MENU}=== Verificação de setores PBS concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
