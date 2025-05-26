#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Destrancar VM ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo -e "${ENTER_LINE}Qual ID da VM a ser destrancada? EX: 100, 101, etc.${NORMAL}"
read -r DESTRANCAVM
if ! [[ "$DESTRANCAVM" =~ ^[0-9]+$ ]]; then
    echo -e "${RED_TEXT}ID da VM inválido. Deve ser um número.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

LOCK_FILE="/var/lock/qemu-server/lock-${DESTRANCAVM}.conf"

echo "Tentando remover o arquivo de lock: $LOCK_FILE (se existir)..."
if [ -f "$LOCK_FILE" ]; then
    rm -f "$LOCK_FILE"
    echo "Arquivo de lock removido."
else
    echo "Arquivo de lock $LOCK_FILE não encontrado."
fi

echo "Executando qm unlock $DESTRANCAVM..."
if qm unlock "$DESTRANCAVM"; then
    echo -e "${GREEN}VM $DESTRANCAVM destrancada com sucesso!${NORMAL}"
else
    echo -e "${RED_TEXT}Falha ao executar qm unlock para VM $DESTRANCAVM. Verifique se a VM existe ou se já está destrancada.${NORMAL}"
fi

echo ""
echo -e "${MENU}=== Operação de destrancar VM concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
