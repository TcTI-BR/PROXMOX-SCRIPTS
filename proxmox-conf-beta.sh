#!/bin/bash

# toda a base do script foi inspirado no  https://github.com/Tontonjo/proxmox_toolbox.git
 

version=1.1
# changelog


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
backupdir="/root/" 
backup_content="/etc/ssh/sshd_config /root/.ssh/ /etc/fail2ban/ /etc/systemd/system/*.mount /etc/network/interfaces /etc/sysctl.conf /etc/resolv.conf /etc/hosts /etc/hostname /etc/cron* /etc/aliases /etc/snmp/ /etc/smartd.conf /usr/share/snmp/snmpd.conf /etc/postfix/ /etc/pve/ /etc/lvm/ /etc/modprobe.d/ /var/lib/pve-firewall/ /var/lib/pve-cluster/  /etc/vzdump.conf /etc/ksmtuned.conf /etc/proxmox-backup/"
# ---------------FIM DAS VARIAVEIS DE SISTEMA-----------------

main_menu(){
    clear
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}****************** Script (V01.R01) para Proxmox **********************${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
    echo " "
    echo -e "${MENU}**${NUMBER} 1)${MENU} Atualização, instalação e upgrade do sistema ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Ferramentas de disco ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Tarefas de backup ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Configuração do email ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 5)${MENU} Configurações e ajustes ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 6)${MENU} Configurações de rede ${NORMAL}"	
    echo -e "${MENU}**${NUMBER} 7)${MENU} Comandos e informações úteis  ${NORMAL}"	
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
      exit
      ;;
      esac
    fi
  done
  main_menu
}

