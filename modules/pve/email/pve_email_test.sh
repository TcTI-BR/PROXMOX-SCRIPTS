#!/bin/bash
MODULE_VERSION="1.0"

# Source shared variables
# shellcheck source=../../common/variables.sh
source "$(dirname "$0")/../../common/variables.sh"
# hostname and date variables are used from variables.sh

clear
echo -e "${MENU}=== Teste de Envio de E-mail ===${NORMAL}"

# Ensure script is run as root (mutt might require it, or for consistency)
if [[ $(id -u) -ne 0 ]] ; then
    echo -e "${RED_TEXT}- Por favor execute com o root / sudo${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

# Check if mutt is installed
if ! command -v mutt &> /dev/null; then
    echo "Comando 'mutt' não encontrado. Tentando instalar..."
    apt update
    apt install mutt -y
    if ! command -v mutt &> /dev/null; then
        echo -e "${RED_TEXT}Falha ao instalar 'mutt'. Por favor, instale manualmente.${NORMAL}"
        read -n 1 -s -r -p "Pressione uma tecla para continuar..."
        exit 1
    fi
fi


echo -e "${ENTER_LINE}- Qual é o endereço de e-mail do destinatário para o teste?:${NORMAL}"
read -r vardestaddress
if [ -z "$vardestaddress" ]; then
    echo -e "${RED_TEXT}Endereço de e-mail não especificado. Abortando.${NORMAL}"
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
    exit 1
fi

echo ""
echo -e "${MENU}Enviando e-mail de teste para: $vardestaddress...${NORMAL}"
# Using hostname and date variables sourced from variables.sh
SUBJECT_EMAIL="Teste de e-mail - $hostname - $date"
BODY_EMAIL="Este e-mail confirma que a configuração de e-mail do seu servidor PVE ($hostname) está funcionando corretamente em $date."

if echo "$BODY_EMAIL" | mail -s "$SUBJECT_EMAIL" "$vardestaddress"; then
    echo -e "${GREEN}E-mail de teste enviado com sucesso (verifique a caixa de entrada e spam).${NORMAL}"
else
    echo -e "${RED_TEXT}Falha ao enviar e-mail de teste.${NORMAL}"
    echo "Verifique os logs do Postfix (/var/log/mail.log) e as configurações de e-mail."
fi

echo ""
echo -e "${MENU}=== Teste de envio concluído. ===${NORMAL}"
read -n 1 -s -r -p "Pressione uma tecla para continuar..."
