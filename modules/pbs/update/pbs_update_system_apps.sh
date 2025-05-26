#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh" # Adjusted path

clear
echo -e "${MENU}=== PBS: Atualização do Sistema e Instalação de Aplicativos ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo "Movendo lista de repositório enterprise (se existir)..."
mv /etc/apt/sources.list.d/pbs-enterprise.list /root/ &>/dev/null || echo "Nota: pbs-enterprise.list não encontrado ou não pôde ser movido."

echo "Configurando repositório PBS No-Subscription..."
# Ensure $distribution is available from variables.sh
if [ -z "$distribution" ]; then
    echo -e "${RED_TEXT}Variável 'distribution' (Codename da distribuição Debian) não definida. Verifique variables.sh.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi
# Remove any existing pbs-no-subscription line to avoid duplicates, then add it.
sed -i '/pbs-no-subscription/d' /etc/apt/sources.list # Or specific file if used for PBS
echo "deb http://download.proxmox.com/debian/pbs $distribution pbs-no-subscription" >> /etc/apt/sources.list

echo "Atualizando lista de pacotes..."
apt update

echo "Realizando upgrade do sistema (pode levar algum tempo)..."
apt upgrade -y

echo "Instalando aplicativos comuns para PBS..."
apt install libsasl2-modules -y
apt install lm-sensors -y
apt install ifupdown2 -y # ifupdown2 might be more for PVE, but included in original PBS update
apt install ethtool -y
apt install hdparm -y

echo ""
echo -e "${MENU}=== Atualização e instalação de aplicativos PBS concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
