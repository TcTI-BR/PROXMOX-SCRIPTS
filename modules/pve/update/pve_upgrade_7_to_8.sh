#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Upgrade Proxmox VE da Versão 7.x para 8.x ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then 
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1 
fi

echo -e "${RED_TEXT}AVISO: Este script tentará realizar o upgrade do Proxmox VE 7.x para 8.x.${NORMAL}"
echo -e "${RED_TEXT}Certifique-se de ter backups completos e snapshots antes de continuar.${NORMAL}"
echo -e "${RED_TEXT}Execute 'pve7to8 --full' para uma verificação completa antes de prosseguir.${NORMAL}"
echo -e "${RED_TEXT}Leia a documentação oficial do Proxmox para este upgrade.${NORMAL}"
read -r -p "Deseja continuar com o upgrade? (s/N): " CONFIRM

if [[ "$CONFIRM" != [sS] && "$CONFIRM" != [yY] ]]; then
    echo "Upgrade cancelado pelo usuário."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

echo "Movendo lista de repositório enterprise (se existir)..."
mv /etc/apt/sources.list.d/pve-enterprise.list /root/ &>/dev/null || echo "Nota: pve-enterprise.list não encontrado ou não pôde ser movido."
clear

echo "Atualizando lista de pacotes e fazendo upgrade inicial em Bullseye..."
apt update
apt upgrade -y # Prefer 'upgrade' over 'dist-upgrade' at this specific step

echo "Atualizando sources.list de Bullseye para Bookworm..."
# Remove old PVE entries and Debian entries, then add new ones for Bookworm
sed -i '/proxmox/d' /etc/apt/sources.list
sed -i '/debian/d' /etc/apt/sources.list # Aggressive, ensure this is intended
sed -i '/update/d' /etc/apt/sources.list # Aggressive

echo "deb http://ftp.debian.org/debian bookworm main contrib" >> /etc/apt/sources.list
echo "deb http://ftp.debian.org/debian bookworm-updates main contrib" >> /etc/apt/sources.list
echo "deb http://security.debian.org/debian-security bookworm-security main contrib" >> /etc/apt/sources.list
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" >> /etc/apt/sources.list

# Update Ceph repository if present (example from PVE 8 upgrade docs)
# This might need to be more intelligent based on currently installed Ceph
if [ -f /etc/apt/sources.list.d/ceph.list ]; then
    echo "Atualizando repositório Ceph para Bookworm (exemplo Quincy para Reef)..."
    # This is an example, the actual Ceph upgrade path needs careful consideration
    # sed -i 's/quincy/reef/' /etc/apt/sources.list.d/ceph.list
    echo "Nota: A atualização do repositório Ceph pode precisar de ajustes manuais."
fi


echo "Atualizando lista de pacotes para Bookworm..."
apt update

echo "Realizando dist-upgrade para Bookworm (pode levar algum tempo)..."
# Using -o Dpkg::Options::="--force-confold" can be helpful for some upgrades
# but should be used with caution. Not adding it by default.
apt dist-upgrade -y

echo "Desabilitando display manager (se existir)..."
systemctl disable display-manager &>/dev/null || echo "Nota: display-manager não encontrado ou não pôde ser desabilitado."
clear

echo -e "${MENU}=== Upgrade de PVE 7.x para 8.x concluído (tentativa). ===${NORMAL}"
echo -e "${RED_TEXT}É crucial verificar os logs, o status do sistema e reiniciar o servidor.${NORMAL}"
echo "Verifique a documentação oficial para passos pós-upgrade, incluindo 'pve7to8'."
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
