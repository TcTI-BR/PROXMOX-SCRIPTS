#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh" # Adjusted path

clear
echo -e "${MENU}=== PBS: Verificação de Logs de E-mail (Postfix) ===${NORMAL}"

# Ensure script is run as root
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo -e "${MENU}Verificando logs em /var/log/mail.log...${NORMAL}"
echo "Últimas 20 linhas do mail.log:"
tail -n 20 /var/log/mail.log
echo "---"
echo "Últimas 20 linhas do mail.err:"
tail -n 20 /var/log/mail.err
echo "---"

applied_fix=0

if grep -q "SMTPUTF8 is required" "/var/log/mail.log"; then
    echo -e "${YELLOW_TEXT}INFO: Encontrado erro no log - 'SMTPUTF8 is required'.${NORMAL}"
    if grep -q "smtputf8_enable = no" /etc/postfix/main.cf; then
        echo -e "${GREEN}Correção 'smtputf8_enable = no' já parece estar aplicada.${NORMAL}"
    else
        read -r -p "Deseja aplicar a correção 'smtputf8_enable = no' ao Postfix? (s/N): " confirm_smtputf8
        if [[ "$confirm_smtputf8" == [sS] || "$confirm_smtputf8" == [yY] ]]; then
            echo "Aplicando 'smtputf8_enable = no'..."
            postconf smtputf8_enable=no
            postfix reload
            applied_fix=1
            echo -e "${GREEN}Correção aplicada.${NORMAL}"
        else
            echo "Correção não aplicada."
        fi
    fi
fi

if grep -q "Network is unreachable" "/var/log/mail.log"; then
    echo -e "${YELLOW_TEXT}INFO: Encontrado erro no log - 'Network is unreachable'. Pode ser um problema de IPv6.${NORMAL}"
    if grep -q "inet_protocols = ipv4" /etc/postfix/main.cf; then
        echo -e "${GREEN}Configuração 'inet_protocols = ipv4' já parece estar aplicada.${NORMAL}"
    else
        read -r -p "Deseja forçar o Postfix a usar IPv4 ('inet_protocols = ipv4')? (s/N): " confirm_ipv4
        if [[ "$confirm_ipv4" == [sS] || "$confirm_ipv4" == [yY] ]]; then
            echo "Aplicando 'inet_protocols = ipv4'..."
            postconf inet_protocols=ipv4
            postfix reload
            applied_fix=1
            echo -e "${GREEN}Configuração aplicada.${NORMAL}"
        else
            echo "Configuração não aplicada."
        fi
    fi
fi

if grep -q "smtp_tls_security_level = encrypt" "/var/log/mail.log"; then
    echo -e "${YELLOW_TEXT}INFO: Log contém 'smtp_tls_security_level = encrypt'. Isso geralmente é uma configuração desejada.${NORMAL}"
    if ! grep -q "smtp_tls_security_level = encrypt" /etc/postfix/main.cf; then
        read -r -p "Seu Postfix não tem 'smtp_tls_security_level = encrypt'. Deseja aplicar? (s/N): " confirm_tls_encrypt
        if [[ "$confirm_tls_encrypt" == [sS] || "$confirm_tls_encrypt" == [yY] ]]; then
            echo "Aplicando 'smtp_tls_security_level = encrypt'..."
            postconf smtp_tls_security_level=encrypt
            postfix reload
            applied_fix=1
            echo -e "${GREEN}Configuração aplicada.${NORMAL}"
        else
            echo "Configuração não aplicada."
        fi
    else
         echo -e "${GREEN}'smtp_tls_security_level = encrypt' já está configurado.${NORMAL}"
    fi
fi

if grep -q "smtp_tls_wrappermode = yes" "/var/log/mail.log"; then
    echo -e "${YELLOW_TEXT}INFO: Log contém 'smtp_tls_wrappermode = yes'. Isso é usado para SMTPS (port 465).${NORMAL}"
    if ! grep -q "smtp_tls_wrappermode = yes" /etc/postfix/main.cf; then
        read -r -p "Seu Postfix não tem 'smtp_tls_wrappermode = yes'. Deseja aplicar? (Útil para relay na porta 465) (s/N): " confirm_wrappermode
        if [[ "$confirm_wrappermode" == [sS] || "$confirm_wrappermode" == [yY] ]]; then
            echo "Aplicando 'smtp_tls_wrappermode = yes'..."
            postconf smtp_tls_wrappermode=yes
            postfix reload
            applied_fix=1
            echo -e "${GREEN}Configuração aplicada.${NORMAL}"
        else
            echo "Configuração não aplicada."
        fi
    else
        echo -e "${GREEN}'smtp_tls_wrappermode = yes' já está configurado.${NORMAL}"
    fi
fi

if [ "$applied_fix" -eq 0 ]; then
    echo ""
    echo "Nenhuma correção automática foi aplicada ou nenhuma condição de erro conhecida foi detectada para correção automática."
fi

echo ""
echo -e "${MENU}=== Verificação de logs PBS concluída. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
