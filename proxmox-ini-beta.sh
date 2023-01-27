#!/bin/bash
mv /TcTI/SCRIPTS/proxmox-conf-beta.sh /TcTI/SCRIPTS/proxmox-conf-beta-bkp.sh
wget https://raw.githubusercontent.com/TcTI-BR/PROXMOX-SCRIPTS/main/proxmox-conf-beta.sh /TcTI/SCRIPTS/proxmox-conf-beta.sh
chmod +x /TcTI/SCRIPTS/proxmox-conf-beta.sh
/TcTI/SCRIPTS/proxmox-conf-beta.sh
