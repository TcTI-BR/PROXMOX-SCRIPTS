#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"
# hostname variable is used from variables.sh

clear
echo -e "${MENU}=== Restauração de Backup das Configurações do PVE ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo -e "${RED_TEXT}ATENÇÃO: Esta operação tentará restaurar configurações do PVE a partir de um backup.${NORMAL}"
echo -e "${RED_TEXT}Isto pode sobrescrever configurações atuais. Use com CUIDADO!${NORMAL}"
read -r -p "Deseja continuar com a restauração? (s/N): " CONFIRM_MAIN
if [[ "$CONFIRM_MAIN" != [sS] && "$CONFIRM_MAIN" != [yY] ]]; then
    echo "Restauração cancelada pelo usuário."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

echo ""
echo "Discos/Labels disponíveis para buscar o backup:"
lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE | grep -vE "SWAP|swap"
echo ""
echo -e "${ENTER_LINE}Qual a LABEL da unidade onde estão os arquivos de backup das configurações? (Ex: BACKUP_CONFIG)${NORMAL}"
read -r RECUPERABKP_LABEL
if [ -z "$RECUPERABKP_LABEL" ]; then
    echo -e "${RED_TEXT}Label da unidade de backup não especificada. Abortando.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

RECUPERABKP_MOUNTPOINT_BASE="/mnt/RECUPERAPVE_TEMP_MOUNT" # Temporary mount point
RECUPERABKP_MOUNTPOINT_FINAL=$(findmnt -rn -S "LABEL=$RECUPERABKP_LABEL" -o TARGET)

if [ -n "$RECUPERABKP_MOUNTPOINT_FINAL" ]; then
    echo "Unidade já parece estar montada em $RECUPERABKP_MOUNTPOINT_FINAL."
    BKP_SOURCE_DIR="$RECUPERABKP_MOUNTPOINT_FINAL/BKP-PVE"
else
    echo "Tentando montar LABEL=$RECUPERABKP_LABEL em $RECUPERABKP_MOUNTPOINT_BASE..."
    mkdir -p "$RECUPERABKP_MOUNTPOINT_BASE"
    if ! mount "LABEL=$RECUPERABKP_LABEL" "$RECUPERABKP_MOUNTPOINT_BASE"; then
        echo -e "${RED_TEXT}Falha ao montar LABEL=$RECUPERABKP_LABEL em $RECUPERABKP_MOUNTPOINT_BASE.${NORMAL}"
        rmdir "$RECUPERABKP_MOUNTPOINT_BASE" &>/dev/null
        read -n 1 -s -r -p "Pressione uma tecla para continuar..."
        exit 1
    fi
    BKP_SOURCE_DIR="$RECUPERABKP_MOUNTPOINT_BASE/BKP-PVE"
fi


