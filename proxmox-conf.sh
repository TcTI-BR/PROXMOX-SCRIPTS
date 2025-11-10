mkdir -p /TcTI/SCRIPTS/PROXMOX
cd /TcTI/SCRIPTS/PROXMOX 
curl -sL -o main.sh https://raw.githubusercontent.com/TcTI-BR/PVE-SCRIPTS-V2/main/main.sh 
chmod +x main.sh


# Cria o arquivo de auto-inicialização
cat > /etc/profile.d/tcti-proxmox-auto.sh << 'EOF'
#!/bin/bash
cd /TcTI/SCRIPTS/PROXMOX
./main.sh
EOF

chmod +x /etc/profile.d/tcti-proxmox-auto.sh


./main.sh
