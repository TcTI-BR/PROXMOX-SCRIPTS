#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh" # Adjusted path

clear
echo -e "${MENU}=== PBS: Configuração de Discos para Datastore ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo "Discos disponíveis:"
lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
echo ""
echo -e "${ENTER_LINE}Qual o disco que vai ser preparado para o Datastore? EX: sda / nvme0n1${NORMAL}"
read -r FORMATADISCO

if [ -z "$FORMATADISCO" ]; then
    echo -e "${RED_TEXT}Nenhum disco especificado. Abortando.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

if [ ! -b "/dev/$FORMATADISCO" ]; then
    echo -e "${RED_TEXT}Disco /dev/$FORMATADISCO não encontrado. Verifique o nome e tente novamente.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo -e "${ENTER_LINE}Qual o nome do Datastore (será usado como Label do disco também)? EX: BACKUP_STORE1${NORMAL}"
read -r DATASTORE_NAME # Changed from STORAGE to DATASTORE_NAME for clarity

if [ -z "$DATASTORE_NAME" ]; then
    echo -e "${RED_TEXT}Nenhum nome de datastore especificado. Abortando.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

# The original script had an unused "IMAGEBACKUP" variable here. PBS datastores are for backups.
# So, no need to ask for content type like in PVE.

echo -e "${RED_TEXT}ATENÇÃO: Todas as informações em /dev/$FORMATADISCO serão PERDIDAS!${NORMAL}"
read -r -p "Tem certeza que deseja continuar e preparar /dev/$FORMATADISCO para o datastore '$DATASTORE_NAME'? (s/N): " CONFIRM
if [[ "$CONFIRM" != [sS] && "$CONFIRM" != [yY] ]]; then
    echo "Operação cancelada pelo usuário."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

echo "Removendo datastore PBS existente com o mesmo nome (se houver)..."
proxmox-backup-manager datastore remove "$DATASTORE_NAME" &>/dev/null || echo "Nota: Datastore $DATASTORE_NAME não existia ou não pôde ser removido."

echo "Criando nova partição em /dev/$FORMATADISCO..."
echo -e "g\nn\np\n1\n\n\nw" | fdisk "/dev/$FORMATADISCO"

# Wait a moment for the kernel to recognize the new partition
sleep 2
PARTITION="${FORMATADISCO}1"
if [[ "$FORMATADISCO" == nvme* || "$FORMATADISCO" == mmcblk* ]]; then
    PARTITION="${FORMATADISCO}p1"
fi

echo "Formatando /dev/$PARTITION como ext4 com Label $DATASTORE_NAME..."
mkfs.ext4 -L "$DATASTORE_NAME" "/dev/$PARTITION"

MOUNT_PATH="/mnt/datastore/$DATASTORE_NAME" # PBS conventional mount path
echo "Criando diretório de montagem $MOUNT_PATH..."
mkdir -p "$MOUNT_PATH"

echo "Removendo entradas antigas para $DATASTORE_NAME ou $MOUNT_PATH em /etc/fstab (se houver)..."
sed -i "/$DATASTORE_NAME/d" /etc/fstab
sed -i "\|$MOUNT_PATH|d" /etc/fstab


echo "Adicionando nova entrada em /etc/fstab..."
echo "" >> /etc/fstab
echo "LABEL=$DATASTORE_NAME $MOUNT_PATH ext4 defaults,auto,nofail 0 0" >> /etc/fstab

echo "Montando disco..."
mount -a

echo "Adicionando diretório como Datastore ao PBS..."
if proxmox-backup-manager datastore create "$DATASTORE_NAME" "$MOUNT_PATH"; then
    echo -e "${GREEN}Datastore '$DATASTORE_NAME' criado e adicionado ao PBS com sucesso.${NORMAL}"
else
    echo -e "${RED_TEXT}Falha ao adicionar o datastore '$DATASTORE_NAME' ao PBS.${NORMAL}"
fi

echo ""
echo -e "${MENU}=== Configuração de disco para Datastore PBS concluída. ===${NORMAL}"
echo "Verifique as saídas acima para quaisquer erros."
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
