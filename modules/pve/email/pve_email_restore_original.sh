#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Restauração da Configuração Original do E-mail (Postfix) ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo -e "${RED_TEXT}AVISO: Esta operação tentará restaurar /etc/postfix/main.cf e /etc/aliases${NORMAL}"
echo -e "${RED_TEXT}a partir dos backups criados por este conjunto de scripts (main.cf.BCK_proxmox_scripts e aliases.BCK_proxmox_scripts).${NORMAL}"
read -r -p "Deseja continuar com a restauração? (s/N): " CONFIRM

if [[ "$CONFIRM" != [sS] && "$CONFIRM" != [yY] ]]; then
    echo "Restauração cancelada pelo usuário."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

restored_something=0
if [ -f /etc/postfix/main.cf.BCK_proxmox_scripts ]; then
    echo "Restaurando /etc/postfix/main.cf..."
    cp -f /etc/postfix/main.cf.BCK_proxmox_scripts /etc/postfix/main.cf
    echo "/etc/postfix/main.cf restaurado."
    restored_something=1
else
    echo -e "${YELLOW_TEXT}Backup /etc/postfix/main.cf.BCK_proxmox_scripts não encontrado. Nenhuma restauração para main.cf.${NORMAL}"
fi

if [ -f /etc/aliases.BCK_proxmox_scripts ]; then
    echo "Restaurando /etc/aliases..."
    cp -f /etc/aliases.BCK_proxmox_scripts /etc/aliases
    newaliases # Apply alias changes
    echo "/etc/aliases restaurado e 'newaliases' executado."
    restored_something=1
else
    echo -e "${YELLOW_TEXT}Backup /etc/aliases.BCK_proxmox_scripts não encontrado. Nenhuma restauração para aliases.${NORMAL}"
fi

if [ "$restored_something" -eq 1 ]; then
    echo "Reiniciando serviço Postfix para aplicar as configurações restauradas..."
    systemctl restart postfix
    echo -e "${GREEN}Serviço Postfix reiniciado.${NORMAL}"
else
    echo "Nenhum arquivo de backup encontrado para restaurar."
fi

echo ""
echo -e "${MENU}=== Restauração concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
