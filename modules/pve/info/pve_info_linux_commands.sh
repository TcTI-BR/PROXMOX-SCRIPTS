#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Comandos Linux Úteis ===${NORMAL}"
# No root check needed for displaying information.

echo ""
echo -e "${GREEN_TEXT}ip address${NORMAL} = Ver os IPs setados nas interfaces"
echo -e "${GREEN_TEXT}df -h${NORMAL} = Lista o tamanho dos pontos de montagem"
echo -e "${GREEN_TEXT}rsync --progress /CAMINHO_DE_ORIGEM.EXTENSÃO /CAMINHO_DE_DESTINO/${NORMAL} = Comando para copiar com progressão"
echo -e "${GREEN_TEXT}lsblk -f${NORMAL} = Lista discos, partições, UUIDs e pontos de montagem"
echo -e "${GREEN_TEXT}free -h${NORMAL} = Mostra uso de memória RAM e SWAP"
echo -e "${GREEN_TEXT}htop${NORMAL} ou ${GREEN_TEXT}top${NORMAL} = Monitor de processos interativo"
echo -e "${GREEN_TEXT}journalctl -fu nome_do_servico${NORMAL} = Ver logs de um serviço em tempo real"
echo -e "${GREEN_TEXT}ss -tulnp${NORMAL} = Listar portas de rede abertas"
echo ""

echo -e "${MENU}=== Fim da Lista de Comandos Linux. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
