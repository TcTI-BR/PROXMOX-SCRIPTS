#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Configuração de NFS para Backup PVE ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo -e "${ENTER_LINE}Qual IP do computador cliente que terá acesso ao NFS? EX: 192.168.0.230${NORMAL}"
read -r IPDOCLIENTENFS
if [ -z "$IPDOCLIENTENFS" ]; then
    echo -e "${RED_TEXT}IP do cliente não especificado. Abortando.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo -e "${ENTER_LINE}Qual o nome do Storage de Backup local já configurado no PVE (onde os dumps são armazenados)? EX: BACKUP_2HD${NORMAL}"
echo -e "${MENU}Este script irá compartilhar o diretório /mnt/NOME_DO_STORAGE/dump${NORMAL}"
read -r STORAGEBACKUP
if [ -z "$STORAGEBACKUP" ]; then
    echo -e "${RED_TEXT}Nome do storage não especificado. Abortando.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

NFS_EXPORT_PATH="/mnt/$STORAGEBACKUP/dump"

if [ ! -d "$NFS_EXPORT_PATH" ]; then
    echo -e "${RED_TEXT}Diretório de dump ${NFS_EXPORT_PATH} não encontrado!${NORMAL}"
    echo -e "${MENU}Certifique-se que o storage '$STORAGEBACKUP' existe e o diretório 'dump' está presente em /mnt/$STORAGEBACKUP/${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo "Instalando nfs-kernel-server (se necessário)..."
apt-get update
apt-get install nfs-kernel-server -y

echo "Configurando exports..."
# Ensure the line is added, or updated if it already exists for a different IP for the same path
if grep -q "$NFS_EXPORT_PATH" /etc/exports; then
    echo "Atualizando configuração existente em /etc/exports para $NFS_EXPORT_PATH"
    sed -i "\|$NFS_EXPORT_PATH|c\\$NFS_EXPORT_PATH $IPDOCLIENTENFS(rw,async,no_subtree_check,no_root_squash)" /etc/exports
else
    echo "Adicionando nova configuração em /etc/exports para $NFS_EXPORT_PATH"
    echo "$NFS_EXPORT_PATH $IPDOCLIENTENFS(rw,async,no_subtree_check,no_root_squash)" >> /etc/exports
fi


echo "Reiniciando serviço nfs-kernel-server..."
systemctl restart nfs-kernel-server

echo "Aplicando configurações de exportação..."
exportfs -arv # Use -arv for better feedback

echo "Ajustando permissões em $NFS_EXPORT_PATH (chmod -R 777)..."
chmod -R 777 "$NFS_EXPORT_PATH" # As per original script, consider security implications

echo ""
echo -e "${MENU}=== Configuração NFS concluída. ===${NORMAL}"
echo -e "${MENU}Cliente ${IPDOCLIENTENFS} agora deve ter acesso a ${NFS_EXPORT_PATH}${NORMAL}"
echo -e "${MENU}Lembre-se de configurar o firewall para permitir tráfego NFS (porta 2049) e RPC (porta 111).${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
