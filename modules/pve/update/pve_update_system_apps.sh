#!/bin/bash
PVE_UPDATE_SYSTEM_APPS_SH_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear # Optional: Consider if this is too jarring when called as a module.
echo -e "${MENU}=== Iniciando Atualização do Sistema e Instalação de Aplicativos ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then 
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1 
fi

echo "Movendo lista de repositório enterprise..."
mv /etc/apt/sources.list.d/pve-enterprise.list /root/ &>/dev/null || echo "Nota: pve-enterprise.list não encontrado ou não pôde ser movido."

echo "Configurando repositório PVE No-Subscription..."
sed -i '/subscription/d' /etc/apt/sources.list
echo "deb http://download.proxmox.com/debian/pve $distribution pve-no-subscription" >> /etc/apt/sources.list

echo "Atualizando lista de pacotes..."
apt update

echo "Realizando upgrade do sistema (pode levar algum tempo)..."
apt upgrade -y

echo "Instalando aplicativos comuns..."
apt install libsasl2-modules -y
apt install lm-sensors -y
apt install ifupdown2 -y
apt install ntfs-3g -y
apt install ethtool -y
apt install zip -y
apt install mutt -y

echo ""
echo -e "${MENU}=== Atualização e instalação de aplicativos concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
# No explicit clear at the end, launcher will handle menu redrawing.
