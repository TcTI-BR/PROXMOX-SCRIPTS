#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh" # Adjusted path

clear
echo -e "${MENU}=== PBS: Configuração do Serviço de E-mail (Postfix) ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

# Backup existing Postfix main.cf and aliases if they haven't been backed up by this script before
# Using a PBS specific backup name to differentiate from PVE if on same host (unlikely for Postfix files but good practice)
if [ ! -f /etc/postfix/main.cf.BCK_pbs_scripts ] && [ -f /etc/postfix/main.cf ]; then
    cp -f /etc/postfix/main.cf /etc/postfix/main.cf.BCK_pbs_scripts
    echo "Backup de /etc/postfix/main.cf criado em /etc/postfix/main.cf.BCK_pbs_scripts"
fi
if [ ! -f /etc/aliases.BCK_pbs_scripts ] && [ -f /etc/aliases ]; then
    cp -f /etc/aliases /etc/aliases.BCK_pbs_scripts
    echo "Backup de /etc/aliases criado em /etc/aliases.BCK_pbs_scripts"
fi

echo -e "${ENTER_LINE}- Endereço de e-mail do destinatário do administrador (root alias) (conta@dominioexemplo.com):${NORMAL}"
read -r varrootmail
echo -e "${ENTER_LINE}- Qual é o endereço do host do servidor de e-mail? (ex: smtp.gmail.com):${NORMAL}"
read -r varmailserver
echo -e "${ENTER_LINE}- Qual é a porta do servidor de e-mail? (Normalmente 587 para TLS, 465 para SSL, 25 sem):${NORMAL}"
read -r varmailport

vartls="no" # Default to no TLS
read -r -p "- O servidor de e-mail requer TLS? (s/N): " REPLY_TLS
if [[ "$REPLY_TLS" == [sS] || "$REPLY_TLS" == [yY] ]]; then
    vartls="yes"
fi

echo -e "${ENTER_LINE}- Nome do usuário de autenticação (ex: email@dominioexemplo.com.br):${NORMAL}"
read -r varmailusername
echo -e "${ENTER_LINE}- Qual é a senha de autenticação?:${NORMAL}"
read -r -s varmailpassword
echo "" # Newline after password input

varsenderaddress=$varmailusername # Default sender address
read -r -p "- O endereço de e-mail remetente é o mesmo que o usuário de autenticação ($varmailusername)? (S/n): " REPLY_SENDER
if [[ "$REPLY_SENDER" == [nN] ]]; then
    echo -e "${ENTER_LINE}- Qual é o endereço de e-mail do remetente?:${NORMAL}"
    read -r varsenderaddress
fi

echo ""
echo -e "${MENU}--- Aplicando Configurações ---${NORMAL}"

echo "Definindo aliases..."
if grep -q "^root:" /etc/aliases; then
    echo "Entrada de alias 'root:' encontrada, atualizando para: $varrootmail"
    sed -i "s/^root:.*$/root: $varrootmail/" /etc/aliases
else
    echo "Nenhum alias 'root:' encontrado, adicionando: root: $varrootmail"
    echo "root: $varrootmail" >> /etc/aliases
fi
newaliases # Apply alias changes

echo "Configurando sender_canonical_maps..."
echo "root $varsenderaddress" > /etc/postfix/sender_canonical
postmap /etc/postfix/sender_canonical
postconf -e "sender_canonical_maps = hash:/etc/postfix/sender_canonical"

echo "Configurando relayhost..."
postconf -e "relayhost = [$varmailserver]:$varmailport"

echo "Configurando autenticação SASL..."
echo "[$varmailserver]:$varmailport $varmailusername:$varmailpassword" > /etc/postfix/sasl_passwd
chmod 600 /etc/postfix/sasl_passwd
postmap /etc/postfix/sasl_passwd
postconf -e "smtp_sasl_auth_enable = yes"
postconf -e "smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd"
postconf -e "smtp_sasl_security_options = noanonymous"

echo "Configurando TLS ($vartls)..."
if [ "$vartls" == "yes" ]; then
    postconf -e "smtp_use_tls = yes"
    postconf -e "smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt"
    postconf -e "smtp_tls_security_level = encrypt"
    if [ "$varmailport" == "465" ]; then # SMTPS
        postconf -e "smtp_tls_wrappermode = yes"
    else # STARTTLS
        postconf -e "smtp_tls_wrappermode = no"
    fi
else
    postconf -e "smtp_use_tls = no"
fi

# Ensure necessary packages are installed
echo "Verificando e instalando dependências (libsasl2-modules, postfix)..."
apt update > /dev/null
apt install postfix libsasl2-modules -y

echo "Reiniciando Postfix..."
systemctl restart postfix
systemctl enable postfix

echo "Limpando arquivo de senha temporário sasl_passwd (se desejado e não em modo debug)..."
# rm -f /etc/postfix/sasl_passwd # For security, this can be removed after postmap.
# Original script did remove it, so following that, but be aware.
rm -f "/etc/postfix/sasl_passwd"

echo ""
echo -e "${MENU}=== Configuração de E-mail PBS Concluída. ===${NORMAL}"
echo "Verifique os logs do Postfix (/var/log/mail.log) se houver problemas."
echo "É recomendado testar o envio de e-mail usando a opção correspondente no menu."
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
