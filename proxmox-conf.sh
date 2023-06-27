#!/bin/bash

# toda a base do script foi inspirado no  https://github.com/Tontonjo/proxmox_toolbox.git
 
version=V002.R001
# changelog

clear
echo -e "\033[33m *********************************************************************************** \033[0m"
echo -e "\033[33m * Atenção! O uso do script fornecido é de inteira responsabilidade do utilizador. *\n * A pessoa ou empresa que forneceu o script não será responsável por quaisquer    *\n *\033[31mproblemas ou danos causados\033[33m pelo uso do mesmo.                                   *\033[0m"
echo -e "\033[33m *                                                                                 * \033[0m"
echo -e "\033[33m * Antes de utilizar o script, é importante que você faça uma avaliação cuidadosa e*\n *compreenda as implicações do seu uso. \033[31mCertifique-se de que o script é            \033[33m*\n *\033[0m\033[31mseguro e adequado\033[33m para as suas necessidades antes de utilizá-lo.                 *\033[0m"
echo -e "\033[33m *                                                                                 * \033[0m"
echo -e "\033[33m * Em resumo, \033[31mutilize o script por sua conta e risco\033[33m. A pessoa ou empresa          *\n *que forneceu o script não será responsável por quaisquer problemas ou            *\n *danos causadospelo seu uso.                                                      *\033[0m"
echo -e "\033[33m *                                                                                 * \033[0m"
echo -e "\033[33m * Ao pressionar uma tecla você concorda com os riscos...                          *\033[0m"
echo -e "\033[33m *********************************************************************************** \033[0m"
read -p  " "
clear

# Verificando se é root
if [[ $(id -u) -ne 0 ]] ; then echo "- Por favor execute com o root / sudo" ; exit 1 ; fi

