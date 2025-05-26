#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"

clear
echo -e "${MENU}=== Comandos PVE Úteis ===${NORMAL}"
# No root check needed for displaying information.

echo ""
echo -e "${GREEN_TEXT}qm list${NORMAL} = Listar todas as VMs e seus status."
echo -e "${GREEN_TEXT}qm status VMID${NORMAL} = Verificar status de uma VM específica."
echo -e "${GREEN_TEXT}qm stop VMID${NORMAL} = Desligar VM (gracefully)."
echo -e "${GREEN_TEXT}qm shutdown VMID${NORMAL} = Desligar VM (via ACPI, se configurado e suportado pela VM)."
echo -e "${GREEN_TEXT}qm start VMID${NORMAL} = Ligar VM."
echo -e "${GREEN_TEXT}qm unlock VMID${NORMAL} = Destrancar VM bloqueada (ex: durante backup)."
echo -e "${GREEN_TEXT}qm reset VMID${NORMAL} = Resetar VM (equivalente a um hard reset)."
echo -e "${GREEN_TEXT}qm clone VMID NOVO_VMID --name NOVO_NOME${NORMAL} = Clonar uma VM."
echo -e "${GREEN_TEXT}qm resize VMID virtio0 +10G${NORMAL} = Redimensionar disco da VM (ex: virtio0 para +10GB)."
echo ""
echo -e "${GREEN_TEXT}pct list${NORMAL} = Listar todos os containers LXC."
echo -e "${GREEN_TEXT}pct status CTID${NORMAL} = Verificar status de um container."
echo -e "${GREEN_TEXT}pct start CTID / pct stop CTID / pct shutdown CTID${NORMAL} = Gerenciar containers."
echo -e "${GREEN_TEXT}pct enter CTID${NORMAL} = Acessar o console do container."
echo ""
echo -e "${GREEN_TEXT}pvesm status${NORMAL} = Listar status de todos os storages configurados."
echo -e "${GREEN_TEXT}pvecm status${NORMAL} = Verificar status do cluster Proxmox VE."
echo -e "${GREEN_TEXT}pveversion -v${NORMAL} = Mostrar versão detalhada do PVE e pacotes relacionados."
echo ""

echo -e "${MENU}=== Fim da Lista de Comandos PVE. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
