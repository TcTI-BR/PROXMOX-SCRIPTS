#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"
# hostname variable is used from variables.sh

clear
echo -e "${MENU}=== Agendamento de Backup das Configurações do PVE ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo "Discos/Labels disponíveis para armazenamento do backup:"
lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE | grep -vE "SWAP|swap" # Filter out swap
echo ""
echo -e "${ENTER_LINE}Qual a LABEL da unidade que vai manter uma copia dos arquivos de configuracao? (Ex: BACKUP_CONFIG)${NORMAL}"
read -r CAMINHOBKP_LABEL
if [ -z "$CAMINHOBKP_LABEL" ]; then
    echo -e "${RED_TEXT}Label da unidade não especificada. Abortando.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

# Find mountpoint for the given label
CAMINHOBKP_MOUNTPOINT=$(findmnt -rn -S "LABEL=$CAMINHOBKP_LABEL" -o TARGET)
if [ -z "$CAMINHOBKP_MOUNTPOINT" ]; then
    echo -e "${RED_TEXT}Não foi possível encontrar o ponto de montagem para a LABEL '$CAMINHOBKP_LABEL'.${NORMAL}"
    echo -e "${MENU}Verifique se o disco está montado e a label está correta.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi
echo "Backup será armazenado em: $CAMINHOBKP_MOUNTPOINT/BKP-PVE"


echo -e "${ENTER_LINE}Qual o e-mail que vai receber uma copia dos arquivos de configuracao?${NORMAL}"
read -r CAMINHOEMAILBKP
if [ -z "$CAMINHOEMAILBKP" ]; then
    echo -e "${RED_TEXT}E-mail não especificado. Abortando.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

BKP_PVE_BASE_DIR="/TcTI/SCRIPTS/BKP-PVE" # Base directory for scripts and temp files
BKP_PVE_SCRIPT="$BKP_PVE_BASE_DIR/BKP-PVE.sh"
BKP_PVE_TEMP_DIR="$BKP_PVE_BASE_DIR/TEMP-BKP/QEMU"
BACKUP_DEST_DIR="$CAMINHOBKP_MOUNTPOINT/BKP-PVE" # Actual backup files destination

mkdir -p "$BKP_PVE_TEMP_DIR"
mkdir -p "$BACKUP_DEST_DIR"

# Create the backup script
echo "#!/bin/bash" > "$BKP_PVE_SCRIPT"
echo "PVENAME=\$(hostname)" >> "$BKP_PVE_SCRIPT" # Get hostname inside the script
echo "BACKUP_DIR=\"$BACKUP_DEST_DIR\"" >> "$BKP_PVE_SCRIPT"
echo "TEMP_QEMU_DIR=\"$BKP_PVE_TEMP_DIR\"" >> "$BKP_PVE_SCRIPT"
echo "EMAIL_TO=\"$CAMINHOEMAILBKP\"" >> "$BKP_PVE_SCRIPT"
echo "CURRENT_DATE=\$(date +%d-%m-%Y)" >> "$BKP_PVE_SCRIPT"
echo "ZIP_FILE=\"\$BACKUP_DIR/\$CURRENT_DATE.zip\"" >> "$BKP_PVE_SCRIPT"
echo "MSG_FILE=\"$BKP_PVE_BASE_DIR/msg.txt\"" >> "$BKP_PVE_SCRIPT"

echo "" >> "$BKP_PVE_SCRIPT"
echo "echo \"Limpando arquivos de backup temporários antigos (se houver)...\"" >> "$BKP_PVE_SCRIPT"
echo "rm -f \"\$TEMP_QEMU_DIR\"/*.conf" >> "$BKP_PVE_SCRIPT"
echo "rm -f \"\$ZIP_FILE\"" >> "$BKP_PVE_SCRIPT" # Remove old zip for today if script is rerun

echo "" >> "$BKP_PVE_SCRIPT"
echo "FILES_TO_BACKUP=(" >> "$BKP_PVE_SCRIPT"
echo "    \"/etc/pve/vzdump.cron\"" >> "$BKP_PVE_SCRIPT"
echo "    \"/etc/pve/storage.cfg\"" >> "$BKP_PVE_SCRIPT"
echo "    \"/etc/pve/user.cfg\"" >> "$BKP_PVE_SCRIPT"
echo "    \"/etc/pve/datacenter.cfg\"" >> "$BKP_PVE_SCRIPT"
echo "    \"/etc/network/interfaces\"" >> "$BKP_PVE_SCRIPT"
echo "    \"/etc/resolv.conf\"" >> "$BKP_PVE_SCRIPT"
echo "    \"/var/spool/cron/crontabs/root\"" >> "$BKP_PVE_SCRIPT"
echo "    \"/etc/hostname\"" >> "$BKP_PVE_SCRIPT"
echo "    \"/etc/hosts\"" >> "$BKP_PVE_SCRIPT"
echo "    \"/etc/fstab\"" >> "$BKP_PVE_SCRIPT"
echo "    \"/etc/pve/jobs.cfg\"" >> "$BKP_PVE_SCRIPT"
# Add more files here if needed
echo ")" >> "$BKP_PVE_SCRIPT"

