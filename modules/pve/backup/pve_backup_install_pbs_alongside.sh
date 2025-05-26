#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Instalação do Proxmox Backup Server (PBS) lado a lado com PVE ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo -e "${RED_TEXT}AVISO: Esta operação instalará o Proxmox Backup Server no mesmo host que o PVE.${NORMAL}"
echo -e "${MENU}Considere os requisitos de sistema e possíveis conflitos de porta (PBS usa 8007).${NORMAL}"
read -r -p "Deseja continuar com a instalação? (s/N): " CONFIRM

if [[ "$CONFIRM" != [sS] && "$CONFIRM" != [yY] ]]; then
    echo "Instalação cancelada pelo usuário."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

echo "Adicionando repositório PBS no-subscription..."
# Ensure $distribution is available from variables.sh
if [ -z "$distribution" ]; then
    echo -e "${RED_TEXT}Variável 'distribution' (Codename da distribuição Debian) não definida. Verifique variables.sh.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi
echo "deb http://download.proxmox.com/debian/pbs $distribution pbs-no-subscription" >> /etc/apt/sources.list
# Note: Original script added to sources.list, consider sources.list.d for PBS too.

echo "Atualizando lista de pacotes..."
apt update # Run apt update twice as per original script
apt update

echo "Instalando Proxmox Backup Server..."
apt-get install proxmox-backup-server -y

echo ""
if dpkg -s proxmox-backup-server &> /dev/null; then
    echo -e "${MENU}=== Proxmox Backup Server instalado com sucesso! ===${NORMAL}"
    echo -e "${MENU}Acesse a interface web do PBS em https://$(hostname -I | awk '{print $1}'):8007${NORMAL}"
else
    echo -e "${RED_TEXT}Falha na instalação do Proxmox Backup Server. Verifique os logs.${NORMAL}"
fi
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