if [ ! -d "$BKP_SOURCE_DIR" ]; then
    echo -e "${RED_TEXT}Diretório de backup $BKP_SOURCE_DIR não encontrado na unidade $RECUPERABKP_LABEL.${NORMAL}"
    if [ -z "$RECUPERABKP_MOUNTPOINT_FINAL" ]; then # Unmount if we mounted it
        umount "$RECUPERABKP_MOUNTPOINT_BASE" &>/dev/null
        rmdir "$RECUPERABKP_MOUNTPOINT_BASE" &>/dev/null
    fi
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo "Arquivos de backup disponíveis em $BKP_SOURCE_DIR:"
ls -t "$BKP_SOURCE_DIR"/*.zip 2>/dev/null || {
    echo -e "${RED_TEXT}Nenhum arquivo .zip encontrado em $BKP_SOURCE_DIR.${NORMAL}"
    if [ -z "$RECUPERABKP_MOUNTPOINT_FINAL" ]; then # Unmount if we mounted it
        umount "$RECUPERABKP_MOUNTPOINT_BASE" &>/dev/null
        rmdir "$RECUPERABKP_MOUNTPOINT_BASE" &>/dev/null
    fi
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
}
echo ""
echo -e "${ENTER_LINE}Qual o nome do arquivo a ser recuperado (sem a extensão .zip)? EX: 20-02-2023${NORMAL}"
read -r RESTAURABKP_FILENAME
if [ -z "$RESTAURABKP_FILENAME" ]; then
    echo -e "${RED_TEXT}Nome do arquivo de backup não especificado. Abortando.${NORMAL}"
     if [ -z "$RECUPERABKP_MOUNTPOINT_FINAL" ]; then umount "$RECUPERABKP_MOUNTPOINT_BASE" &>/dev/null; rmdir "$RECUPERABKP_MOUNTPOINT_BASE" &>/dev/null; fi
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

RESTAURABKP_ZIP="$BKP_SOURCE_DIR/$RESTAURABKP_FILENAME.zip"
if [ ! -f "$RESTAURABKP_ZIP" ]; then
    echo -e "${RED_TEXT}Arquivo de backup $RESTAURABKP_ZIP não encontrado. Abortando.${NORMAL}"
    if [ -z "$RECUPERABKP_MOUNTPOINT_FINAL" ]; then umount "$RECUPERABKP_MOUNTPOINT_BASE" &>/dev/null; rmdir "$RECUPERABKP_MOUNTPOINT_BASE" &>/dev/null; fi
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

# Ensure zip/unzip is installed
if ! command -v unzip &> /dev/null; then
    echo "Comando 'unzip' não encontrado. Tentando instalar..."
    apt update
    apt install zip -y # Original script installed zip, assuming it provides unzip or it's a common pair.
    if ! command -v unzip &> /dev/null; then
        echo -e "${RED_TEXT}Falha ao instalar 'unzip'. Por favor, instale manualmente.${NORMAL}"
        if [ -z "$RECUPERABKP_MOUNTPOINT_FINAL" ]; then umount "$RECUPERABKP_MOUNTPOINT_BASE" &>/dev/null; rmdir "$RECUPERABKP_MOUNTPOINT_BASE" &>/dev/null; fi
        read -n 1 -s -r -p "Pressione uma tecla para continuar..."
        exit 1
    fi
fi

TMP_RECUPERA_DIR="/TcTI/SCRIPTS/TMP-RECUPERA"
mkdir -p "$TMP_RECUPERA_DIR"
echo "Extraindo $RESTAURABKP_ZIP para $TMP_RECUPERA_DIR..."
unzip -o "$RESTAURABKP_ZIP" -d "$TMP_RECUPERA_DIR" # -o for overwrite without prompt

PVENAME_FROM_HOSTNAME=$(hostname) # Used for qemu-server path

# List of files/dirs to potentially restore, relative to $TMP_RECUPERA_DIR/etc or $TMP_RECUPERA_DIR/var etc.
# Format: "source_in_zip:destination_on_system:type(file/dir):description"
# Note: original script copies qemu-server from a sub-sub-folder structure. This simplified version assumes files are in $TMP_RECUPERA_DIR/etc/pve...
ITEMS_TO_RESTORE=(
    "etc/pve/nodes/$PVENAME_FROM_HOSTNAME/qemu-server/:/etc/pve/nodes/$PVENAME_FROM_HOSTNAME/qemu-server/:dir:Configurações de VM (qemu-server)"
    "etc/fstab:/etc/fstab:file:Configuração de montagem de discos (fstab)"
    "etc/pve/vzdump.cron:/etc/pve/vzdump.cron:file:Agendamento de backup VZDump (vzdump.cron)"
    "etc/pve/storage.cfg:/etc/pve/storage.cfg:file:Configuração de Storages PVE (storage.cfg)"
    "etc/pve/user.cfg:/etc/pve/user.cfg:file:Configuração de Usuários PVE (user.cfg)"
    "etc/pve/datacenter.cfg:/etc/pve/datacenter.cfg:file:Configurações do Datacenter PVE (datacenter.cfg)"
    "etc/network/interfaces:/etc/network/interfaces:file:Configurações de Rede (interfaces)"
    "etc/resolv.conf:/etc/resolv.conf:file:Configuração de DNS (resolv.conf)"
    "var/spool/cron/crontabs/root:/var/spool/cron/crontabs/root:file:Agendamentos Cron do Root (crontab)"
    "etc/hostname:/etc/hostname:file:Nome do Host (hostname)"
    "etc/hosts:/etc/hosts:file:Arquivo Hosts"
    "etc/pve/jobs.cfg:/etc/pve/jobs.cfg:file:Configuração de Jobs PVE (jobs.cfg)"
    "etc/postfix/:/etc/postfix/:dir:Configurações do Postfix"
)

echo ""
echo -e "${MENU}Iniciando processo de restauração interativa...${NORMAL}"

for item_info in "${ITEMS_TO_RESTORE[@]}"; do
    IFS=':' read -r source_path dest_path item_type description <<< "$item_info"
    
    full_source_path="$TMP_RECUPERA_DIR/$source_path"

    if [ "$item_type" == "file" ] && [ ! -f "$full_source_path" ]; then
        echo -e "${RED_TEXT}AVISO: Arquivo de origem '$description' ($full_source_path) não encontrado no backup. Pulando.${NORMAL}"
        continue
    elif [ "$item_type" == "dir" ] && [ ! -d "$full_source_path" ]; then
        echo -e "${RED_TEXT}AVISO: Diretório de origem '$description' ($full_source_path) não encontrado no backup. Pulando.${NORMAL}"
        continue
    fi

    # Check if original file/dir exists for context, not for skipping
    if [ -e "$dest_path" ]; then
        echo -e "${MENU}Configuração atual para '$description' ($dest_path) existe.${NORMAL}"
    else
        echo -e "${YELLOW_TEXT}Configuração atual para '$description' ($dest_path) NÃO existe.${NORMAL}" # Yellow might not be defined, use MENU or RED_TEXT
    fi

    read -r -p "Deseja restaurar '$description' de '$full_source_path' para '$dest_path'? (s/N): " CONFIRM_ITEM
    if [[ "$CONFIRM_ITEM" == [sS] || "$CONFIRM_ITEM" == [yY] ]]; then
        echo "Restaurando $description..."
        if [ "$item_type" == "dir" ]; then
            # For directories, ensure destination parent exists, then copy contents
            mkdir -p "$(dirname "$dest_path")" 
            cp -ar "$full_source_path/." "$dest_path/" # Copy contents recursively
        else
            mkdir -p "$(dirname "$dest_path")"
            cp -a "$full_source_path" "$dest_path"
        fi
        echo "'$description' restaurado."
    else
        echo "'$description' não restaurado (pulado pelo usuário)."
    fi
    echo "-----------------------------------------------------"
done

echo ""
echo -e "${MENU}=== Restauração Interativa Concluída ===${NORMAL}"
echo -e "${RED_TEXT}É altamente recomendável reiniciar o servidor para aplicar todas as configurações restauradas, especialmente as de rede e sistema.${NORMAL}"
read -r -p "Deseja reiniciar o servidor agora? (s/N): " CONFIRM_REBOOT

# Cleanup
rm -rf "$TMP_RECUPERA_DIR"
if [ -z "$RECUPERABKP_MOUNTPOINT_FINAL" ]; then # Unmount if we mounted it
    echo "Desmontando $RECUPERABKP_MOUNTPOINT_BASE..."
    umount "$RECUPERABKP_MOUNTPOINT_BASE" &>/dev/null
    rmdir "$RECUPERABKP_MOUNTPOINT_BASE" &>/dev/null
fi

if [[ "$CONFIRM_REBOOT" == [sS] || "$CONFIRM_REBOOT" == [yY] ]]; then
    echo "Reiniciando o servidor..."
    reboot
else
    echo "Lembre-se de reiniciar o servidor manualmente se necessário."
fi

read -n 1 -s -r -p "Pressione uma tecla para finalizar, se não reiniciado..."
