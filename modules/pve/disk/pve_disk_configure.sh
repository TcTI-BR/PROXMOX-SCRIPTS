#!/bin/bash
PVE_DISK_CONFIGURE_SH_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Configuração de Discos para PVE ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then 
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1 
fi

echo "Discos disponíveis:"
lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
echo ""
echo -e "${ENTER_LINE}Qual o disco que vai ser preparado? EX: sda / nvme0n1${NORMAL}"
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

echo -e "${ENTER_LINE}Qual o nome do Storage (Label)? EX: VM01 / RECOVER / BACKUP_2HD${NORMAL}"
read -r STORAGE

if [ -z "$STORAGE" ]; then
    echo -e "${RED_TEXT}Nenhum nome de storage especificado. Abortando.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo -e "${ENTER_LINE}O disco será para VMs ou Backup? Digite exatamente 'images' para VM/Container ou 'backup' para Arquivos de Backup${NORMAL}"
read -r IMAGEBACKUP

if [[ "$IMAGEBACKUP" != "images" && "$IMAGEBACKUP" != "backup" ]]; then
    echo -e "${RED_TEXT}Opção inválida para tipo de conteúdo. Use 'images' ou 'backup'. Abortando.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo -e "${RED_TEXT}ATENÇÃO: Todas as informações em /dev/$FORMATADISCO serão PERDIDAS!${NORMAL}"
read -r -p "Tem certeza que deseja continuar? (s/N): " CONFIRM
if [[ "$CONFIRM" != [sS] && "$CONFIRM" != [yY] ]]; then
    echo "Operação cancelada pelo usuário."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo "Removendo storage PVE existente com o mesmo nome (se houver)..."
pvesm remove "$STORAGE" &>/dev/null || echo "Nota: Storage $STORAGE não existia ou não pôde ser removido."

echo "Criando nova partição em /dev/$FORMATADISCO..."
echo -e "g\nn\np\n1\n\n\nw" | fdisk "/dev/$FORMATADISCO"

# Wait a moment for the kernel to recognize the new partition
sleep 2
PARTITION="${FORMATADISCO}1"
if [[ "$FORMATADISCO" == nvme* || "$FORMATADISCO" == mmcblk* ]]; then
    PARTITION="${FORMATADISCO}p1"
fi

echo "Formatando /dev/$PARTITION como ext4 com Label $STORAGE..."
mkfs.ext4 -L "$STORAGE" "/dev/$PARTITION"

echo "Criando diretório de montagem /mnt/$STORAGE..."
mkdir -p "/mnt/$STORAGE"

echo "Removendo entradas antigas do $STORAGE em /etc/fstab (se houver)..."
sed -i "/$STORAGE/d" /etc/fstab # Basic removal, might need refinement for complex fstab entries

echo "Adicionando nova entrada em /etc/fstab..."
echo "" >> /etc/fstab
echo "LABEL=$STORAGE /mnt/$STORAGE ext4 defaults,auto,nofail 0 0" >> /etc/fstab

echo "Montando disco..."
mount -a

echo "Adicionando diretório como storage ao PVE..."
pvesm add dir "$STORAGE" --path "/mnt/$STORAGE" --content "$IMAGEBACKUP"

echo ""
echo -e "${MENU}=== Configuração de disco concluída. ===${NORMAL}"
echo "Verifique as saídas acima para quaisquer erros."
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
