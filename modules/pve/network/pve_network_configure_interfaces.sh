#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Configuração de Interfaces de Rede (/etc/network/interfaces) ===${NORMAL}"

# Ensure script is run as root, as editing network interfaces requires it.
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo -e "${MENU}Você está prestes a editar o arquivo /etc/network/interfaces.${NORMAL}"
echo -e "${YELLOW_TEXT}Alterações incorretas podem levar à perda de conectividade de rede.${NORMAL}"
echo -e "${YELLOW_TEXT}Certifique-se de saber o que está fazendo ou tenha acesso físico ao servidor.${NORMAL}"
read -r -p "Deseja continuar e editar o arquivo? (s/N): " CONFIRM

if [[ "$CONFIRM" != [sS] && "$CONFIRM" != [yY] ]]; then
    echo "Edição cancelada pelo usuário."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

# Check if nano is installed, if not, try to install or suggest
if ! command -v nano &> /dev/null; then
    echo -e "${YELLOW_TEXT}Editor 'nano' não encontrado. Tentar instalar? (s/N) (Alternativamente, instale 'nano' manualmente)${NORMAL}"
    read -r CONFIRM_NANO
    if [[ "$CONFIRM_NANO" == [sS] || "$CONFIRM_NANO" == [yY] ]]; then
        apt update && apt install nano -y
        if ! command -v nano &> /dev/null; then
             echo -e "${RED_TEXT}Falha ao instalar 'nano'. Por favor, instale manualmente e tente novamente.${NORMAL}"
             read -n 1 -s -r -p "Pressione uma tecla para continuar..."
             exit 1
        fi
    else
        echo -e "${RED_TEXT}Editor 'nano' não disponível. Não é possível continuar.${NORMAL}"
        read -n 1 -s -r -p "Pressione uma tecla para continuar..."
        exit 1
    fi
fi

nano /etc/network/interfaces

echo ""
echo -e "${MENU}=== Edição de /etc/network/interfaces concluída. ===${NORMAL}"
echo "Lembre-se de aplicar as alterações de rede se necessário (ex: ifreload -a, ou reiniciando a rede/servidor)."
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