# -----------------VARIAVEIS DE SISTEMA----------------------
dnstesthost=google.com.br
pve_log_folder="/var/log/pve/tasks/"
proxmoxlib="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"
distribution=$(. /etc/*-release;echo $VERSION_CODENAME)
execdir=$(dirname $0)
hostname=$(hostname)
date=$(date +%Y_%m_%d-%H_%M_%S)
# ---------------FIM DAS VARIAVEIS DE SISTEMA-----------------

main_menu(){
    clear
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}******************* Script ($version) para Proxmox *******************${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
    echo " "
    echo -e "${MENU}**${NUMBER} 1)${MENU} Proxmox Virtual Environment ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Proxmox Backup Server ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Sair ${NORMAL}"
    echo " "
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
    read -rsn1 opt
	while [ opt != '' ]
  do
    if [[ $opt = "" ]]; then
      exit;
    else
      case $opt in
	   	1) clear;
		pve_menu
			;;
	    2) clear;
		pbs_menu
			;;
		0)
		clear
		exit
			;;
		*)
		clear
		exit
			;;
      esac
    fi
  done
  main_menu
}


pve_menu(){
    clear
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}********* Script ($version) para Proxmox Virtual Environment *********${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
    echo " "
    echo -e "${MENU}**${NUMBER} 1)${MENU} Atualização, instalação e upgrade do sistema ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Ferramentas de disco ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Tarefas de backup ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Configuração do email ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 5)${MENU} Configurações e ajustes ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 6)${MENU} Configurações de rede ${NORMAL}"	
    echo -e "${MENU}**${NUMBER} 7)${MENU} Comandos e informações úteis  ${NORMAL}"	
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
    echo " "
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
    read -rsn1 opt
	while [ opt != '' ]
  do
    if [[ $opt = "" ]]; then
      exit;
    else
      case $opt in
   	
	   	1) clear;
		update_menu
			;;
	    2) clear;
		disco_menu
			;;
	    3) clear;
		bkp_menu
			;;
	    4) clear;
		email_menu
			;;
	    5) clear;
		tweaks_menu
			;;
	    6) clear;
		lan_menu
			;;
	    7) clear;
		com_menu
			;;	  
		0)
		clear
		main_menu
			;;
		*)
		clear
		main_menu
			;;
      esac
    fi
  done
  pve_menu
}

update_menu(){
	clear
	NORMAL=`echo "\033[m"`
	MENU=`echo "\033[36m"` #Blue
	NUMBER=`echo "\033[33m"` #yellow
	FGRED=`echo "\033[41m"`
	RED_TEXT=`echo "\033[31m"`
	ENTER_LINE=`echo "\033[33m"`
	echo -e "${MENU}********* Script ($version) para Proxmox Virtual Environment *********${NORMAL}"
	echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
	echo " "
	echo -e "${MENU}**${NUMBER} 1)${MENU} Upgrade de versões ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Atualização do sistema e instalação de aplicativos mais utilizados ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
	echo " "
	echo -e "${MENU}***********************************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
	read -rsn1 opt
	while [ opt != '' ]
   do
	if [[ $opt = "" ]]; then
	  exit;
	else
	  case $opt in
		1) clear;
		upgrade_menu
			;;
		2) clear;
		mv /etc/apt/sources.list.d/pve-enterprise.list /root/
		clear
		sed -i '/subscription/d' /etc/apt/sources.list
		echo "deb http://download.proxmox.com/debian/pve $distribution pve-no-subscription" >> /etc/apt/sources.list
		apt update
		apt upgrade -y
		apt install libsasl2-modules -y
		apt install lm-sensors
		apt install ifupdown2 -y
		apt install ntfs-3g -y
		apt install ethtool -y
		apt install zip -y
		apt install mutt -y 			
		read -p "Pressione uma tecla para continuar..."
		clear 
		update_menu;	
			;;
		0) clear;
		pve_menu;
			;;
		*)clear;
		pve_menu;
			;;
      esac
    fi
  done
}

upgrade_menu(){
	clear
	NORMAL=`echo "\033[m"`
	MENU=`echo "\033[36m"` #Blue
	NUMBER=`echo "\033[33m"` #yellow
	FGRED=`echo "\033[41m"`
	RED_TEXT=`echo "\033[31m"`
	ENTER_LINE=`echo "\033[33m"`
	echo -e "${MENU}********* Script ($version) para Proxmox Virtual Environment *********${NORMAL}"
	echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
	echo " "
	echo -e "${MENU}**${NUMBER} 1)${MENU} Upgrade da versão 5x para a versão 6x ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Upgrade da versão 6x para a versão 7x ${NORMAL}"
 	echo -e "${MENU}**${NUMBER} 3)${MENU} Upgrade da versão 7x para a versão 8x ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
	echo " "
	echo -e "${MENU}***********************************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
	read -rsn1 opt
	while [ opt != '' ]
   do
	if [[ $opt = "" ]]; then
	  exit;
	else
	  case $opt in
		1) clear;
		mv /etc/apt/sources.list.d/pve-enterprise.list /root/
		clear
		systemctl stop pve-ha-lrm
		systemctl stop pve-ha-crm
		echo "deb http://download.proxmox.com/debian/corosync-3/ stretch main" > /etc/apt/sources.list.d/corosync3.list
		apt update
		apt dist-upgrade -y
		systemctl start pve-ha-lrm
		systemctl start pve-ha-crm
		apt update
		apt dist-upgrade -y
		sed -i 's/stretch/buster/g' /etc/apt/sources.list
		echo "deb http://download.proxmox.com/debian/pve buster pve-no-subscription" > /etc/apt/sources.list.d/sources.list
		sed -i -e 's/stretch/buster/g' /etc/apt/sources.list.d/pve-install-repo.list 
		echo "deb http://download.proxmox.com/debian/ceph-luminous buster main" > /etc/apt/sources.list.d/ceph.list
		apt update
		apt dist-upgrade -y
		rm /etc/apt/sources.list.d/corosync3.list
		apt update
		apt dist-upgrade -y
		apt remove linux-image-amd64
		systemctl disable display-manager
		clear
		read -p "Pressione uma tecla para continuar..."
		clear
		update_menu;
			;;
		2) clear;
		mv /etc/apt/sources.list.d/pve-enterprise.list /root/
		clear
		sed -i '/proxmox/d' /etc/apt/sources.list
		echo	"deb http://download.proxmox.com/debian/pve buster pve-no-subscription"	>> /etc/apt/sources.list
		dpkg --configure -a
		apt update
		apt upgrade -y
		sed -i '/proxmox/d' /etc/apt/sources.list
		sed -i '/debian/d' /etc/apt/sources.list
		sed -i '/update/d' /etc/apt/sources.list
		echo "deb http://security.debian.org/debian-security bullseye-security main contrib" >> /etc/apt/sources.list
		echo "deb http://ftp.debian.org/debian bullseye-updates main contrib" >> /etc/apt/sources.list
		echo "deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription" >> /etc/apt/sources.list
		echo "deb http://ftp.debian.org/debian bullseye main contrib" >> /etc/apt/sources.list
		apt update
		apt upgrade -y
		apt dist-upgrade
		systemctl disable display-manager
		clear
		read -p "Pressione uma tecla para continuar..."
		clear
		upgrade_menu;	
			;;
   		3) clear;
		mv /etc/apt/sources.list.d/pve-enterprise.list /root/
		clear
  		apt update
		apt upgrade -y
		sed -i '/proxmox/d' /etc/apt/sources.list
		sed -i '/debian/d' /etc/apt/sources.list
		sed -i '/update/d' /etc/apt/sources.list
		echo "deb http://security.debian.org/debian-security bookworm-security main contrib" >> /etc/apt/sources.list
		echo "deb http://ftp.debian.org/debian bookworm-updates main contrib" >> /etc/apt/sources.list
		echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" >> /etc/apt/sources.list
		echo "deb http://ftp.debian.org/debian bookworm main contrib" >> /etc/apt/sources.list
		apt update
		apt upgrade -y
		apt dist-upgrade
		systemctl disable display-manager
		clear
		read -p "Pressione uma tecla para continuar..."
		clear
		upgrade_menu;	
			;;
		0) clear;
		update_menu;
			;;
		*)clear;
		update_menu;
			;;
      esac
    fi
  done
}

disco_menu(){
	clear
	NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}********* Script ($version) para Proxmox Virtual Environment *********${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
	echo " "
	echo -e "${MENU}**${NUMBER} 1)${MENU} Configura discos ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Teste de velocidade dos discos ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 3)${MENU} Verifica setores defeituosos em discos ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 4)${MENU} Verifica o SMART do disco ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 5)${MENU} Remove o storage local-lvm ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
	echo " "
	echo -e "${MENU}***********************************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
	read -rsn1 opt
		while [ opt != '' ]	
	do
		if [[ $opt = "" ]]; then
			exit;
		else
	case $opt in
		1) clear
		lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
		echo "Qual o disco que vai ser preparado? EX: sda / nvme0n1"
		read FORMATADISCO
		echo "Qual o nome do Storage? EX: VM01 / RECOVER / BACKUP_2HD / BACKUP_REDE / EXTERNO_TERCA / EXTERNO_QUINTA"
		read STORAGE
		echo "O disco será para backup ou VM?: Digite exatamente "images" para VM ou "backup" para BACKUP sem as aspas"
		read IMAGEBACKUP
		pvesm remove $STORAGE
		echo -e "g\nn\np\n1\n\n\nw" | fdisk /dev/$FORMATADISCO
		mkfs.ext4 -L $STORAGE /dev/$FORMATADISCO
		mkdir -p /mnt/$STORAGE
		sed -i /"$STORAGE"/d /etc/fstab
		echo "" >> /etc/fstab
		echo "LABEL=$STORAGE /mnt/$STORAGE ext4 defaults,auto,nofail 0 0" >> /etc/fstab
		mount -a
		pvesm add dir $STORAGE --path /mnt/$STORAGE --content $IMAGEBACKUP 
		read -p "Pressione uma tecla para continuar..."
		clear
		disco_menu
			;;
		2) clear
		lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
		echo "Qual disco será testado o desempenho? EX: sda / nvme0n1"
		read TESTEDISCO
		clear
		hdparm -tT /dev/$TESTEDISCO
		read -p "Pressione uma tecla para continuar..."
		clear
		disco_menu
			;;
		3) clear
		lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
		echo "Qual disco será testado os setores? EX: sda / nvme0n1"
		read TESTESETORES
		clear
		badblocks -sv -c 10240 /dev/$TESTESETORES
		read -p "Pressione uma tecla para continuar..."
		disco_menu
			;;
		4) clear
		lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
		echo "Qual disco será verificado o status do SMART? EX: sda / nvme0n1"
		read TESTESMART
		clear
		smartctl -a /dev/$TESTESMART
		read -p "Pressione uma tecla para continuar..."
		disco_menu
			;;
		5) clear
		lvremove /dev/pve/data
		lvresize -l +100%FREE /dev/pve/root
		resize2fs /dev/mapper/pve-root
		pvesm remove local-lvm
		read -p "Pressione uma tecla para continuar..."
		disco_menu
			;;			
		0) clear;
		pve_menu;
			;;
		*)clear;
		pve_menu;
			;;
      esac
    fi
  done
}

bkp_menu(){
	clear
	NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}********* Script ($version) para Proxmox Virtual Environment *********${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
	echo " "
	echo -e "${MENU}**${NUMBER} 1)${MENU} Configura o serviço de NFS para receber o BACKUP em rede do PROXMOX ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Instala o PBS lado a lado com o PVE ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 3)${MENU} Agenda o BACKUP das configurações do PROXMOX ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 4)${MENU} Restaura o BACKUP das configurações do PROXMOX ${NORMAL}"			
	echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
	echo " "
	echo -e "${MENU}***********************************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
	read -rsn1 opt
	while [ opt != '' ]	
	do
		if [[ $opt = "" ]]; then
			exit;
		else
	case $opt in
		1) clear
		echo "Qual IP do computador cliente? EX: 192.168.0.230?"
		read IPDOCLIENTENFS
		echo "Qual o Storage de Backup? EX: BACKUP_2HD?"
		read STORAGEBACKUP
		apt-get install nfs-kernel-server -y
		echo	"/mnt/$STORAGEBACKUP/ $IPDOCLIENTENFS(rw,async,no_subtree_check)"	>	/etc/exports
		service nfs-kernel-server restart
		exportfs -a
		chmod -R 777 /mnt/$STORAGEBACKUP/dump
		read -p "Pressione uma tecla para continuar..."
		clear
		bkp_menu
			;;
		2) clear	
		echo deb http://download.proxmox.com/debian/pbs $distribution pbs-no-subscription >> /etc/apt/sources.list
		apt update
		apt update
		apt-get install proxmox-backup-server
		echo "PBS instalado!"
		read -p "Pressione uma tecla para continuar..."
		clear
		bkp_menu
			;;	
		3) clear	
		lsblk -o LABEL
		echo "Qual a unidade que vai manter uma copia dos arquivos de configuracao?"
		read CAMINHOBKP
		echo "Qual o e-mail que vai receber uma copia dos arquivos de configuracao?"
		read CAMINHOEMAILBKP
		mkdir /mnt/$CAMINHOBKP/BKP-PVE
		mkdir -p /TcTI/SCRIPTS/BKP-PVE/TEMP-BKP/QEMU
		echo "CAMINHOLOCAL=$CAMINHOBKP" > /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh						
		echo "PVENAME=$(hostname)" >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo "CAMINHOEMAIL=$CAMINHOEMAILBKP" >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/pve/vzdump.cron' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/pve/storage.cfg' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/pve/user.cfg' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/pve/datacenter.cfg' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/network/interfaces' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/resolv.conf' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /var/spool/cron/crontabs/root' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/hostname' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'cp -r /etc/pve/nodes/$PVENAME/qemu-server/*.conf /TcTI/SCRIPTS/BKP-PVE/TEMP-BKP/QEMU/' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /TcTI/SCRIPTS/BKP-PVE/TEMP-BKP/QEMU/*.conf' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/hosts' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/fstab' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/pve/jobs.cfg' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'zip /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip /etc/postfix/' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'echo "Log de email do dia $(date +%d-%m-%Y)" > /TcTI/SCRIPTS/BKP-PVE/msg.txt' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		echo 'mutt -s "$(hostname -f) - Backup diário das configurações"  $CAMINHOEMAIL < /TcTI/SCRIPTS/BKP-PVE/msg.txt  -a /mnt/$CAMINHOLOCAL/BKP-PVE/$(date +%d-%m-%Y).zip' >> /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		chmod +x /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		sed -i '/BKP-PVE/d' /var/spool/cron/crontabs/root
        echo "0 0 * * * /TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh" >> /var/spool/cron/crontabs/root
		/TcTI/SCRIPTS/BKP-PVE/BKP-PVE.sh
		clear
		echo -e "\033[33m Backup dos arquivos do PVE agendado para todos os dias as \033[31m00:00\033[33m \033[0m"
		echo -e "\033[33m Armazenando no local \033[31m/mnt/$CAMINHOBKP/BKP-PVE\033[33m \033[0m"
        echo -e "\033[33m Envia por e-mail uma copia no endereço \033[31m$CAMINHOEMAILBKP\033[33m \033[0m"
		echo -e "\033[33m Revise as configurações acima, caso necessário refaça, utilizando o mesmo caminho no script\033[0m"
		echo -e "\033[33mPressione uma tecla para continuar...\033[0m"
		read -p  " "
		clear
		bkp_menu
			;;	
		4) clear	
		echo -e "\033[31mAtenção\033[33m! Essa opção vai recuperar o Backup selecionado \033[31mapagando\033[33m as configurações atuais.\033[0m"
		read -p  " "
		lsblk -o LABEL
		echo "Qual a unidade que estão os arquivos de configuracao?"
		read RECUPERABKP
		mkdir /mnt/RECUPERAPVE
		PVENAME=$(hostname)
		mount LABEL=$RECUPERABKP /mnt/RECUPERAPVE
		ls -t /mnt/RECUPERAPVE/BKP-PVE/ 
		echo "Qual o arquivo a ser recuperado, não precisa da extensão EX:20-02-2023?"
		read RESTAURABKP
		clear
		apt update
		apt install zip -y
		clear	
		unzip /mnt/RECUPERAPVE/BKP-PVE/$RESTAURABKP.zip -d /TcTI/SCRIPTS/TMP-RECUPERA
		if [ -f /etc/pve/nodes/$PVENAME/qemu-server/ ]; then
				echo -e "\033[33mDeseja restaurar a pasta \033[31m/etc/pve/nodes/$PVENAME/qemu-server/\033[33m (s/n) \033[0m"
					read -p "" QEMUSERVER
				if [ "$QEMUSERVER"  = "s" ]; then
			cp -r /TcTI/SCRIPTS/BKP-PVE/TEMP-BKP/QEMU/qemu-server/ /etc/pve/nodes/$PVENAME/qemu-server/
		fi
		else
			cp -r /TcTI/SCRIPTS/BKP-PVE/TEMP-BKP/QEMU/qemu-server/ /etc/pve/nodes/$PVENAME/qemu-server/
				echo -e "\033[33mA pasta \033[31m/etc/pve/nodes/$PVENAME/qemu-server/\033[33m não foi encontrada, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi
		
		if [ -f /etc/fstab ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/fstab\033[33m (s/n) \033[0m"
					read -p "" FSTAB
				if [ "$FSTAB"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/fstab /etc/fstab
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/fstab /etc/fstab
				echo -e "\033[33mArquivo \033[31m/etc/fstab\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi
		
		if [ -f /etc/pve/vzdump.cron ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/pve/vzdump.cron\033[33m (s/n) \033[0m"
					read -p "" VZDUMPCRON
				if [ "$VZDUMPCRON"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/vzdump.cron /etc/pve/vzdump.cron
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/vzdump.cron /etc/pve/vzdump.cron
				echo -e "\033[33mArquivo \033[31m/etc/pve/vzdump.cron\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi

		if [ -f /etc/pve/storage.cfg ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/pve/storage.cfg\033[33m (s/n) \033[0m"
					read -p "" STORAGECFG
				if [ "$STORAGECFG"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/storage.cfg /etc/pve/storage.cfg
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/storage.cfg /etc/pve/storage.cfg
				echo -e "\033[33mArquivo \033[31m/etc/pve/storage.cfg\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi		
		
		if [ -f /etc/pve/user.cfg ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/pve/user.cfg\033[33m (s/n) \033[0m"
					read -p "" USERCFG
				if [ "$USERCFG"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/user.cfg /etc/pve/user.cfg
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/user.cfg /etc/pve/user.cfg
				echo -e "\033[33mArquivo \033[31m/etc/pve/user.cfg\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi		
		
		if [ -f /etc/pve/datacenter.cfg ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/pve/datacenter.cfg\033[33m (s/n) \033[0m"
					read -p "" DATACENTERCFG
				if [ "$DATACENTERCFG"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/datacenter.cfg /etc/pve/datacenter.cfg
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/datacenter.cfg /etc/pve/datacenter.cfg
				echo -e "\033[33mArquivo \033[31m/etc/pve/datacenter.cfg\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi		
		
		if [ -f /etc/network/interfaces ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/network/interfaces\033[33m (s/n) \033[0m"
					read -p "" INTERFACES
				if [ "$INTERFACES"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/network/interfaces /etc/network/interfaces
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/network/interfaces /etc/network/interfaces
				echo -e "\033[33mArquivo \033[31m/etc/network/interfaces\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi		
		
		if [ -f /etc/resolv.conf ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/resolv.conf\033[33m (s/n) \033[0m"
					read -p "" RESOLVCONF
				if [ "$RESOLVCONF"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/resolv.conf /etc/resolv.conf
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/resolv.conf /etc/resolv.conf
				echo -e "\033[33mArquivo \033[31m/etc/resolv.conf\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi
				
		if [ -f /var/spool/cron/crontabs/root ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/var/spool/cron/crontabs/root\033[33m (s/n) \033[0m"
					read -p "" CRONTABROOT
				if [ "$CRONTABROOT"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/var/spool/cron/crontabs/root /var/spool/cron/crontabs/root
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/var/spool/cron/crontabs/root /var/spool/cron/crontabs/root
				echo -e "\033[33mArquivo \033[31m/var/spool/cron/crontabs/root\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi		

		if [ -f /etc/hostname ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/hostname\033[33m (s/n) \033[0m"
					read -p "" HOSTNAME
				if [ "$HOSTNAME"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/hostname /etc/hostname
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/hostname /etc/hostname
				echo -e "\033[33mArquivo \033[31m/etc/hostname\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi

		if [ -f /etc/hosts ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/hosts\033[33m (s/n) \033[0m"
					read -p "" HOSTS
				if [ "$HOSTS"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/hosts /etc/hosts
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/hosts /etc/hosts
				echo -e "\033[33mArquivo \033[31m/etc/hosts\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi
		
		if [ -f /etc/pve/jobs.cfg ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/pve/jobs.cfg\033[33m (s/n) \033[0m"
					read -p "" JOBSCFG
				if [ "$JOBSCFG"  = "s" ]; then
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/jobs.cfg /etc/pve/jobs.cfg
		fi
		else
			cp /TcTI/SCRIPTS/TMP-RECUPERA/etc/pve/jobs.cfg /etc/pve/jobs.cfg
				echo -e "\033[33mArquivo \033[31m/etc/pve/jobs.cfg\033[33m não encontrado, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi
		
		if [ -f /etc/postfix/ ]; then
				echo -e "\033[33mDeseja restaurar o arquivo \033[31m/etc/postfix/\033[33m (s/n) \033[0m"
					read -p "" POSTFIX
				if [ "$POSTFIX"  = "s" ]; then
			cp -r /TcTI/SCRIPTS/TMP-RECUPERA/etc/postfix/ /etc/postfix/
		fi
		else
			cp -r /TcTI/SCRIPTS/TMP-RECUPERA/etc/postfix/ /etc/postfix/
				echo -e "\033[33mA pasta \033[31m/etc/postfix/\033[33m não foi encontrada, recuperado do backup, aperte \033[31mENTER\033[33m \033[0m"
			read -p ""
		fi
		echo -e "\033[33m Arquivos recuperados, aperte \033[31mENTER\033[33m para reiniciar.\033[0m"
		read -p  " "
		umount /mnt/RECUPERAPVE/
		rmdir /mnt/RECUPERAPVE/
		read -p  " "
		reboot
		clear
		bkp_menu
			;;				
		0) clear;
		pve_menu;
			;;
		*)clear;
		pve_menu;
			;;
      esac
    fi
  done
}

email_menu(){
	clear
	NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}********* Script ($version) para Proxmox Virtual Environment *********${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
	echo " "
	echo -e "${MENU}**${NUMBER} 1)${MENU} Configura o serviço de e-mail ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Testa as configurações ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 3)${MENU} Verifica os logs para tentar executar a correção ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 4)${MENU} Restaura a configuração original  ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
	echo " "
	echo -e "${MENU}***********************************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
	read -rsn1 opt
	while [ opt != '' ]	
	do
		if [[ $opt = "" ]]; then
			 exit;
		else
	case $opt in
		1) clear
		echo "- Endereço de e-mail do destinatário do administrador do sistema (conta@dominioexemplo.com) (root alias): "
		read 'varrootmail'
		echo "- Qual é o endereço do host do servidor de e-mail? (smtp.gmail.com): "
		read 'varmailserver'
		echo "- Qual é a porta do servidor de e-mail? (Normalmente 587 (sem tls)): "
		read 'varmailport'
		read -p  "- O servidor de e-mail requer TLS? s = sim / n = não: " -n 1 -r 
		if [[ $REPLY =~ ^[Ss]$ ]]; then
		vartls=yes
		else
		vartls=no
		fi
		echo " "
		echo "- O nome do usuário de autenticação? (EX: email@dominioexemplo.com.br): "
		read 'varmailusername'
		echo "- Qual é a senha de autenticação?: "
		read 'varmailpassword'
		echo "- O endereço de e-mail que envia é o mesmo que o usuário de autenticação?"
		read -p " s para usar $varmailusername / Enter para não: " -n 1 -r 
		if [[ $REPLY =~ ^[Ss]$ ]]; then
		varsenderaddress=$varmailusername
		else
		echo " "
		echo "- Qual é o endereço de e-mail do remetente?: "
		read 'varsenderaddress'
		fi
		echo " "
		echo "- Executando...!"
		echo " "
		echo "- Definindo aliases"
		if grep "root:" /etc/aliases
		then
		echo "- A entrada de alias foi encontrada: editando para $varrootmail"
		sed -i "s/^root:.*$/root: $varrootmail/" /etc/aliases
		else
		echo "- Nenhum alias do root encontrado: Adicionando"
		echo "root: $varrootmail" >> /etc/aliases
		fi
		#Configurando o arquivo canônico para o remetente - :
		echo "root $varsenderaddress" > /etc/postfix/canonical
		chmod 600 /etc/postfix/canonical
		# Preparando para o hash da senha
		echo [$varmailserver]:$varmailport $varmailusername:$varmailpassword > /etc/postfix/sasl_passwd
		chmod 600 /etc/postfix/sasl_passwd 
		# Adicionando o servidor de email no arquivo main.cf
		sed -i "/#/!s/\(relayhost[[:space:]]*=[[:space:]]*\)\(.*\)/\1"[$varmailserver]:"$varmailport""/"  /etc/postfix/main.cf
		# Verificando as configurações de TLS
		echo "- Definindo as configurações de TLS corretas: $vartls"
		postconf smtp_use_tls=$vartls
		# Verificando a entrada de hash da senha
		if grep "smtp_sasl_password_maps" /etc/postfix/main.cf
		then
		echo "- Hash da senha já configurado"
		else
		echo "- Adicionando entrada de hash da senha"
		postconf smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd
		fi
		# Verificando o certificado
		if grep "smtp_tls_CAfile" /etc/postfix/main.cf
		then
		echo "- O arquivo TLS CA parece configurado"
		else
		postconf smtp_tls_CAfile=/etc/ssl/certs/ca-certificates.crt
		fi
		# Adicionando opções de segurança sasl
		# eliminates default security options which are imcompatible with gmail
		if grep "smtp_sasl_security_options" /etc/postfix/main.cf
		then
		echo "- Configuração de smtp_sasl_security_options do Google"
		else
		postconf smtp_sasl_security_options=noanonymous
		fi
		if grep "smtp_sasl_auth_enable" /etc/postfix/main.cf
		then
		echo "- Autenticação já habilitada"
		else
		postconf smtp_sasl_auth_enable=yes
		fi 
		if grep "sender_canonical_maps" /etc/postfix/main.cf
		then
		echo "- Entrada canônica já existente"
		else
		postconf sender_canonical_maps=hash:/etc/postfix/canonical
		fi 
		echo "- Criptografia de senha e entrada canônica"
		postmap /etc/postfix/sasl_passwd
		postmap /etc/postfix/canonical
		apt update
		apt install libsasl2-modules -y
		echo "- Reiniciando o postfix e habilitando a inicialização automática"
		systemctl restart postfix && systemctl enable postfix
		echo "- Limpando o arquivo usado para gerar hash de senha"
		rm -rf "/etc/postfix/sasl_passwd"
		echo "- Removido arquivos"
		email_menu
			;;
		2) clear;
		echo "- Qual é o endereço de e-mail do destinatário? :"
		read vardestaddress
		echo "- Um e-mail será enviado para: $vardestaddress"
		echo “Esse e-mail confirma que a configuração do seu PVE esta ok!” | mail -s "Teste de e-mail - $hostname - $date" $vardestaddress
		echo "- O e-mail deveria ter sido enviado - Se nenhum for recebido, verifique se há erros no menu 3"
		read -p "Pressione uma tecla para continuar..."
		email_menu
			;;
		3) clear;
		echo "- Verificando se a erros nos logs"
		if grep "SMTPUTF8 is required" "/var/log/mail.log"
		then
		echo "- Encontrado erros no log - SMTPUTF8 é requerido"
		if grep "smtputf8_enable = no" /etc/postfix/main.cf
		then
		echo "- Executado correção!"
		else
		echo " "
		echo "- Configuração "smtputf8_enable=no" para correta "SMTPUTF8 was required but not supported""
		postconf smtputf8_enable=no
		postfix reload
		fi 
		elif grep "Network is unreachable" "/var/log/mail.log"; then
		read -p "- Você está no IPv4 e seu host pode resolver e acessar endereços públicos? s = sim / n = não: " -n 1 -r
		if [[ $REPLY =~ ^[Ss]$ ]]; then
		if grep "inet_protocols = ipv4" /etc/postfix/main.cf
		then
		echo "- Executado correção!"
		else
		echo " "
		echo "- Configuração "inet_protocols = ipv4 " para o correto ""Network is unreachable" caused by ipv6 resolution""
		postconf inet_protocols=ipv4
		postfix reload
		fi
		fi
		elif grep "smtp_tls_security_level = encrypt" "/var/log/mail.log"; then		
		echo "- Encontrado erros no log - smtp_tls_security_level = encrypt is required"
		if grep "smtp_tls_security_level = encrypt" /etc/postfix/main.cf; then
		echo "- Executado correção!"
		else
		echo " "
		echo "- Setting "smtp_tls_security_level = encrypt" to correct"
		postconf inet_protocols=ipv4
		postfix reload
		fi
		elif grep "smtp_tls_wrappermode = yes" "/var/log/mail.log"; then		
		echo "- Encontrado erros no log - smtp_tls_wrappermode = yes is required"
		if grep "smtp_tls_wrappermode = yes" /etc/postfix/main.cf; then
		echo "- Executado correção!"
		else
		echo " "
		echo "- Configuração "smtp_tls_wrappermode = yes" para o correto"
		postconf smtp_tls_wrappermode=yes
		postfix reload
		fi
		else
		echo "- Não foram encontrados erros!"
		read -p "Pressione uma tecla para continuar..."
		fi
		email_menu	
			;;
		4) clear;
		read -p "- Deseja restarar as configurações? s = sim / n = não: " -n 1 -r
		if [[ $REPLY =~ ^[Ss]$ ]]; then
		echo " "
		echo "- Restaurando as configurações originais"
		cp -rf /etc/aliases.BCK /etc/aliases
		cp -rf /etc/postfix/main.cf.BCK /etc/postfix/main.cf
		echo "- Reiniciando serviço "
		systemctl restart postfix
		echo "- Restauração executada!"
		fi
		read -p "Pressione uma tecla para continuar..."
		email_menu
			;;
		0) clear;
		pve_menu;
			;;
		*)clear;
		pve_menu;
			;;
      esac
    fi
  done
}

tweaks_menu(){
	clear
	NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}********* Script ($version) para Proxmox Virtual Environment *********${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
	echo " "
	echo -e "${MENU}**${NUMBER} 1)${MENU} Verifica temperatura ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Destranca, desliga e reinicia VM ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 3)${MENU} Configura SWAP ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 4)${MENU} Informações do Host ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 5)${MENU} Instala ou desinstala o script ao carregar o usuário ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 6)${MENU} Instala interface grafica e o Chromium ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 7)${MENU} Configura o watchdog  ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
	echo " "
	echo -e "${MENU}***********************************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
	read -rsn1 opt
	while [ opt != '' ]	
	do
		if [[ $opt = "" ]]; then
			exit;
		else
	case $opt in
		1) clear
		apt install lm-sensors -y
		watch -n 1 sensors
		clear
		tweaks_menu
			;;
		2) clear;
		destranca_desliga
			;;
		3)clear;
		lsblk | grep -qi swap
		swapenabled=$?
	   	if [ $swapenabled -eq 0 ]; then
		read -p "- Gostaria editar ou desativar o swap? s = sim / n = não: " -n 1 -r
		if [[ $REPLY =~ ^[Ss]$ ]]; then
		swapvalue=$(cat /proc/sys/vm/swappiness)
		echo ""
		echo "- Swap esta definido como $swapvalue"
		echo "- Valor recomendado: 1 - O valor mais baixo - menos swap será usado - 0 para usar swap somente quando estiver sem memória"
		echo ""
		echo "- Qual é o novo valor de swap? 0 a 100 "
		read newswapvalue
		echo "- Configurando o swap para $newswapvalue"
		sysctl vm.swappiness=$newswapvalue
		echo "vm.swappiness=$newswapvalue" > /etc/sysctl.d/swappiness.conf
		echo "- Esvaziando o swap - isto pode levar algum tempo"
		swapoff -a
		echo "- Re-habilitando o swap com valor $newswapvalue " 
		swapon -a
		sleep 3	
		fi
		else
		echo " - O sistema não tem swap - Nada a fazer"
		fi
		read -p "Pressione uma tecla para continuar..."
		tweaks_menu
			;;
		4) clear;
		red="\e[31m"
		default="\e[39m"
		white="\e[97m"
		green="\e[32m"
		date=`date`
		load=`cat /proc/loadavg | awk '{print $1}'`
		memory_usage=`free -m | awk '/Mem:/ { total=$2; used=$3 } END { printf("%3.1f%%", used/total*100)}'`
		users=`users | wc -w`
		time=`uptime | grep -ohe 'up .*' | sed 's/,/\ hours/g' | awk '{ printf $2" "$3 }'`
		processes=`ps aux | wc -l`
		ip=`hostname -I | awk '{print $1}'`
		root_usage=`df -h / | awk '/\// {print $(NF-1)}'`
		root_free_space=`df -h / | awk '/\// {print $(NF-4)}'`
		printf "${green}System information as of: ${white}$date \n"
		echo
		printf "${red}System Load${white}:${default}\t%s\t${red}IP Address${white}:${default}\t%s\n" $load $ip
		printf "${red}Memory Usage${white}:${default}\t%s\t${red}System Uptime${white}:${default}\t%s\n" $memory_usage "$time"
		printf "${red}Local Users${white}:${default}\t%s\t${red}Processes${white}:${default}\t%s\n" $users $processes
		echo
		printf "${green}Disk information as of: ${white}$date \n"
		echo
		printf "${red}Usage On /${white}:${default}\t\t%s\t${red}Free On /${white}:${default}\t\t%s\n" $root_usage $root_free_space
		echo
		read -p "Pressione uma tecla para continuar..."
		clear
		tweaks_menu	
			;;
		5) clear;
		instala_script
			;;
		6) clear;
		instala_x			
			;;
		7) clear;
		watch_dog			
			;;					
		0) clear;
		pve_menu;
			;;
		*) clear
		pve_menu;
			;;
      esac
    fi
  done
tweaks_menu
}

destranca_desliga(){
	clear
	NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}********* Script ($version) para Proxmox Virtual Environment *********${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
	echo " "
	echo -e "${MENU}**${NUMBER} 1)${MENU} Destranca VM ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Destranca e desliga a VM ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 3)${MENU} Destranca, desliga e reinicia VM ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
	echo " "
	echo -e "${MENU}***********************************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
	read -rsn1 opt
	while [ opt != '' ]	
	do
		if [[ $opt = "" ]]; then
			exit;
		else
	case $opt in
		1) clear;
		echo "Qual ID da VM? EX: 230"
		read DESTRANCAVM
		rm /var/lock/qemu-server/lock-$DESTRANCAVM.conf
		qm unlock $DESTRANCAVM
		echo "VM destrancada com sucesso!"
		read -p "Pressione uma tecla para continuar..."
		clear	  
		destranca_desliga
			;;
		2) clear;
		echo "Qual ID da VM? EX: 230"
		read DESTRANCADESLIGAVM
		rm /var/lock/qemu-server/lock-$DESTRANCADESLIGAVM.conf
		qm unlock $DESTRANCADESLIGAVM
		sleep 10
		qm stop $DESTRANCADESLIGAVM
		sleep 5
		echo "VM destrancada e desligada com sucesso!"
		read -p "Pressione uma tecla para continuar..."
		clear
		destranca_desliga	
			;;
		3) clear;
		echo "Qual ID da VM? EX: 230"
		read DESTRANCADESLIGAREINICIAVM
		rm /var/lock/qemu-server/lock-$DESTRANCADESLIGAREINICIAVM.conf
		qm unlock $DESTRANCADESLIGAREINICIAVM
		sleep 10
		qm stop $DESTRANCADESLIGAREINICIAVM
		sleep 5
		qm start $DESTRANCADESLIGAREINICIAVM
		sleep 2
		echo "VM destrancada, desligada e reiniciada!"
		read -p "Pressione uma tecla para continuar..."
		clear
		destranca_desliga	
			;;
		0) clear;
		tweaks_menu;
			;;
		*) clear
		tweaks_menu;
			;;			
      esac
    fi
  done
destranca_desliga
}	
		
instala_script(){
	clear
	NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}********* Script ($version) para Proxmox Virtual Environment *********${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
	echo " "
	echo -e "${MENU}**${NUMBER} 1)${MENU} Instala o script ao carregar o usuário ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Desinstala o script ao carregar o usuario ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
	echo " "
	echo -e "${MENU}***********************************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
	read -rsn1 opt
	while [ opt != '' ]	
	do
		if [[ $opt = "" ]]; then
			exit;
		else
	case $opt in
		1) clear;
		echo cd\ > /etc/profile.d/proxmox-ini.sh
		echo cd /TcTI/SCRIPTS >> /etc/profile.d/proxmox-ini.sh
		echo rm proxmox-conf.sh	>> /etc/profile.d/proxmox-ini.sh
		echo wget https://raw.githubusercontent.com/TcTI-BR/PROXMOX-SCRIPTS/main/proxmox-conf.sh >> /etc/profile.d/proxmox-ini.sh
		echo chmod +x proxmox-conf.sh	>> /etc/profile.d/proxmox-ini.sh
		echo ./proxmox-conf.sh	>> /etc/profile.d/proxmox-ini.sh
		chmod +x /etc/profile.d/proxmox-ini.sh
		echo "Script instalado!"		
		read -p "Pressione uma tecla para continuar..."
		clear	  
		instala_script
			;;
		2) clear;
		rm /etc/profile.d/proxmox-ini.sh
		echo "Script removido!"
		read -p "Pressione uma tecla para continuar..."
		clear	  
		instala_script
			;;
		0) clear;
		tweaks_menu;
			;;
		*) clear
		tweaks_menu;
			;;			
      esac
    fi
  done
instala_script
}
						
instala_x(){
	clear
	NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}********* Script ($version) para Proxmox Virtual Environment *********${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
	echo " "
	echo -e "${MENU}**${NUMBER} 1)${MENU} Instala interface grafica e o Chromium ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Inicia a interface grafico ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
	echo " "
	echo -e "${MENU}***********************************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
	read -rsn1 opt
	while [ opt != '' ]	
	do
		if [[ $opt = "" ]]; then
			exit;
		else
	case $opt in
      	1) clear;
		apt-get update
		apt-get upgrade -y
		apt-get install xfce4 chromium lightdm -y
		clear	 
		mkdir /root/Desktop
		touch /root/Desktop/"Chromium Web Browser.desktop"
		echo [Desktop Entry] > /root/Desktop/"Chromium Web Browser.desktop"
		echo Version=1.0 >> /root/Desktop/"Chromium Web Browser.desktop"
		echo Type=Application	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo Name=Chromium Web Browser	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo Comment=Access the Internet	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo Exec=/usr/bin/chromium %U --no-sandbox	  "https://127.0.0.1:8006" >> /root/Desktop/"Chromium Web Browser.desktop"
		echo Icon=chromium	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo Path=	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo Terminal=false	>> /root/Desktop/"Chromium Web Browser.desktop"
		echo StartupNotify=true	>> /root/Desktop/"Chromium Web Browser.desktop"
		chmod +x /root/Desktop/"Chromium Web Browser.desktop"
		apt-get install dbus-x11
		systemctl disable display-manager
		clear	 
		echo "Interface grafica instalada!" 
		read -p "Pressione uma tecla para continuar..."
		clear	  
		instala_x
			;;
		2) clear;
		startx
		clear	  
		instala_x
			;;
		0) clear;
		tweaks_menu;
			;;
		*) clear
		tweaks_menu;
			;;				
		esac
    fi
  done
  instala_x
}
	
watch_dog(){
	clear
	NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}********* Script ($version) para Proxmox Virtual Environment *********${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
	echo " "
	echo -e "${MENU}**${NUMBER} 1)${MENU} Cria o agendamento do watchdog de 10 em 10 minutos ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Remove o agendamento do watchdog ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 3)${MENU} Lista as VMs que estão monitoradas pelo watchdog ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 4)${MENU} Adiciona uma VM ao monitoramento do watchdog ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 5)${MENU} Remove uma VM do monitoramento do watchdog ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
	echo " "
	echo -e "${MENU}***********************************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
	read -rsn1 opt
	while [ opt != '' ]	
	do
		if [[ $opt = "" ]]; then
			 exit;
		else
	case $opt in
		1) clear;
        sed -i '/WATCHDOG/d' /var/spool/cron/crontabs/root
        echo "*/10 * * * * /TcTI/SCRIPTS/WATCHDOG/*.sh" >> /var/spool/cron/crontabs/root
		read -p "Pressione uma tecla para continuar..."
		clear	  
		watch_dog
			;;
		2) clear;
        sed -i '/WATCHDOG/d' /var/spool/cron/crontabs/root
		read -p "Pressione uma tecla para continuar..."
		clear
		watch_dog
			;;
		3) clear;
		ls -t /TcTI/SCRIPTS/WATCHDOG/
		read -p "Pressione uma tecla para continuar..."
		clear
		watch_dog
			;;
		4) clear;
		echo "Qual ID da VM? EX: 230"
		read WATCHDOGVMID
		echo "Qual IP da VM? EX: 192.168.0.230"
		read WATCHDOGVMIP
		mkdir /TcTI/SCRIPTS/WATCHDOG/
		touch /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo '#!/bin/bash' > /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'ping -c4 $WATCHDOGVMIP > /dev/null' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'if [ $? != 1 ]' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'then' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'echo "Host encontrado"' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'qm status $WATCHDOGVMID' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'else' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'echo "host não encontaado - reiniciando...."' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'qm stop $WATCHDOGVMID' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'qm start $WATCHDOGVMID' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'qm status $WATCHDOGVMID' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		echo 'fi' >> /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMID.sh
		clear	 
		echo "Monitoramento da VM ativada" 
		read -p "Pressione uma tecla para continuar..."
		clear	  
		watch_dog
			;;	
		5) clear;
		echo "Qual ID da VM? EX: 230"
		read WATCHDOGVMIDDEL
		rm /TcTI/SCRIPTS/WATCHDOG/$WATCHDOGVMIDDEL.sh
		read -p "Pressione uma tecla para continuar..."
		clear
		watch_dog
			;;			
		0) clear;
		tweaks_menu;
			;;				
		*)clear;
		tweaks_menu;
      ;;
      esac
    fi
  done
watch_dog
}

lan_menu(){
	clear
	NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}********* Script ($version) para Proxmox Virtual Environment *********${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
	echo " "
	echo -e "${MENU}**${NUMBER} 1)${MENU} Configura rede${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Configura DNS ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 3)${MENU} Configura hosts ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
	echo " "
	echo -e "${MENU}***********************************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
	read -rsn1 opt
	while [ opt != '' ]	
	do
		if [[ $opt = "" ]]; then
			 exit;
		else
	case $opt in
		1) clear
		nano /etc/network/interfaces
		read -p "Pressione uma tecla para continuar..."
		clear
		lan_menu
			;;
		2) clear;
		nano /etc/resolv.conf
		read -p "Pressione uma tecla para continuar..."
		clear	  
		lan_menu
			;;
		3) clear;
		nano /etc/hosts
		read -p "Pressione uma tecla para continuar..."
		clear
		lan_menu	
			;;
		0) clear;
		pve_menu;
			;;
		*)clear;
		pve_menu;
			;;
      esac
    fi
  done
}

com_menu(){
	clear
	NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}********* Script ($version) para Proxmox Virtual Environment *********${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
	echo " "
	echo -e "${MENU}**${NUMBER} 1)${MENU} Comandos linux ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 2)${MENU} Comandos PVE ${NORMAL}"
	echo -e "${MENU}**${NUMBER} 3)${MENU} Caminho e informações gerais ${NORMAL}"
	echo " "
	echo -e "${MENU}***********************************************************************${NORMAL}"
	echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
	read -rsn1 opt
	while [ opt != '' ]	
	do
		if [[ $opt = "" ]]; then
			 exit;
		else
	case $opt in
		1) clear
		echo "ip address = Ver os IPs setados nas interfaces"
		echo "df -h = Lista o tamanho dos pontos de montagem"
		echo "rsync --progress /CAMINHO_DE_ORIGEM.EXTENSÃO   /CAMINHO_DE_DESTINO/ = Comando para copiar com progressão"
		echo ""
		echo ""
		read -p "Pressione uma tecla para continuar..."
		clear
		com_menu
			;;
		2) clear
		echo "qm stop|shutdown|start|unlock VMID = comando para desligar|desligar via sistema|ligar|desbloquear VMs"
		echo "qm  VMID = Destranca VM bloqueada"
		echo ""
		echo ""
		read -p "Pressione uma tecla para continuar..."
		clear
		com_menu
			;;
		3) clear
		echo "/etc/pve/nodes/nome-do-node/qemu-server/ = Caminho onde ficam os VMIDS"
		echo "/var/lib/vz/template/iso = Caminho os ficam os arquivos ISO"
		echo ""
		echo ""
		read -p "Pressione uma tecla para continuar..."
		clear
		com_menu
			;;
		0) clear;
		pve_menu;
			;;
		*)clear;
		pve_menu;
      ;;
      esac
    fi
  done
}

pbs_menu(){
    clear
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}************ Script ($version) para Proxmox Backup Server ************${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
    echo " "
    echo -e "${MENU}**${NUMBER} 1)${MENU} Atualização, instalação e upgrade do sistema ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Ferramentas de disco ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Configuração do email ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Configurações e ajustes ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 5)${MENU} Configurações de rede ${NORMAL}"	
    echo -e "${MENU}**${NUMBER} 0)${MENU} Sair ${NORMAL}"
    echo " "
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
    read -rsn1 opt
	while [ opt != '' ]
  do
    if [[ $opt = "" ]]; then
      exit;
    else
      case $opt in
   	
	   	 1) clear;
		update_pbs_menu
      ;;
	     2) clear;
		disco_pbs_menu
	  ;;
	     3) clear;
		email_pbs_menu
      ;;
	     4) clear;
		tweaks_pbs_menu
	  ;;
	     5) clear;
		lan_pbs_menu
      ;;	  
      0)
	  clear
      main_menu
      ;;
      esac
    fi
  done
  pve_menu
}

update_pbs_menu(){

			NORMAL=`echo "\033[m"`
			MENU=`echo "\033[36m"` #Blue
			NUMBER=`echo "\033[33m"` #yellow
			FGRED=`echo "\033[41m"`
			RED_TEXT=`echo "\033[31m"`
			ENTER_LINE=`echo "\033[33m"`
			echo -e "${MENU}************ Script ($version) para Proxmox Backup Server ************${NORMAL}"
			echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
			echo " "
			echo -e "${MENU}**${NUMBER} 1)${MENU} Upgrade de versões ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 2)${MENU} Atualização do sistema e instalação de aplicativos mais utilizados ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
			echo " "
			echo -e "${MENU}***********************************************************************${NORMAL}"
			echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
			read -rsn1 opt
			while [ opt != '' ]
		  do
			if [[ $opt = "" ]]; then
			  exit;
			else
			  case $opt in
				1) clear;
				upgrade_pbs_menu
			;;
				2) clear;
				mv /etc/apt/sources.list.d/pbs-enterprise.list /root/
				echo "deb http://download.proxmox.com/debian/pbs $distribution pbs-no-subscription" >> /etc/apt/sources.list
				apt update
				apt upgrade -y
				apt install libsasl2-modules -y
				apt install lm-sensors
				apt install ifupdown2 -y
				apt install ethtool -y
				apt install hdparm -y
				
				read -p "Pressione uma tecla para continuar..."
				clear 
			  update_pbs_menu;	
				;;
      0) clear;
      pbs_menu;
      ;;

      x)exit;
      ;;

      \n)exit;
      ;;

      *)clear;
      pbs_menu;
      ;;
      esac
    fi
  done
}


upgrade_pbs_menu(){

			NORMAL=`echo "\033[m"`
			MENU=`echo "\033[36m"` #Blue
			NUMBER=`echo "\033[33m"` #yellow
			FGRED=`echo "\033[41m"`
			RED_TEXT=`echo "\033[31m"`
			ENTER_LINE=`echo "\033[33m"`
			echo -e "${MENU}************ Script ($version) para Proxmox Backup Server ************${NORMAL}"
			echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
			echo " "
			echo -e "${MENU}**${NUMBER} 1)${MENU} Upgrade da versão 1x para a versão 2x ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
			echo " "
			echo -e "${MENU}***********************************************************************${NORMAL}"
			echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
			read -rsn1 opt
			while [ opt != '' ]
		  do
			if [[ $opt = "" ]]; then
			  exit;
			else
			  case $opt in
				1) clear;
				mv /etc/apt/sources.list.d/pbs-enterprise.list /root/
				sed -i 's/buster\/updates/bullseye-security/g;s/buster/bullseye/g' /etc/apt/sources.list
				echo "deb http://download.proxmox.com/debian/pbs bullseye pbs-no-subscription" >> /etc/apt/sources.list
				apt update
				systemctl stop proxmox-backup-proxy.service proxmox-backup.servic
				apt update
				apt dist-upgrade -y
				apt upgrade -y 
				systemctl start proxmox-backup-proxy.service proxmox-backup.service
				clear 
			  update_pbs_menu;
	  ;;
      0) clear;
      update_pbs_menu;
      ;;

      x)exit;
      ;;

      \n)exit;
      ;;

      *)clear;
      update_pbs_menu;
      ;;
      esac
    fi
  done
}


disco_pbs_menu(){
			clear
	NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}************ Script ($version) para Proxmox Backup Server ************${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
			echo " "
			echo -e "${MENU}**${NUMBER} 1)${MENU} Configura discos ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 2)${MENU} Teste de velocidade dos discos ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 3)${MENU} Verifica setores defeituosos em discos ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 4)${MENU} Verifica o SMART do disco ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
			echo " "
	echo -e "${MENU}***********************************************************************${NORMAL}"
			echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
			read -rsn1 opt
			while [ opt != '' ]	
		  do
			if [[ $opt = "" ]]; then
			  exit;
			else
			case $opt in
		    1) clear
		lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
		echo "Qual o disco que vai ser preparado? EX: sda / nvme0n1"
		read FORMATADISCO
		echo "Qual o nome do Datastore? EX: BACKUP_REDE / STORE_01 / BACKUP_01"
		read STORAGE
		echo "O disco será para backup ou VM?: Digite exatamente "images" para VM ou "backup" para BACKUP sem as aspas"
		echo -e "g\nn\np\n1\n\n\nw" | fdisk /dev/$FORMATADISCO
		mkfs.ext4 -L $STORAGE /dev/$FORMATADISCO
		mkdir -p /mnt/$STORAGE
		sed -i /"$STORAGE"/d /etc/fstab
		echo "" >> /etc/fstab
		echo "LABEL=$STORAGE /mnt/$STORAGE ext4 defaults,auto,nofail 0 0" >> /etc/fstab
		mount -a
		proxmox-backup-manager datastore create $STORAGE /mnt/$STORAGE
		read -p "Pressione uma tecla para continuar..."
		clear
			  disco_pbs_menu
			;;
			2) clear
		lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
		echo "Qual disco será testado o desempenho? EX: sda / nvme0n1"
		read TESTEDISCO
		clear
		hdparm -tT /dev/$TESTEDISCO
		read -p "Pressione uma tecla para continuar..."
		clear
			disco_pbs_menu
			;;
			3) clear
		lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
		echo "Qual disco será testado os setores? EX: sda / nvme0n1"
		read TESTESETORES
		clear
		badblocks -sv -c 10240 /dev/$TESTESETORES
		read -p "Pressione uma tecla para continuar..."
			disco_pbs_menu
			;;
			4) clear
		lsblk -o NAME,SIZE,LABEL,MOUNTPOINT,FSTYPE
		echo "Qual disco será verificado o status do SMART? EX: sda / nvme0n1"
		read TESTESMART
		clear
		smartctl -a /dev/$TESTESMART
		read -p "Pressione uma tecla para continuar..."
			disco_pbs_menu
			;;
      0) clear;
      pbs_menu;
      ;;

      x)exit;
      ;;

      \n)exit;
      ;;

      *)clear;
      pbs_menu;
      ;;
      esac
    fi
  done
}

email_pbs_menu(){
			clear
	NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}************ Script ($version) para Proxmox Backup Server ************${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
			echo " "
			echo -e "${MENU}**${NUMBER} 1)${MENU} Configura o serviço de e-mail ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 2)${MENU} Testa as configurações ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 3)${MENU} Verifica os logs para tentar executar a correção ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 4)${MENU} Restaura a configuração original  ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
			echo " "
	echo -e "${MENU}***********************************************************************${NORMAL}"
			echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
			read -rsn1 opt
			while [ opt != '' ]	
		  do
			if [[ $opt = "" ]]; then
			  exit;
			else
			case $opt in
		    1) clear
	echo "- Endereço de e-mail do destinatário do administrador do sistema (conta@dominioexemplo.com) (root alias): "
					read 'varrootmail'
					echo "- Qual é o endereço do host do servidor de e-mail? (smtp.gmail.com): "
					read 'varmailserver'
					echo "- Qual é a porta do servidor de e-mail? (Normalmente 587 (sem tls)): "
					read 'varmailport'
					read -p  "- O servidor de e-mail requer TLS? s = sim / n = não: " -n 1 -r 
					if [[ $REPLY =~ ^[Ss]$ ]]; then
					vartls=yes
					else
					vartls=no
					fi
					echo " "
					echo "- O nome do usuário de autenticação? (EX: email@dominioexemplo.com.br): "
					read 'varmailusername'
					echo "- Qual é a senha de autenticação?: "
					read 'varmailpassword'
					echo "- O endereço de e-mail que envia é o mesmo que o usuário de autenticação?"
					read -p " s para usar $varmailusername / Enter para não: " -n 1 -r 
					if [[ $REPLY =~ ^[Ss]$ ]]; then
					varsenderaddress=$varmailusername
					else
					echo " "
					echo "- Qual é o endereço de e-mail do remetente?: "
					read 'varsenderaddress'
					fi
					echo " "
				echo "- Executando...!"
				echo " "
				echo "- Definindo aliases"
				if grep "root:" /etc/aliases
					then
					echo "- A entrada de alias foi encontrada: editando para $varrootmail"
					sed -i "s/^root:.*$/root: $varrootmail/" /etc/aliases
				else
					echo "- Nenhum alias do root encontrado: Adicionando"
					echo "root: $varrootmail" >> /etc/aliases
				fi
				
				#Configurando o arquivo canônico para o remetente - :
				echo "root $varsenderaddress" > /etc/postfix/canonical
				chmod 600 /etc/postfix/canonical
				
				# Preparando para o hash da senha
				echo [$varmailserver]:$varmailport $varmailusername:$varmailpassword > /etc/postfix/sasl_passwd
				chmod 600 /etc/postfix/sasl_passwd 
				
				# Adicionando o servidor de email no arquivo main.cf
				sed -i "/#/!s/\(relayhost[[:space:]]*=[[:space:]]*\)\(.*\)/\1"[$varmailserver]:"$varmailport""/"  /etc/postfix/main.cf
				
				# Verificando as configurações de TLS
				echo "- Definindo as configurações de TLS corretas: $vartls"
				postconf smtp_use_tls=$vartls
				
				# Verificando a entrada de hash da senha
					if grep "smtp_sasl_password_maps" /etc/postfix/main.cf
					then
					echo "- Hash da senha já configurado"
				else
					echo "- Adicionando entrada de hash da senha"
					postconf smtp_sasl_password_maps=hash:/etc/postfix/sasl_passwd
				fi
				# Verificando o certificado
				if grep "smtp_tls_CAfile" /etc/postfix/main.cf
					then
					echo "- O arquivo TLS CA parece configurado"
					else
					postconf smtp_tls_CAfile=/etc/ssl/certs/ca-certificates.crt
				fi
				# Adicionando opções de segurança sasl
				# eliminates default security options which are imcompatible with gmail
				if grep "smtp_sasl_security_options" /etc/postfix/main.cf
					then
					echo "- Configuração de smtp_sasl_security_options do Google"
					else
					postconf smtp_sasl_security_options=noanonymous
				fi
				if grep "smtp_sasl_auth_enable" /etc/postfix/main.cf
					then
					echo "- Autenticação já habilitada"
					else
					postconf smtp_sasl_auth_enable=yes
				fi 
				if grep "sender_canonical_maps" /etc/postfix/main.cf
					then
					echo "- Entrada canônica já existente"
					else
					postconf sender_canonical_maps=hash:/etc/postfix/canonical
				fi 
				
				echo "- Criptografia de senha e entrada canônica"
				postmap /etc/postfix/sasl_passwd
				postmap /etc/postfix/canonical
				apt update
				apt install libsasl2-modules -y
				echo "- Reiniciando o postfix e habilitando a inicialização automática"
				systemctl restart postfix && systemctl enable postfix
				echo "- Limpando o arquivo usado para gerar hash de senha"
				rm -rf "/etc/postfix/sasl_passwd"
				echo "- Removido arquivos"
				
			  email_pbs_menu
			;;
	2)	clear;
		echo "- Qual é o endereço de e-mail do destinatário? :"
		read vardestaddress
		echo "- Um e-mail será enviado para: $vardestaddress"
		echo “Esse e-mail confirma que a configuração do seu PBS esta ok!” | mail -s "Teste de e-mail - $hostname - $date" $vardestaddress
		echo "- O e-mail deveria ter sido enviado - Se nenhum for recebido, verifique se há erros no menu 3"
		read -p "Pressione uma tecla para continuar..."
	  
	  email_pbs_menu
			;;
	3)	clear;
		echo "- Verificando se a erros nos logs"
			if grep "SMTPUTF8 is required" "/var/log/mail.log"
			then
			echo "- Encontrado erros no log - SMTPUTF8 é requerido"
					if grep "smtputf8_enable = no" /etc/postfix/main.cf
						then
						echo "- Executado correção!"
					else
						echo " "
						echo "- Configuração "smtputf8_enable=no" para correta "SMTPUTF8 was required but not supported""
						postconf smtputf8_enable=no
						postfix reload
				 	 fi 

			elif grep "Network is unreachable" "/var/log/mail.log"; then
				read -p "- Você está no IPv4 e seu host pode resolver e acessar endereços públicos? s = sim / n = não: " -n 1 -r
				if [[ $REPLY =~ ^[Ss]$ ]]; then
					if grep "inet_protocols = ipv4" /etc/postfix/main.cf
					then
						echo "- Executado correção!"
					else
						echo " "
						echo "- Configuração "inet_protocols = ipv4 " para o correto ""Network is unreachable" caused by ipv6 resolution""
						postconf inet_protocols=ipv4
						postfix reload
					fi
				fi
			elif grep "smtp_tls_security_level = encrypt" "/var/log/mail.log"; then		
				echo "- Encontrado erros no log - smtp_tls_security_level = encrypt is required"
				if grep "smtp_tls_security_level = encrypt" /etc/postfix/main.cf; then
					echo "- Executado correção!"
				else
					echo " "
					echo "- Setting "smtp_tls_security_level = encrypt" to correct"
					postconf inet_protocols=ipv4
					postfix reload
				fi
			elif grep "smtp_tls_wrappermode = yes" "/var/log/mail.log"; then		
				echo "- Encontrado erros no log - smtp_tls_wrappermode = yes is required"
				if grep "smtp_tls_wrappermode = yes" /etc/postfix/main.cf; then
					echo "- Executado correção!"
				else
					echo " "
					echo "- Configuração "smtp_tls_wrappermode = yes" para o correto"
					postconf smtp_tls_wrappermode=yes
					postfix reload
				fi
		    else
			echo "- Não foram encontrados erros!"
			read -p "Pressione uma tecla para continuar..."
			fi
	  email_pbs_menu	
			;;
	4)clear;
		read -p "- Deseja restarar as configurações? s = sim / n = não: " -n 1 -r
			if [[ $REPLY =~ ^[Ss]$ ]]; then
					echo " "
					echo "- Restaurando as configurações originais"
				        cp -rf /etc/aliases.BCK /etc/aliases
					cp -rf /etc/postfix/main.cf.BCK /etc/postfix/main.cf
					echo "- Reiniciando serviço "
					systemctl restart postfix
					echo "- Restauração executada!"
			fi
			read -p "Pressione uma tecla para continuar..."
	  email_pbs_menu
			;;
      0) clear;
      pbs_menu;
      ;;

      x)exit;
      ;;

      \n)exit;
      ;;

      *)clear;
      pbs_menu;
      ;;
      esac
    fi
  done
}


tweaks_pbs_menu(){
			clear
	NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}************ Script ($version) para Proxmox Backup Server ************${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
			echo " "
			echo -e "${MENU}**${NUMBER} 1)${MENU} Verifica temperatura ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 2)${MENU} Configura SWAP ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 3)${MENU} Informações do Host ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 4)${MENU} Instala o script ao carregar o usuario ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 5)${MENU} Remove o script ao carregar o usuario ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
			echo " "
	echo -e "${MENU}***********************************************************************${NORMAL}"
			echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
			read -rsn1 opt
			while [ opt != '' ]	
		  do
			if [[ $opt = "" ]]; then
			  exit;
			else
			case $opt in
		    1) clear
		apt install lm-sensors -y
		watch -n 1 sensors
				clear
		tweaks_pbs_menu
			;;
	2)clear;
		lsblk | grep -qi swap
		swapenabled=$?
	   	if [ $swapenabled -eq 0 ]; then
		read -p "- Gostaria editar ou desativar o swap? s = sim / n = não: " -n 1 -r
			if [[ $REPLY =~ ^[Ss]$ ]]; then
				swapvalue=$(cat /proc/sys/vm/swappiness)
				echo ""
				echo "- Swap esta definido como $swapvalue"
				echo "- Valor recomendado: 1 - O valor mais baixo - menos swap será usado - 0 para usar swap somente quando estiver sem memória"
				echo ""
				echo "- Qual é o novo valor de swap? 0 a 100 "
				read newswapvalue
				echo "- Configurando o swap para $newswapvalue"
				sysctl vm.swappiness=$newswapvalue
				echo "vm.swappiness=$newswapvalue" > /etc/sysctl.d/swappiness.conf
				echo "- Esvaziando o swap - isto pode levar algum tempo"
				swapoff -a
				echo "- Re-habilitando o swap com valor $newswapvalue " 
				swapon -a
				sleep 3	
			fi
		else
			echo " - O sistema não tem swap - Nada a fazer"
		fi
			read -p "Pressione uma tecla para continuar..."
	  tweaks_pbs_menu
			;;
	3)	clear;
		red="\e[31m"
default="\e[39m"
white="\e[97m"
green="\e[32m"
 
date=`date`
load=`cat /proc/loadavg | awk '{print $1}'`
memory_usage=`free -m | awk '/Mem:/ { total=$2; used=$3 } END { printf("%3.1f%%", used/total*100)}'`

users=`users | wc -w`
time=`uptime | grep -ohe 'up .*' | sed 's/,/\ hours/g' | awk '{ printf $2" "$3 }'`
processes=`ps aux | wc -l`
ip=`hostname -I | awk '{print $1}'`

root_usage=`df -h / | awk '/\// {print $(NF-1)}'`
root_free_space=`df -h / | awk '/\// {print $(NF-4)}'`
 
printf "${green}System information as of: ${white}$date \n"
echo
printf "${red}System Load${white}:${default}\t%s\t${red}IP Address${white}:${default}\t%s\n" $load $ip
printf "${red}Memory Usage${white}:${default}\t%s\t${red}System Uptime${white}:${default}\t%s\n" $memory_usage "$time"
printf "${red}Local Users${white}:${default}\t%s\t${red}Processes${white}:${default}\t%s\n" $users $processes
echo
printf "${green}Disk information as of: ${white}$date \n"
echo
printf "${red}Usage On /${white}:${default}\t\t%s\t${red}Free On /${white}:${default}\t\t%s\n" $root_usage $root_free_space
echo
		read -p "Pressione uma tecla para continuar..."
		clear
	  tweaks_pbs_menu	
			;;
	4)	clear;
		echo cd\ > /etc/profile.d/proxmox-ini.sh
		echo cd /TcTI/SCRIPTS >> /etc/profile.d/proxmox-ini.sh
		echo rm proxmox-conf.sh	>> /etc/profile.d/proxmox-ini.sh
		echo wget https://raw.githubusercontent.com/TcTI-BR/PROXMOX-SCRIPTS/main/proxmox-conf.sh >> /etc/profile.d/proxmox-ini.sh
		echo chmod +x proxmox-conf.sh	>> /etc/profile.d/proxmox-ini.sh
		echo ./proxmox-conf.sh	>> /etc/profile.d/proxmox-ini.sh
		chmod +x /etc/profile.d/proxmox-ini.sh
		echo "Script instalado!"		
		read -p "Pressione uma tecla para continuar..."
		clear	  
	  tweaks_pbs_menu
			;;
				7)	clear;
		rm /etc/profile.d/proxmox-ini.sh
		echo "Script removido!"
		read -p "Pressione uma tecla para continuar..."
		clear	  
	  tweaks_pbs_menu
			;;
	  0) clear;
      pbs_menu;
      ;;

      x)exit;
      ;;

      \n)exit;
      ;;

      *)clear;
      pbs_menu;
      ;;
      esac
    fi
  done
}



lan_pbs_menu(){
			clear
	NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}************ Script ($version) para Proxmox Backup Server ************${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
			echo " "
			echo -e "${MENU}**${NUMBER} 1)${MENU} Configura rede ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 2)${MENU} Configura DNS ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 3)${MENU} Configura hosts ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar ${NORMAL}"
			echo " "
	echo -e "${MENU}***********************************************************************${NORMAL}"
			echo -e "${ENTER_LINE}Digite um numero dentre as opções acima ou pressione ${RED_TEXT}ENTER ${ENTER_LINE}para sair.${NORMAL} "
			read -rsn1 opt
			while [ opt != '' ]	
		  do
			if [[ $opt = "" ]]; then
			  exit;
			else
			case $opt in
    1) clear
		nano /etc/network/interfaces
		read -p "Pressione uma tecla para continuar..."
		clear
		lan_pbs_menu
			;;
	2)	clear;
		nano /etc/resolv.conf
		read -p "Pressione uma tecla para continuar..."
		clear	  
	  lan_pbs_menu
			;;
	3)	clear;
		nano /etc/hosts
		read -p "Pressione uma tecla para continuar..."
		clear
	  lan_pbs_menu	
			;;
	  0) clear;
      pbs_menu;
      ;;

      x)exit;
      ;;

      \n)exit;
      ;;

      *)clear;
      pbs_menu;
      ;;
      esac
    fi
  done
}
main_menu
