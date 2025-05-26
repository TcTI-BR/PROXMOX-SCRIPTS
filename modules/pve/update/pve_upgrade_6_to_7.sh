#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Upgrade Proxmox VE da Versão 6.x para 7.x ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then 
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1 
fi

echo -e "${RED_TEXT}AVISO: Este script tentará realizar o upgrade do Proxmox VE 6.x para 7.x.${NORMAL}"
echo -e "${RED_TEXT}Certifique-se de ter backups completos e snapshots antes de continuar.${NORMAL}"
echo -e "${RED_TEXT}Execute 'pve6to7 --full' para uma verificação completa antes de prosseguir.${NORMAL}"
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

echo "Configurando repositório PVE 6.x (buster) no-subscription (para garantir que estamos vindo do lugar certo)..."
sed -i '/proxmox/d' /etc/apt/sources.list # Remove other proxmox entries first
echo "deb http://download.proxmox.com/debian/pve buster pve-no-subscription" >> /etc/apt/sources.list

echo "Configurando dpkg (se necessário)..."
dpkg --configure -a

echo "Atualizando lista de pacotes e fazendo upgrade inicial em Buster..."
apt update
apt upgrade -y # Prefer 'upgrade' over 'dist-upgrade' at this specific step as per some guides

echo "Atualizando sources.list de Buster para Bullseye..."
# Remove old PVE entries and Debian entries, then add new ones
sed -i '/proxmox/d' /etc/apt/sources.list
sed -i '/debian/d' /etc/apt/sources.list # This is quite aggressive, ensure it's what's needed.
sed -i '/update/d' /etc/apt/sources.list # Also aggressive

echo "deb http://ftp.debian.org/debian bullseye main contrib" >> /etc/apt/sources.list
echo "deb http://ftp.debian.org/debian bullseye-updates main contrib" >> /etc/apt/sources.list
echo "deb http://security.debian.org/debian-security bullseye-security main contrib" >> /etc/apt/sources.list
echo "deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription" >> /etc/apt/sources.list


echo "Atualizando lista de pacotes para Bullseye..."
apt update

echo "Realizando dist-upgrade para Bullseye (pode levar algum tempo)..."
apt dist-upgrade -y # Changed from apt dist-upgrade to apt dist-upgrade -y

echo "Desabilitando display manager (se existir)..."
systemctl disable display-manager &>/dev/null || echo "Nota: display-manager não encontrado ou não pôde ser desabilitado."
clear

echo -e "${MENU}=== Upgrade de PVE 6.x para 7.x concluído (tentativa). ===${NORMAL}"
echo -e "${RED_TEXT}É crucial verificar os logs, o status do sistema e reiniciar o servidor.${NORMAL}"
echo "Verifique a documentação oficial para passos pós-upgrade, incluindo 'pve6to7'."
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
