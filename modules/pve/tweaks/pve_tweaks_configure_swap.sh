#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Configuração de SWAP ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

# Check if swap is enabled
if ! grep -q "swap" /proc/swaps; then
    echo -e "${YELLOW_TEXT}Nenhuma partição ou arquivo de SWAP ativo encontrado.${NORMAL}"
    echo "Este script atualmente lida apenas com o ajuste de 'swappiness' para SWAP existente."
    echo "Para criar SWAP, use ferramentas como 'fallocate' e 'mkswap'/'swapon' manualmente."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

current_swappiness=$(cat /proc/sys/vm/swappiness)
echo -e "Valor atual do vm.swappiness: ${GREEN}$current_swappiness${NORMAL}"
echo ""
echo "Valores de Swappiness:"
echo "  - 0:  O kernel evitará o SWAP o máximo possível."
echo "  - 1:  Mínima quantidade de SWAP (recomendado para servidores com muita RAM)."
echo "  - 10: Bom valor para muitos servidores Proxmox."
echo "  - 60: Valor padrão do Debian/Ubuntu."
echo "  - 100: O kernel usará SWAP agressivamente."
echo ""

read -r -p "Gostaria de editar o valor do swappiness? (s/N): " confirm_edit
if [[ "$confirm_edit" != [sS] && "$confirm_edit" != [yY] ]]; then
    echo "Nenhuma alteração feita."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

echo ""
read -r -p "Digite o novo valor para vm.swappiness (0-100): " new_swappiness
if ! [[ "$new_swappiness" =~ ^[0-9]+$ ]] || [ "$new_swappiness" -lt 0 ] || [ "$new_swappiness" -gt 100 ]; then
    echo -e "${RED_TEXT}Valor inválido. Deve ser um número entre 0 e 100.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo "Configurando vm.swappiness para $new_swappiness (temporário)..."
if ! sysctl vm.swappiness="$new_swappiness"; then
    echo -e "${RED_TEXT}Falha ao definir o valor temporário do swappiness.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo "Tornando a configuração vm.swappiness=$new_swappiness permanente em /etc/sysctl.d/99-swappiness.conf..."
echo "vm.swappiness=$new_swappiness" > /etc/sysctl.d/99-swappiness.conf

# Original script had swapoff/swapon logic which might be very disruptive.
# Generally, changing swappiness value does not require this for most systems.
# If it were for creating/resizing swap, then yes.
# For now, I'm omitting swapoff -a / swapon -a unless specifically requested.
# echo "Esvaziando o swap (pode levar algum tempo)..."
# swapoff -a
# echo "Re-habilitando o swap com o novo valor..."
# swapon -a

echo ""
echo -e "${GREEN}vm.swappiness configurado para $new_swappiness.${NORMAL}"
echo "A configuração foi aplicada imediatamente e persistirá após reinicializações."
echo -e "${MENU}=== Configuração de SWAP concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
