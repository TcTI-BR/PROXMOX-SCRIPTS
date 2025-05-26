#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Adicionar VM ao Monitoramento do Watchdog ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

WATCHDOG_SCRIPTS_DIR="/TcTI/SCRIPTS/WATCHDOG" # As per original script logic
mkdir -p "$WATCHDOG_SCRIPTS_DIR" # Ensure directory exists

echo -e "${ENTER_LINE}Qual ID da VM a ser monitorada? EX: 100${NORMAL}"
read -r WATCHDOGVMID
if ! [[ "$WATCHDOGVMID" =~ ^[0-9]+$ ]]; then
    echo -e "${RED_TEXT}ID da VM inválido. Deve ser um número.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo -e "${ENTER_LINE}Qual o IP da VM a ser pingado para verificação? EX: 192.168.0.100${NORMAL}"
read -r WATCHDOGVMIP
if ! [[ "$WATCHDOGVMIP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED_TEXT}Endereço IP inválido.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

VM_WATCHDOG_SCRIPT="$WATCHDOG_SCRIPTS_DIR/$WATCHDOGVMID.sh"

echo -e "${MENU}Criando script de watchdog para VM $WATCHDOGVMID com IP $WATCHDOGVMIP em:${NORMAL}"
echo -e "${YELLOW_TEXT}$VM_WATCHDOG_SCRIPT${NORMAL}"

{
    echo "#!/bin/bash"
    echo "# Watchdog script for VMID $WATCHDOGVMID (IP: $WATCHDOGVMIP)"
    echo ""
    echo "PING_TARGET=\"$WATCHDOGVMIP\""
    echo "VMID_TO_MANAGE=\"$WATCHDOGVMID\""
    echo "LOG_FILE=\"/var/log/watchdog_\$VMID_TO_MANAGE.log\" # Optional: Log to a specific file"
    echo ""
    echo "echo \"[\$(date)] Verificando VM \$VMID_TO_MANAGE (IP: \$PING_TARGET)...\" >> \"\$LOG_FILE\""
    echo ""
    echo "if ping -c 4 \"\$PING_TARGET\" > /dev/null 2>&1; then"
    echo "    echo \"[\$(date)] Host \$PING_TARGET (VM \$VMID_TO_MANAGE) está respondendo.\" >> \"\$LOG_FILE\""
    echo "    # Optional: qm status \$VMID_TO_MANAGE >> \"\$LOG_FILE\" # Already running, usually not needed to log status
    echo "else"
    echo "    echo \"[\$(date)] Host \$PING_TARGET (VM \$VMID_TO_MANAGE) NÃO está respondendo. Tentando reiniciar...\" >> \"\$LOG_FILE\""
    echo "    if qm status \"\$VMID_TO_MANAGE\" | grep -q 'status: running'; then"
    echo "        echo \"[\$(date)] VM \$VMID_TO_MANAGE está listada como 'running'. Tentando 'qm stop' e 'qm start'.\" >> \"\$LOG_FILE\""
    echo "        qm stop \"\$VMID_TO_MANAGE\" >> \"\$LOG_FILE\" 2>&1"
    echo "        sleep 10 # Give time for VM to stop"
    echo "        qm start \"\$VMID_TO_MANAGE\" >> \"\$LOG_FILE\" 2>&1"
    echo "    else"
    echo "        echo \"[\$(date)] VM \$VMID_TO_MANAGE não está 'running'. Tentando 'qm start' diretamente.\" >> \"\$LOG_FILE\""
    echo "        qm start \"\$VMID_TO_MANAGE\" >> \"\$LOG_FILE\" 2>&1"
    echo "    fi"
    echo "    NEW_STATUS=\$(qm status \"\$VMID_TO_MANAGE\" 2>/dev/null)"
    echo "    echo \"[\$(date)] Novo status da VM \$VMID_TO_MANAGE após tentativa de reinício: \$NEW_STATUS\" >> \"\$LOG_FILE\""
    echo "fi"
    echo ""
} > "$VM_WATCHDOG_SCRIPT"

chmod +x "$VM_WATCHDOG_SCRIPT"

if [ -f "$VM_WATCHDOG_SCRIPT" ]; then
    echo -e "${GREEN}Script de watchdog para VM $WATCHDOGVMID criado com sucesso.${NORMAL}"
    echo "Certifique-se que o agendamento geral do watchdog está ativo (Opção 1 do menu Watchdog)."
else
    echo -e "${RED_TEXT}Falha ao criar o script de watchdog.${NORMAL}"
fi

echo ""
echo -e "${MENU}=== Adição de VM ao watchdog concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
