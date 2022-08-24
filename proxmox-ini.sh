#!/bin/bash
mv /TcTI/SCRIPTS/proxmox-conf.sh /TcTI/SCRIPTS/proxmox-conf-bkp.sh
wget https://raw.githubusercontent.com/TcTI-BR/PROXMOX-SCRIPTS/main/proxmox-conf.sh /TcTI/SCRIPTS/proxmox-conf.sh
chmod +x /TcTI/SCRIPTS/proxmox-conf.sh
/TcTI/SCRIPTS/proxmox-conf.sh