update_menu(){

			NORMAL=`echo "\033[m"`
			MENU=`echo "\033[36m"` #Blue
			NUMBER=`echo "\033[33m"` #yellow
			FGRED=`echo "\033[41m"`
			RED_TEXT=`echo "\033[31m"`
			ENTER_LINE=`echo "\033[33m"`
			echo -e "${MENU}****************** Script (V01.R01) para Proxmox **********************${NORMAL}"
			echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
			echo " "
			echo -e "${MENU}**${NUMBER} 1)${MENU} Upgrade da versão 5x para a versão 6x ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 2)${MENU} Upgrade da versão 6x para a versão 7x ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 3)${MENU} Atualização do sistema e instalação de aplicativos mais utilizados ${NORMAL}"
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
				read -p "Pressione uma tecla para continuar..."
				clear
			 
			  update_menu;
				;;

			   2) clear;
			    mv /etc/apt/sources.list.d/pve-enterprise.list /root/
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
				read -p "Pressione uma tecla para continuar..."
				clear
	  
			  update_menu;	
				;;
				3) clear;
				mv /etc/apt/sources.list.d/pve-enterprise.list /root/
				echo "deb http://download.proxmox.com/debian/pve $distribution pve-no-subscription" >> /etc/apt/sources.list
				apt update
				apt upgrade -y
				apt install libsasl2-modules -y
				apt install lm-sensors
				apt install ifupdown2 -y
				apt install ntfs-3g -y
				apt install ethtool -y
				
				read -p "Pressione uma tecla para continuar..."
				clear 
			  update_menu;	
				;;
      0) clear;
      main_menu;
      ;;

      x)exit;
      ;;

      \n)exit;
      ;;

      *)clear;
      main_menu;
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
    echo -e "${MENU}****************** Script (V01.R01) para Proxmox **********************${NORMAL}"
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
      0) clear;
      main_menu;
      ;;

      x)exit;
      ;;

      \n)exit;
      ;;

      *)clear;
      main_menu;
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
    echo -e "${MENU}****************** Script (V01.R01) para Proxmox **********************${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
			echo " "
			echo -e "${MENU}**${NUMBER} 1)${MENU} Configura o NFS para BACKUP rede do PROXMOX (SERVIDOR DE BACKUP USANDO UM PVE) ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 2)${MENU} Instala o PBS lado a lado com o PVE ${NORMAL}"
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
	2)	clear	
		echo deb http://download.proxmox.com/debian/pbs $distribution pbs-no-subscription >> /etc/apt/sources.list
		apt update
		apt update
		apt-get install proxmox-backup-server
		echo "PBS instalado!"
		read -p "Pressione uma tecla para continuar..."
		clear
		bkp_menu
			;;					
      0) clear;
      main_menu;
      ;;

      x)exit;
      ;;

      \n)exit;
      ;;

      *)clear;
      main_menu;
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
    echo -e "${MENU}****************** Script (V01.R01) para Proxmox **********************${NORMAL}"
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
					read -p  "- O servidor de e-mail requer TLS? y = sim / n = não: " -n 1 -r 
					if [[ $REPLY =~ ^[Yy]$ ]]; then
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
					read -p " y para usar $varmailusername / Enter para não: " -n 1 -r 
					if [[ $REPLY =~ ^[Yy]$ ]]; then
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
	2)	clear;
		echo "- Qual é o endereço de e-mail do destinatário? :"
		read vardestaddress
		echo "- Um e-mail será enviado para: $vardestaddress"
		echo “Esse e-mail confirma que a configuração do seu PVE esta ok!” | mail -s "Teste de e-mail - $hostname - $date" $vardestaddress
		echo "- O e-mail deveria ter sido enviado - Se nenhum for recebido, verifique se há erros no menu 3"
		read -p "Pressione uma tecla para continuar..."
	  
	  email_menu
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
				read -p "- Você está no IPv4 e seu host pode resolver e acessar endereços públicos? y = sim / n = não: " -n 1 -r
				if [[ $REPLY =~ ^[Yy]$ ]]; then
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
	4)clear;
		read -p "- Deseja restarar as configurações? y = sim / n = não: " -n 1 -r
			if [[ $REPLY =~ ^[Yy]$ ]]; then
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
      main_menu;
      ;;

      x)exit;
      ;;

      \n)exit;
      ;;

      *)clear;
      main_menu;
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
    echo -e "${MENU}****************** Script (V01.R01) para Proxmox **********************${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
			echo " "
			echo -e "${MENU}**${NUMBER} 1)${MENU} Verifica temperatura ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 2)${MENU} Destranca VM ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 3)${MENU} Destranca e desliga a VM ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 4)${MENU} Configura SWAP ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 5)${MENU} Informações do Host ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 6)${MENU} Instala o script ao carregar o usuario ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 7)${MENU} Remove o script ao carregar o usuario ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 8)${MENU} Instala interface grafica e o Chromium ${NORMAL}"
			echo -e "${MENU}**${NUMBER} 9)${MENU} Inicia a interface grafico ${NORMAL}"
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
	2)	clear;
		echo "Qual ID da VM? EX: 230"
		read DESTRANCAVM
		rm /var/lock/qemu-server/lock-$DESTRANCAVM.conf
		qm unlock $DESTRANCAVM
		echo "VM destrancada com sucesso!"
		read -p "Pressione uma tecla para continuar..."
		clear	  
	  tweaks_menu
			;;
	3)	clear;
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
	  tweaks_menu	
			;;
	4)clear;
		lsblk | grep -qi swap
		swapenabled=$?
	   	if [ $swapenabled -eq 0 ]; then
		read -p "- Gostaria editar ou desativar o swap? y = sim / n = não: " -n 1 -r
			if [[ $REPLY =~ ^[Yy]$ ]]; then
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
				5)	clear;
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
				6)	clear;
		echo cd\ > /etc/profile.d/proxmox-ini-beta.sh
		echo cd /TcTI/SCRIPTS >> /etc/profile.d/proxmox-ini-beta.sh
		echo rm proxmox-conf-beta.sh	>> /etc/profile.d/proxmox-ini-beta.sh
		echo wget https://raw.githubusercontent.com/TcTI-BR/PROXMOX-SCRIPTS/main/proxmox-conf-beta.sh >> /etc/profile.d/proxmox-ini-beta.sh
		echo chmod +x proxmox-conf-beta.sh	>> /etc/profile.d/proxmox-ini-beta.sh
		echo ./proxmox-conf-beta.sh	>> /etc/profile.d/proxmox-ini-beta.sh
		chmod +x /etc/profile.d/proxmox-ini-beta.sh
		echo "Script instalado!"		
		read -p "Pressione uma tecla para continuar..."
		clear	  
	  tweaks_menu
			;;
				7)	clear;
		rm /etc/profile.d/proxmox-ini-beta.sh
		echo "Script removido!"
		read -p "Pressione uma tecla para continuar..."
		clear	  
	  tweaks_menu
			;;
      		8)	clear;
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
	  tweaks_menu
			;;
			9)	clear;
		startx
		clear	  
	  main_menu
			;;
	  0) clear;
      main_menu;
      ;;

      x)exit;
      ;;

      \n)exit;
      ;;

      *)clear;
      main_menu;
      ;;
      esac
    fi
  done
}



lan_menu(){
			clear
	NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Azul
    NUMBER=`echo "\033[33m"` #Amarelo
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}****************** Script (V01.R01) para Proxmox **********************${NORMAL}"
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
	2)	clear;
		nano /etc/resolv.conf
		read -p "Pressione uma tecla para continuar..."
		clear	  
	  lan_menu
			;;
	3)	clear;
		nano /etc/hosts
		read -p "Pressione uma tecla para continuar..."
		clear
	  lan_menu	
			;;
	  0) clear;
      main_menu;
      ;;

      x)exit;
      ;;

      \n)exit;
      ;;

      *)clear;
      main_menu;
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
    echo -e "${MENU}****************** Script (V01.R01) para Proxmox **********************${NORMAL}"
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
      main_menu;
      ;;

      x)exit;
      ;;

      \n)exit;
      ;;

      *)clear;
      main_menu;
      ;;
      esac
    fi
  done
}

main_menu
