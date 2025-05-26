#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Instalação de Interface Gráfica (XFCE) e Chromium ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo -e "${MENU}Esta operação instalará XFCE, LightDM (gerenciador de login) e Chromium.${NORMAL}"
echo -e "${YELLOW_TEXT}Pode consumir uma quantidade significativa de espaço em disco e baixar muitos pacotes.${NORMAL}"
read -r -p "Deseja continuar com a instalação? (s/N): " CONFIRM

if [[ "$CONFIRM" != [sS] && "$CONFIRM" != [yY] ]]; then
    echo "Instalação cancelada pelo usuário."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

echo "Atualizando lista de pacotes..."
apt-get update

echo "Instalando XFCE, Chromium e LightDM..."
apt-get install xfce4 chromium lightdm -y

echo "Criando atalho do Chromium na área de trabalho do root..."
DESKTOP_DIR="/root/Desktop"
mkdir -p "$DESKTOP_DIR"
CHROMIUM_DESKTOP_FILE="$DESKTOP_DIR/Chromium Web Browser.desktop"

{
    echo "[Desktop Entry]"
    echo "Version=1.0"
    echo "Type=Application"
    echo "Name=Chromium Web Browser (Proxmox UI)"
    echo "Comment=Access the Proxmox Web UI via localhost"
    # Added --no-sandbox as it's often needed when running chromium as root, common in this context
    # Also directly opening the Proxmox UI
    echo "Exec=/usr/bin/chromium %U --no-sandbox --password-store=basic https://127.0.0.1:8006/"
    echo "Icon=chromium"
    echo "Path="
    echo "Terminal=false"
    echo "StartupNotify=true"
} > "$CHROMIUM_DESKTOP_FILE"

chmod +x "$CHROMIUM_DESKTOP_FILE"
echo "Atalho criado em $CHROMIUM_DESKTOP_FILE"

echo "Instalando dbus-x11 (necessário para startx em alguns ambientes)..."
apt-get install dbus-x11 -y

echo "Desabilitando o display manager de iniciar automaticamente no boot do servidor..."
# This is important for servers, GUI should be started manually if needed
systemctl disable lightdm &>/dev/null || echo "Nota: lightdm não pôde ser desabilitado via systemctl (pode não estar ativo)."
systemctl disable display-manager &>/dev/null || echo "Nota: display-manager genérico não pôde ser desabilitado."


if command -v xfce4-session &>/dev/null && command -v chromium &>/dev/null; then
    echo -e "${GREEN}Interface gráfica (XFCE) e Chromium instalados com sucesso.${NORMAL}"
    echo "Você pode tentar iniciar a interface gráfica com 'startx' ou 'systemctl start lightdm'."
    echo "Lembre-se que rodar GUI em servidores é geralmente para troubleshooting."
else
    echo -e "${RED_TEXT}Falha na verificação da instalação. Verifique os logs.${NORMAL}"
fi

echo ""
echo -e "${MENU}=== Instalação de GUI e Chromium concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
