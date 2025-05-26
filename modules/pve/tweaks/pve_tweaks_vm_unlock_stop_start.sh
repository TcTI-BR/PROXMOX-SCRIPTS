#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Destrancar, Desligar e Reiniciar VM ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo -e "${ENTER_LINE}Qual ID da VM a ser destrancada, desligada e reiniciada? EX: 100, 101, etc.${NORMAL}"
read -r DESTRANCADESLIGAREINICIAVM
if ! [[ "$DESTRANCADESLIGAREINICIAVM" =~ ^[0-9]+$ ]]; then
    echo -e "${RED_TEXT}ID da VM inválido. Deve ser um número.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

LOCK_FILE="/var/lock/qemu-server/lock-${DESTRANCADESLIGAREINICIAVM}.conf"

echo "Tentando remover o arquivo de lock: $LOCK_FILE (se existir)..."
if [ -f "$LOCK_FILE" ]; then
    rm -f "$LOCK_FILE"
    echo "Arquivo de lock removido."
else
    echo "Arquivo de lock $LOCK_FILE não encontrado."
fi

echo "Executando qm unlock $DESTRANCADESLIGAREINICIAVM..."
if qm unlock "$DESTRANCADESLIGAREINICIAVM"; then
    echo "VM $DESTRANCADESLIGAREINICIAVM destrancada."
else
    echo -e "${YELLOW_TEXT}Aviso: Falha ao executar qm unlock para VM $DESTRANCADESLIGAREINICIAVM ou já estava destrancada.${NORMAL}"
fi

echo "Aguardando 5 segundos antes de desligar..."
sleep 5

echo "Executando qm stop $DESTRANCADESLIGAREINICIAVM..."
if qm stop "$DESTRANCADESLIGAREINICIAVM"; then
    echo "VM $DESTRANCADESLIGAREINICIAVM desligada."
else
    echo -e "${YELLOW_TEXT}Aviso: Falha ao desligar VM $DESTRANCADESLIGAREINICIAVM. Pode já estar parada ou ter ocorrido um erro.${NORMAL}"
fi

echo "Aguardando 2 segundos antes de reiniciar..."
sleep 2

echo "Executando qm start $DESTRANCADESLIGAREINICIAVM..."
if qm start "$DESTRANCADESLIGAREINICIAVM"; then
    echo -e "${GREEN}VM $DESTRANCADESLIGAREINICIAVM reiniciada com sucesso!${NORMAL}"
else
    echo -e "${RED_TEXT}Falha ao reiniciar VM $DESTRANCADESLIGAREINICIAVM. Verifique o estado da VM e logs.${NORMAL}"
fi

echo ""
echo -e "${MENU}=== Operação de destrancar, desligar e reiniciar VM concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
