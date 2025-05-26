#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Upgrade Proxmox VE da Versão 5.x para 6.x ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then 
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1 
fi

echo -e "${RED_TEXT}AVISO: Este script tentará realizar o upgrade do Proxmox VE 5.x para 6.x.${NORMAL}"
echo -e "${RED_TEXT}Certifique-se de ter backups completos e snapshots antes de continuar.${NORMAL}"
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

echo "Parando serviços PVE HA..."
systemctl stop pve-ha-lrm
systemctl stop pve-ha-crm

echo "Adicionando repositório Corosync 3 para Stretch..."
echo "deb http://download.proxmox.com/debian/corosync-3/ stretch main" > /etc/apt/sources.list.d/corosync3.list

echo "Atualizando e fazendo dist-upgrade inicial..."
apt update
apt dist-upgrade -y

echo "Iniciando serviços PVE HA..."
systemctl start pve-ha-lrm
systemctl start pve-ha-crm

echo "Atualizando e fazendo segundo dist-upgrade..."
apt update
apt dist-upgrade -y

echo "Modificando sources.list de Stretch para Buster..."
sed -i 's/stretch/buster/g' /etc/apt/sources.list

echo "Configurando repositório PVE 6.x (no-subscription)..."
# Assuming pve-install-repo.list might be the one for initial setup, ensure it's also updated
if [ -f /etc/apt/sources.list.d/pve-install-repo.list ]; then
    sed -i -e 's/stretch/buster/g' /etc/apt/sources.list.d/pve-install-repo.list
fi
echo "deb http://download.proxmox.com/debian/pve buster pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list


echo "Configurando repositório Ceph Luminous para Buster (se aplicável)..."
# Note: Original script specified ceph-luminous. PVE 6 typically uses Nautilus.
# Keeping luminous as per original script, but this might need adjustment based on actual Ceph version.
echo "deb http://download.proxmox.com/debian/ceph-luminous buster main" > /etc/apt/sources.list.d/ceph.list

echo "Atualizando e fazendo terceiro dist-upgrade..."
apt update
apt dist-upgrade -y

echo "Removendo repositório Corosync 3..."
rm /etc/apt/sources.list.d/corosync3.list

echo "Atualizando e fazendo quarto dist-upgrade..."
apt update
apt dist-upgrade -y

echo "Removendo imagem de kernel antiga (se existir)..."
apt remove linux-image-amd64 -y &>/dev/null || echo "Nota: linux-image-amd64 não encontrado para remoção ou já removido."

echo "Desabilitando display manager (se existir)..."
systemctl disable display-manager &>/dev/null || echo "Nota: display-manager não encontrado ou não pôde ser desabilitado."
clear

echo -e "${MENU}=== Upgrade de PVE 5.x para 6.x concluído (tentativa). ===${NORMAL}"
echo -e "${RED_TEXT}É crucial verificar os logs, o status do sistema e reiniciar o servidor.${NORMAL}"
echo "Verifique a documentação oficial para passos pós-upgrade."
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
