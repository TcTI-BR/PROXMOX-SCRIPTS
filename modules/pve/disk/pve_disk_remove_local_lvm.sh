#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Remoção do Storage local-lvm ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then 
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1 
fi

echo -e "${RED_TEXT}AVISO: Esta operação removerá o storage 'local-lvm' e tentará redimensionar o 'local' (root).${NORMAL}"
echo -e "${RED_TEXT}Isto é destrutivo para os dados em 'local-lvm'. Faça backups!${NORMAL}"
read -r -p "Tem certeza que deseja remover 'local-lvm' e redimensionar 'root'? (s/N): " CONFIRM

if [[ "$CONFIRM" != [sS] && "$CONFIRM" != [yY] ]]; then
    echo "Operação cancelada pelo usuário."
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 0
fi

echo "Removendo LV 'data' de /dev/pve/..."
lvremove /dev/pve/data -y || echo -e "${RED_TEXT}Falha ao remover /dev/pve/data. Verifique se existe ou se está em uso.${NORMAL}"

echo "Redimensionando LV 'root' para usar 100% do espaço livre..."
lvresize -l +100%FREE /dev/pve/root || echo -e "${RED_TEXT}Falha ao redimensionar /dev/pve/root.${NORMAL}"

echo "Redimensionando o sistema de arquivos em /dev/mapper/pve-root..."
resize2fs /dev/mapper/pve-root || echo -e "${RED_TEXT}Falha ao redimensionar o sistema de arquivos em /dev/mapper/pve-root.${NORMAL}"

echo "Removendo 'local-lvm' da configuração de storage do PVE..."
pvesm remove local-lvm &>/dev/null || echo "Nota: Storage local-lvm não encontrado na configuração do PVE ou já removido."

echo ""
echo -e "${MENU}=== Remoção de 'local-lvm' e redimensionamento concluídos (tentativa). ===${NORMAL}"
echo "Verifique o status do LVM ('lvs'), dos storages PVE ('pvesm status') e do sistema de arquivos ('df -h')."
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