echo "" >> "$BKP_PVE_SCRIPT"
echo "for file_path in \"\${FILES_TO_BACKUP[@]}\"; do" >> "$BKP_PVE_SCRIPT"
echo "    if [ -f \"\$file_path\" ]; then" >> "$BKP_PVE_SCRIPT"
echo "        zip -j \"\$ZIP_FILE\" \"\$file_path\" # -j junks paths" >> "$BKP_PVE_SCRIPT"
echo "    else" >> "$BKP_PVE_SCRIPT"
echo "        echo \"Aviso: Arquivo \$file_path não encontrado.\" >> \"\$MSG_FILE\"" >> "$BKP_PVE_SCRIPT"
echo "    fi" >> "$BKP_PVE_SCRIPT"
echo "done" >> "$BKP_PVE_SCRIPT"

echo "" >> "$BKP_PVE_SCRIPT"
echo "echo \"Copiando configurações de VMs (qemu-server)...\"" >> "$BKP_PVE_SCRIPT"
echo "if [ -d \"/etc/pve/nodes/\$PVENAME/qemu-server/\" ]; then" >> "$BKP_PVE_SCRIPT"
echo "    cp -r /etc/pve/nodes/\"\$PVENAME\"/qemu-server/*.conf \"\$TEMP_QEMU_DIR/\" 2>/dev/null || echo \"Nenhum arquivo .conf encontrado em qemu-server.\"" >> "$BKP_PVE_SCRIPT"
echo "    if ls \"\$TEMP_QEMU_DIR\"/*.conf 1> /dev/null 2>&1; then" >> "$BKP_PVE_SCRIPT"
echo "        zip -j \"\$ZIP_FILE\" \"\$TEMP_QEMU_DIR\"/*.conf" >> "$BKP_PVE_SCRIPT"
echo "    fi" >> "$BKP_PVE_SCRIPT"
echo "else" >> "$BKP_PVE_SCRIPT"
echo "    echo \"Aviso: Diretório /etc/pve/nodes/\$PVENAME/qemu-server/ não encontrado.\" >> \"\$MSG_FILE\"" >> "$BKP_PVE_SCRIPT"
echo "fi" >> "$BKP_PVE_SCRIPT"

echo "" >> "$BKP_PVE_SCRIPT"
echo "echo \"Copiando configurações do Postfix (se existir)...\"" >> "$BKP_PVE_SCRIPT"
echo "if [ -d \"/etc/postfix/\" ]; then" >> "$BKP_PVE_SCRIPT"
echo "    zip -r \"\$ZIP_FILE\" /etc/postfix/" >> "$BKP_PVE_SCRIPT" # Using -r to keep postfix structure
echo "else" >> "$BKP_PVE_SCRIPT"
echo "    echo \"Aviso: Diretório /etc/postfix/ não encontrado.\" >> \"\$MSG_FILE\"" >> "$BKP_PVE_SCRIPT"
echo "fi" >> "$BKP_PVE_SCRIPT"


echo "" >> "$BKP_PVE_SCRIPT"
echo "echo \"Log de email do dia \$CURRENT_DATE\" > \"\$MSG_FILE\"" >> "$BKP_PVE_SCRIPT"
echo "echo \"Backup das configurações do PVE '\$PVENAME' realizado em: \$ZIP_FILE\" >> \"\$MSG_FILE\"" >> "$BKP_PVE_SCRIPT"
echo "echo \"Verifique o anexo.\" >> \"\$MSG_FILE\"" >> "$BKP_PVE_SCRIPT"

echo "" >> "$BKP_PVE_SCRIPT"
echo "if command -v mutt &> /dev/null && [ -f \"\$ZIP_FILE\" ]; then" >> "$BKP_PVE_SCRIPT"
echo "    mutt -s \"\$PVENAME - Backup diário das configurações (\$CURRENT_DATE)\" \"\$EMAIL_TO\" < \"\$MSG_FILE\" -a \"\$ZIP_FILE\"" >> "$BKP_PVE_SCRIPT"
echo "    echo \"E-mail de backup enviado para \$EMAIL_TO.\"" >> "$BKP_PVE_SCRIPT"
echo "else" >> "$BKP_PVE_SCRIPT"
echo "    echo \"Comando 'mutt' não encontrado ou arquivo ZIP não criado. E-mail não enviado.\" >> \"\$MSG_FILE\"" >> "$BKP_PVE_SCRIPT"
echo "fi" >> "$BKP_PVE_SCRIPT"
echo "cat \"\$MSG_FILE\"" >> "$BKP_PVE_SCRIPT" # Output log to console

chmod +x "$BKP_PVE_SCRIPT"

# Add to crontab
# Remove existing entry to avoid duplicates, then add new one
(crontab -l 2>/dev/null | grep -v "$BKP_PVE_SCRIPT" ; echo "0 0 * * * $BKP_PVE_SCRIPT") | crontab -

echo ""
echo -e "${MENU}=== Agendamento de Backup Concluído ===${NORMAL}"
echo -e "${GREEN}Backup dos arquivos do PVE agendado para todos os dias às 00:00.${NORMAL}"
echo -e "${GREEN}Script de backup: $BKP_PVE_SCRIPT${NORMAL}"
echo -e "${GREEN}Arquivos de backup serão armazenados em: $BACKUP_DEST_DIR${NORMAL}"
echo -e "${GREEN}E-mail de notificação será enviado para: $CAMINHOEMAILBKP${NORMAL}"
echo -e "${MENU}Você pode executar o script $BKP_PVE_SCRIPT manualmente para testar.${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
