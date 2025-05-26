#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh" # Adjusted path

clear
echo -e "${MENU}=== Upgrade Proxmox Backup Server da Versão 1.x para 2.x ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo -e "${RED_TEXT}AVISO: Este script tentará realizar o upgrade do PBS 1.x para 2.x.${NORMAL}"
echo -e "${RED_TEXT}Certifique-se de ter backups completos do seu servidor PBS e datastores antes de continuar.${NORMAL}"
echo -e "${RED_TEXT}Leia a documentação oficial do Proxmox para este upgrade.${NORMAL}"
read -r -p "Deseja continuar com o upgrade? (s/N): " CONFIRM

if [[ "$CONFIRM" != [sS] && "$CONFIRM" != [yY] ]]; then
    echo "Upgrade cancelado pelo usuário."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

echo "Movendo lista de repositório enterprise (se existir)..."
mv /etc/apt/sources.list.d/pbs-enterprise.list /root/ &>/dev/null || echo "Nota: pbs-enterprise.list não encontrado ou não pôde ser movido."
clear

echo "Atualizando sources.list de Buster para Bullseye..."
# This assumes the existing sources.list is for Buster.
# This is a simplified version of the original script's sed commands.
# It's crucial that these replacements are accurate for the user's environment.
# A more robust script might check current release before changing.
sed -i 's/buster\/updates/bullseye-security/g;s/buster/bullseye/g' /etc/apt/sources.list

echo "Adicionando repositório PBS 2.x (Bullseye) no-subscription..."
# Remove any existing pbs-no-subscription line to avoid duplicates, then add it.
sed -i '/pbs-no-subscription/d' /etc/apt/sources.list # Or specific file if used for PBS
echo "deb http://download.proxmox.com/debian/pbs bullseye pbs-no-subscription" >> /etc/apt/sources.list

echo "Atualizando lista de pacotes (primeira vez)..."
apt update

echo "Parando serviços PBS..."
systemctl stop proxmox-backup-proxy.service proxmox-backup.service

echo "Atualizando lista de pacotes (segunda vez, após parar serviços)..."
apt update # As per original script, update again

echo "Realizando dist-upgrade para Bullseye (pode levar algum tempo)..."
apt dist-upgrade -y

echo "Realizando upgrade final (pode levar algum tempo)..."
apt upgrade -y

echo "Iniciando serviços PBS..."
systemctl start proxmox-backup-proxy.service proxmox-backup.service

# Verification step (optional but good)
echo "Verificando versão do PBS..."
proxmox-backup-manager versions

clear
echo -e "${MENU}=== Upgrade de PBS 1.x para 2.x concluído (tentativa). ===${NORMAL}"
echo -e "${RED_TEXT}É crucial verificar os logs, o status do sistema e reiniciar o servidor.${NORMAL}"
echo "Verifique a documentação oficial para passos pós-upgrade."
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
