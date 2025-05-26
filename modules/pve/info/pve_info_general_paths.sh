#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Caminhos e Informações Gerais PVE ===${NORMAL}"
# No root check needed for displaying information.

echo ""
echo -e "${GREEN_TEXT}/etc/pve/nodes/NOME_DO_NODE/qemu-server/${NORMAL} = Caminho onde ficam os arquivos de configuração das VMs (VMID.conf)."
echo -e "${GREEN_TEXT}/etc/pve/nodes/NOME_DO_NODE/lxc/${NORMAL} = Caminho onde ficam os arquivos de configuração dos containers LXC (CTID.conf)."
echo -e "${GREEN_TEXT}/var/lib/vz/template/iso/${NORMAL} = Caminho padrão para armazenar imagens ISO."
echo -e "${GREEN_TEXT}/var/lib/vz/template/cache/${NORMAL} = Caminho padrão para templates de container LXC."
echo -e "${GREEN_TEXT}/var/lib/vz/dump/${NORMAL} = Caminho padrão para arquivos de backup VZDump."
echo -e "${GREEN_TEXT}/etc/pve/storage.cfg${NORMAL} = Arquivo de configuração dos storages do Proxmox VE."
echo -e "${GREEN_TEXT}/etc/pve/user.cfg${NORMAL} = Arquivo de configuração de usuários e permissões do Proxmox VE."
echo -e "${GREEN_TEXT}/etc/pve/vzdump.cron${NORMAL} = Arquivo de agendamento de backups via VZDump."
echo -e "${GREEN_TEXT}/var/log/pve/tasks/${NORMAL} = Logs das tarefas executadas pelo Proxmox VE."
echo -e "${GREEN_TEXT}/etc/network/interfaces${NORMAL} = Configuração das interfaces de rede do host."
echo ""

echo -e "${MENU}=== Fim da Lista de Caminhos e Informações. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
