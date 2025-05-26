#!/bin/bash
MODULE_VERSION="1.1" # Incremented version

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== PVE: Instalar Script Proxmox Toolkit NG para Executar no Login ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

PROFILE_SCRIPT_PATH="/etc/profile.d/proxmox-toolkit-launcher.sh" # New name
LAUNCHER_PATH="/TcTI/PROXMOX_TOOLKIT/proxmox-launcher.sh" # New launcher path

echo -e "${MENU}Este script configurará o Proxmox Toolkit NG para iniciar automaticamente${NORMAL}"
echo -e "${MENU}quando o usuário root fizer login. O script de inicialização será criado em:${NORMAL}"
echo -e "${YELLOW_TEXT}$PROFILE_SCRIPT_PATH${NORMAL}"
echo -e "${MENU}Ele executará: ${YELLOW_TEXT}$LAUNCHER_PATH${NORMAL}"
read -r -p "Deseja continuar com a instalação? (s/N): " CONFIRM

if [[ "$CONFIRM" != [sS] && "$CONFIRM" != [yY] ]]; then
    echo "Instalação cancelada pelo usuário."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

# Create the script in /etc/profile.d
{
    echo "#!/bin/bash"
    echo "# TcTI Proxmox Toolkit NG Launcher"
    echo "if [ \"\$(id -u)\" -eq 0 ]; then" # Only run for root user
    echo "    if [ -f \"$LAUNCHER_PATH\" ]; then"
    echo "        echo 'Iniciando Proxmox Toolkit NG automaticamente...'"
    echo "        cd \"$(dirname "$LAUNCHER_PATH")\"" # cd to the launcher's directory
    echo "        ./\"$(basename "$LAUNCHER_PATH")\"" # Execute the launcher
    echo "    fi"
    echo "fi"
} > "$PROFILE_SCRIPT_PATH"

chmod +x "$PROFILE_SCRIPT_PATH"

if [ -f "$PROFILE_SCRIPT_PATH" ]; then
    echo -e "${GREEN_TEXT}Script instalado com sucesso em $PROFILE_SCRIPT_PATH${NORMAL}"
    echo "O Proxmox Toolkit NG será iniciado automaticamente no próximo login do usuário root."
else
    echo -e "${RED_TEXT}Falha ao criar o script em $PROFILE_SCRIPT_PATH.${NORMAL}"
fi

echo ""
echo -e "${MENU}=== Instalação de script no login PVE concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
