#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Iniciar Interface Gráfica (XFCE) ===${NORMAL}"

# Check if X server might be running
if pgrep -x "Xorg" > /dev/null; then
    echo -e "${YELLOW_TEXT}Um servidor X (interface gráfica) parece já estar em execução.${NORMAL}"
    read -r -p "Tentar iniciar um novo servidor X mesmo assim? (s/N): " confirm_start_anyway
    if [[ "$confirm_start_anyway" != [sS] && "$confirm_start_anyway" != [yY] ]]; then
        echo "Operação cancelada."
        read -n 1 -s -r -p "Pressione uma tecla para continuar..."
        exit 0
    fi
fi

# Attempt to check if user is in a TTY. This is not perfectly reliable.
# /dev/tty[1-6] usually means a local console.
# /dev/pts/* usually means an SSH session.
current_tty=$(tty)
if [[ "$current_tty" != /dev/tty[0-9]* ]]; then
    echo -e "${RED_TEXT}AVISO: Você não parece estar em um console local (TTY).${NORMAL}"
    echo -e "${YELLOW_TEXT}Iniciar 'startx' via SSH geralmente não funciona ou não é o desejado.${NORMAL}"
    echo -e "${YELLOW_TEXT}Se você estiver usando SSH com X11 Forwarding, inicie aplicações X11 diretamente.${NORMAL}"
    echo -e "${YELLOW_TEXT}Se você deseja iniciar uma sessão de desktop no servidor físico, execute este comando a partir de um TTY local.${NORMAL}"
    read -r -p "Continuar tentando iniciar 'startx' mesmo assim? (s/N): " confirm_tty
    if [[ "$confirm_tty" != [sS] && "$confirm_tty" != [yY] ]]; then
        echo "Operação cancelada."
        read -n 1 -s -r -p "Pressione uma tecla para continuar..."
        exit 0
    fi
fi


echo -e "${MENU}Tentando iniciar a interface gráfica com 'startx'...${NORMAL}"
echo "Se o XFCE e LightDM foram instalados corretamente, isso deve iniciar uma sessão gráfica."
echo "Para sair da sessão gráfica, geralmente você pode fazer logout no menu do XFCE."
echo ""
echo -e "${YELLOW_TEXT}Pressione uma tecla para tentar iniciar 'startx'. Se falhar, você retornará aqui.${NORMAL}"
read -n 1 -s -r

# Before running startx, ensure dbus-x11 is running for the session if needed.
# This can be tricky without a full login manager.
# The 'dbus-launch startx' approach might be more robust for some cases.
# However, the original script just called 'startx'.
if ! command -v startx &> /dev/null; then
    echo -e "${RED_TEXT}Comando 'startx' não encontrado. Certifique-se que xinit está instalado (geralmente vem com xfce4).${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

startx

# This message will likely only be seen if startx fails or if the user exits the X session quickly.
echo ""
echo -e "${MENU}=== Tentativa de iniciar interface gráfica concluída. ===${NORMAL}"
echo "Se a interface não iniciou, verifique os logs (ex: /var/log/Xorg.0.log ou ~/.xsession-errors)."
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
