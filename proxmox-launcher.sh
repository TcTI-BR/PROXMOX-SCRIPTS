#!/bin/bash

# Source shared variables
# shellcheck source=modules/common/variables.sh
source "$(dirname "$0")/modules/common/variables.sh"

# --- Update Check Function ---
check_for_updates() {
    echo "Verificando atualizações..."
    local remote_manifest_url="https://raw.githubusercontent.com/TcTI-BR/PROXMOX-SCRIPTS/main/versions/manifest.txt" # In a real scenario
    local remote_manifest_temp="versions/remote_manifest_temp.txt"
    local local_manifest="versions/local_manifest.txt"
    local base_download_url="https://raw.githubusercontent.com/TcTI-BR/PROXMOX-SCRIPTS/main/" # In a real scenario

    # Ensure versions directory exists
    mkdir -p "$(dirname "$0")/versions"

    # Simulate Download of remote manifest
    if ! cp "$(dirname "$0")/versions/manifest.txt" "$(dirname "$0")/$remote_manifest_temp"; then
        echo -e "${RED_TEXT}Erro: Falha ao simular o download do manifesto remoto (copiando versions/manifest.txt).${NORMAL}"
        echo "Verificação de atualizações cancelada."
        read -n 1 -s -r -p "Pressione uma tecla para continuar..."
        return 1
    fi
    echo "Manifesto remoto 'baixado' para $remote_manifest_temp"

    if [ ! -f "$local_manifest" ]; then
        echo "Manifesto local não encontrado. Criando a partir do remoto (simulando primeira execução)..."
        if ! cp "$remote_manifest_temp" "$local_manifest"; then
            echo -e "${RED_TEXT}Erro: Falha ao criar manifesto local a partir do remoto.${NORMAL}"
            rm "$remote_manifest_temp"
            read -n 1 -s -r -p "Pressione uma tecla para continuar..."
            return 1
        fi
    fi

    local updated_anything=0
    # Compare Manifests
    local new_local_manifest_temp="${local_manifest}.new"
    cp "$remote_manifest_temp" "$new_local_manifest_temp" # Start with remote as base for new local

    while IFS= read -r remote_line || [[ -n "$remote_line" ]]; do
        if [ -z "$remote_line" ]; then continue; fi
        
        script_path=$(echo "$remote_line" | cut -d':' -f1)
        remote_version=$(echo "$remote_line" | cut -d':' -f2)

        if [ -z "$script_path" ] || [ -z "$remote_version" ]; then
            echo -e "${RED_TEXT}Aviso: Linha mal formatada no manifesto remoto: '$remote_line'${NORMAL}"
            continue
        fi
        
        local_version=""
        if grep -q "^${script_path}:" "$local_manifest"; then
            local_version=$(grep "^${script_path}:" "$local_manifest" | cut -d':' -f2)
        fi

        script_full_path="$(dirname "$0")/$script_path"

        if [ ! -f "$script_full_path" ] || [ "$remote_version" != "$local_version" ]; then
            if [ ! -f "$script_full_path" ]; then
                echo -e "${MENU}Script ${script_path} não encontrado localmente. Baixando versão ${remote_version}...${NORMAL}"
            else
                echo -e "${MENU}Atualizando ${script_path} da versão ${local_version:-'local não versionado/novo'} para ${remote_version}...${NORMAL}"
            fi
            
            if [ -f "${script_full_path}" ]; then 
                if cp "${script_full_path}" "${script_full_path}.tmp_update_download"; then
                    mv "${script_full_path}.tmp_update_download" "${script_full_path}"
                    echo "Simulado download de ${script_path} para ${script_full_path}"
                    chmod +x "${script_full_path}"
                    echo "Permissões de execução concedidas para ${script_path}."
                    updated_anything=1
                    sed -i "s|^${script_path}:.*$|${script_path}:${remote_version}|" "$new_local_manifest_temp"
                else
                    echo -e "${RED_TEXT}Falha ao simular download (cp) de ${script_path}. A versão local pode estar desatualizada.${NORMAL}"
                fi
            elif [[ "$remote_line" == *"modules/"* ]]; then 
                echo "#!/bin/bash
# Placeholder for ${script_path} - Version ${remote_version}
echo \"Este é um placeholder para ${script_path}. Implementação pendente.\"
                " > "${script_full_path}"
                chmod +x "${script_full_path}"
                echo "Placeholder para novo script ${script_path} (versão ${remote_version}) criado e tornado executável."
                updated_anything=1
                if grep -q "^${script_path}:" "$new_local_manifest_temp"; then
                    sed -i "s|^${script_path}:.*$|${script_path}:${remote_version}|" "$new_local_manifest_temp"
                else
                    echo "${script_path}:${remote_version}" >> "$new_local_manifest_temp"
                fi
            else
                echo -e "${RED_TEXT}Script ${script_path} não encontrado localmente para simular download e não é um módulo padrão para criar placeholder.${NORMAL}"
            fi
        else
            echo "Script ${script_path} está atualizado (Versão ${local_version})."
        fi
    done < "$remote_manifest_temp"

    if mv "$new_local_manifest_temp" "$local_manifest"; then
        echo "Manifesto local atualizado."
    else
        echo -e "${RED_TEXT}Erro ao atualizar o manifesto local a partir de $new_local_manifest_temp.${NORMAL}"
    fi

    if ! rm "$remote_manifest_temp"; then
         echo -e "${RED_TEXT}Aviso: Falha ao remover manifesto remoto temporário $remote_manifest_temp ${NORMAL}"
    fi
    
    if [ "$updated_anything" -eq 1 ]; then
         echo -e "${MENU}Verificação de atualizações concluída. Alguns scripts foram atualizados.${NORMAL}"
         echo "É recomendado reiniciar o launcher para aplicar todas as mudanças."
    else
        echo "Verificação de atualizações concluída. Todos os scripts monitorados estão atualizados."
    fi
    read -n 1 -s -r -p "Pressione uma tecla para continuar..."
}
# --- Fim da Função de Update Check ---

# --- PVE Menu Functions ---
pve_update_menu_call() {
    clear
    echo -e "${MENU}====== PVE: Atualização e Instalação ======${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Upgrade de versões ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Atualização do sistema e instalação de aplicativos ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu PVE ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) pve_upgrade_submenu_call; return ;;
        2) clear; bash "$(dirname "$0")/modules/pve/update/pve_update_system_apps.sh"; pve_update_menu_call ;;
        0) pve_main_menu ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pve_update_menu_call ;;
    esac
}

pve_upgrade_submenu_call() {
    clear
    echo -e "${MENU}====== PVE: Upgrade de Versões ======${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Upgrade da versão 5.x para a versão 6.x ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Upgrade da versão 6.x para a versão 7.x ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Upgrade da versão 7.x para a versão 8.x ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu de Atualização ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) clear; bash "$(dirname "$0")/modules/pve/update/pve_upgrade_5_to_6.sh"; pve_upgrade_submenu_call ;;
        2) clear; bash "$(dirname "$0")/modules/pve/update/pve_upgrade_6_to_7.sh"; pve_upgrade_submenu_call ;;
        3) clear; bash "$(dirname "$0")/modules/pve/update/pve_upgrade_7_to_8.sh"; pve_upgrade_submenu_call ;;
        0) pve_update_menu_call ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pve_upgrade_submenu_call ;;
    esac
}

pve_disk_menu_call() {
    clear
    echo -e "${MENU}========= PVE: Ferramentas de Disco =========${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Configura discos ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Teste de velocidade dos discos ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Verifica setores defeituosos em discos ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Verifica o SMART do disco ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 5)${MENU} Remove o storage local-lvm ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu PVE ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) clear; bash "$(dirname "$0")/modules/pve/disk/pve_disk_configure.sh"; pve_disk_menu_call ;;
        2) clear; bash "$(dirname "$0")/modules/pve/disk/pve_disk_test_speed.sh"; pve_disk_menu_call ;;
        3) clear; bash "$(dirname "$0")/modules/pve/disk/pve_disk_check_sectors.sh"; pve_disk_menu_call ;;
        4) clear; bash "$(dirname "$0")/modules/pve/disk/pve_disk_check_smart.sh"; pve_disk_menu_call ;;
        5) clear; bash "$(dirname "$0")/modules/pve/disk/pve_disk_remove_local_lvm.sh"; pve_disk_menu_call ;;
        0) pve_main_menu ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pve_disk_menu_call ;;
    esac
}

pve_backup_menu_call() {
    clear
    echo -e "${MENU}========= PVE: Tarefas de Backup =========${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Configura o serviço de NFS para receber o BACKUP ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Instala o PBS lado a lado com o PVE ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Agenda o BACKUP das configurações do PROXMOX ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Restaura o BACKUP das configurações do PROXMOX ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu PVE ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) clear; bash "$(dirname "$0")/modules/pve/backup/pve_backup_configure_nfs.sh"; pve_backup_menu_call ;;
        2) clear; bash "$(dirname "$0")/modules/pve/backup/pve_backup_install_pbs_alongside.sh"; pve_backup_menu_call ;;
        3) clear; bash "$(dirname "$0")/modules/pve/backup/pve_backup_schedule_pve_config.sh"; pve_backup_menu_call ;;
        4) clear; bash "$(dirname "$0")/modules/pve/backup/pve_backup_restore_pve_config.sh"; pve_backup_menu_call ;;
        0) pve_main_menu ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pve_backup_menu_call ;;
    esac
}

pve_email_menu_call() {
    clear
    echo -e "${MENU}====== PVE: Configuração de E-mail ======${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Configura o serviço de e-mail ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Testa as configurações ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Verifica os logs para tentar executar a correção ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Restaura a configuração original ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu PVE ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) clear; bash "$(dirname "$0")/modules/pve/email/pve_email_configure.sh"; pve_email_menu_call ;;
        2) clear; bash "$(dirname "$0")/modules/pve/email/pve_email_test.sh"; pve_email_menu_call ;;
        3) clear; bash "$(dirname "$0")/modules/pve/email/pve_email_check_logs.sh"; pve_email_menu_call ;;
        4) clear; bash "$(dirname "$0")/modules/pve/email/pve_email_restore_original.sh"; pve_email_menu_call ;;
        0) pve_main_menu ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pve_email_menu_call ;;
    esac
}

pve_tweaks_vm_submenu_call() {
    clear
    echo -e "${MENU}====== PVE Tweaks: Gerenciamento de VM ======${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Destranca VM ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Destranca e desliga VM ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Destranca, desliga e reinicia VM ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu de Ajustes ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) clear; bash "$(dirname "$0")/modules/pve/tweaks/pve_tweaks_vm_unlock.sh"; pve_tweaks_vm_submenu_call ;;
        2) clear; bash "$(dirname "$0")/modules/pve/tweaks/pve_tweaks_vm_unlock_stop.sh"; pve_tweaks_vm_submenu_call ;;
        3) clear; bash "$(dirname "$0")/modules/pve/tweaks/pve_tweaks_vm_unlock_stop_start.sh"; pve_tweaks_vm_submenu_call ;;
        0) pve_tweaks_menu_call ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pve_tweaks_vm_submenu_call ;;
    esac
}

pve_tweaks_script_login_submenu_call() {
    clear
    echo -e "${MENU}====== PVE Tweaks: Script de Login ======${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Instala script para executar no login ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Desinstala script de execução no login ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu de Ajustes ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) clear; bash "$(dirname "$0")/modules/pve/tweaks/pve_tweaks_script_login_install.sh"; pve_tweaks_script_login_submenu_call ;;
        2) clear; bash "$(dirname "$0")/modules/pve/tweaks/pve_tweaks_script_login_uninstall.sh"; pve_tweaks_script_login_submenu_call ;;
        0) pve_tweaks_menu_call ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pve_tweaks_script_login_submenu_call ;;
    esac
}

pve_tweaks_gui_submenu_call() {
    clear
    echo -e "${MENU}====== PVE Tweaks: Interface Gráfica e Chromium ======${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Instala interface grafica (XFCE) e Chromium ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Inicia interface grafica (startx) ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu de Ajustes ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) clear; bash "$(dirname "$0")/modules/pve/tweaks/pve_tweaks_gui_chromium_install.sh"; pve_tweaks_gui_submenu_call ;;
        2) clear; bash "$(dirname "$0")/modules/pve/tweaks/pve_tweaks_gui_start.sh"; pve_tweaks_gui_submenu_call ;;
        0) pve_tweaks_menu_call ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pve_tweaks_gui_submenu_call ;;
    esac
}

pve_tweaks_watchdog_submenu_call() {
    clear
    echo -e "${MENU}====== PVE Tweaks: Configuração do Watchdog ======${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Cria agendamento do watchdog (10 em 10 min) ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Remove agendamento do watchdog ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Lista VMs monitoradas pelo watchdog ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Adiciona VM ao monitoramento do watchdog ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 5)${MENU} Remove VM do monitoramento do watchdog ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu de Ajustes ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) clear; bash "$(dirname "$0")/modules/pve/tweaks/pve_tweaks_watchdog_schedule_create.sh"; pve_tweaks_watchdog_submenu_call ;;
        2) clear; bash "$(dirname "$0")/modules/pve/tweaks/pve_tweaks_watchdog_schedule_remove.sh"; pve_tweaks_watchdog_submenu_call ;;
        3) clear; bash "$(dirname "$0")/modules/pve/tweaks/pve_tweaks_watchdog_list_monitored_vms.sh"; pve_tweaks_watchdog_submenu_call ;;
        4) clear; bash "$(dirname "$0")/modules/pve/tweaks/pve_tweaks_watchdog_add_vm.sh"; pve_tweaks_watchdog_submenu_call ;;
        5) clear; bash "$(dirname "$0")/modules/pve/tweaks/pve_tweaks_watchdog_remove_vm.sh"; pve_tweaks_watchdog_submenu_call ;;
        0) pve_tweaks_menu_call ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pve_tweaks_watchdog_submenu_call ;;
    esac
}

pve_tweaks_menu_call() {
    clear
    echo -e "${MENU}====== PVE: Configurações e Ajustes ======${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Verifica temperatura ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Destranca, desliga e reinicia VM ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Configura SWAP ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Informações do Host ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 5)${MENU} Instala ou desinstala o script ao carregar o usuário ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 6)${MENU} Instala interface grafica e o Chromium ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 7)${MENU} Configura o watchdog ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu PVE ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) clear; bash "$(dirname "$0")/modules/pve/tweaks/pve_tweaks_check_temp.sh"; pve_tweaks_menu_call ;;
        2) pve_tweaks_vm_submenu_call; return ;; 
        3) clear; bash "$(dirname "$0")/modules/pve/tweaks/pve_tweaks_configure_swap.sh"; pve_tweaks_menu_call ;;
        4) clear; bash "$(dirname "$0")/modules/pve/tweaks/pve_tweaks_host_info.sh"; pve_tweaks_menu_call ;;
        5) pve_tweaks_script_login_submenu_call; return ;;
        6) pve_tweaks_gui_submenu_call; return ;;
        7) pve_tweaks_watchdog_submenu_call; return ;;
        0) pve_main_menu ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pve_tweaks_menu_call ;;
    esac
}

pve_network_menu_call() {
    clear
    echo -e "${MENU}====== PVE: Configurações de Rede ======${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Configura interfaces de rede (/etc/network/interfaces) ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Configura DNS (/etc/resolv.conf) ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Configura hosts (/etc/hosts) ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu PVE ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) clear; bash "$(dirname "$0")/modules/pve/network/pve_network_configure_interfaces.sh"; pve_network_menu_call ;;
        2) clear; bash "$(dirname "$0")/modules/pve/network/pve_network_configure_dns.sh"; pve_network_menu_call ;;
        3) clear; bash "$(dirname "$0")/modules/pve/network/pve_network_configure_hosts.sh"; pve_network_menu_call ;;
        0) pve_main_menu ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pve_network_menu_call ;;
    esac
}

pve_info_menu_call() {
    clear
    echo -e "${MENU}====== PVE: Comandos e Informações Úteis ======${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Comandos Linux úteis ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Comandos PVE úteis ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Caminhos e informações gerais PVE ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu PVE ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) clear; bash "$(dirname "$0")/modules/pve/info/pve_info_linux_commands.sh"; pve_info_menu_call ;;
        2) clear; bash "$(dirname "$0")/modules/pve/info/pve_info_pve_commands.sh"; pve_info_menu_call ;;
        3) clear; bash "$(dirname "$0")/modules/pve/info/pve_info_general_paths.sh"; pve_info_menu_call ;;
        0) pve_main_menu ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pve_info_menu_call ;;
    esac
}

pve_main_menu() {
    clear
    echo -e "${MENU}********* Proxmox Virtual Environment Management *********${NORMAL}"
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
    case $opt in
        1) pve_update_menu_call; return ;;
        2) pve_disk_menu_call; return ;;
        3) pve_backup_menu_call; return ;;
        4) pve_email_menu_call; return ;;
        5) pve_tweaks_menu_call; return ;;
        6) pve_network_menu_call; return ;;
        7) pve_info_menu_call; return ;;
        0) main_menu; return ;;
        "") main_menu; return ;; # ENTER key behavior
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Press key..."; pve_main_menu ;;
    esac
}

# --- PBS Menu Functions ---
pbs_update_submenu_call() {
    clear
    echo -e "${MENU}====== PBS: Upgrade de Versões ======${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Upgrade da versão 1.x para a versão 2.x ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu de Atualização PBS ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) clear; bash "$(dirname "$0")/modules/pbs/update/pbs_upgrade_1_to_2.sh"; pbs_update_submenu_call ;;
        0) pbs_update_menu_call ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pbs_update_submenu_call ;;
    esac
}

pbs_update_menu_call() {
    clear
    echo -e "${MENU}====== PBS: Atualização e Instalação ======${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Upgrade de versões ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Atualização do sistema e instalação de aplicativos ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu PBS ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) pbs_update_submenu_call; return ;;
        2) clear; bash "$(dirname "$0")/modules/pbs/update/pbs_update_system_apps.sh"; pbs_update_menu_call ;;
        0) pbs_main_menu ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pbs_update_menu_call ;;
    esac
}

pbs_disk_menu_call() {
    clear
    echo -e "${MENU}========= PBS: Ferramentas de Disco =========${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Configura discos para Datastore ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Teste de velocidade dos discos ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Verifica setores defeituosos ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Verifica o SMART do disco ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu PBS ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) clear; bash "$(dirname "$0")/modules/pbs/disk/pbs_disk_configure.sh"; pbs_disk_menu_call ;;
        2) clear; bash "$(dirname "$0")/modules/pbs/disk/pbs_disk_test_speed.sh"; pbs_disk_menu_call ;;
        3) clear; bash "$(dirname "$0")/modules/pbs/disk/pbs_disk_check_sectors.sh"; pbs_disk_menu_call ;;
        4) clear; bash "$(dirname "$0")/modules/pbs/disk/pbs_disk_check_smart.sh"; pbs_disk_menu_call ;;
        0) pbs_main_menu ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pbs_disk_menu_call ;;
    esac
}

# --- PBS Email Menu Functions ---
pbs_email_menu_call() {
    clear
    echo -e "${MENU}====== PBS: Configuração de E-mail ======${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Configura o serviço de e-mail ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Testa as configurações ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Verifica os logs para tentar executar a correção ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Restaura a configuração original ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu PBS ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) clear; bash "$(dirname "$0")/modules/pbs/email/pbs_email_configure.sh"; pbs_email_menu_call ;;
        2) clear; bash "$(dirname "$0")/modules/pbs/email/pbs_email_test.sh"; pbs_email_menu_call ;;
        3) clear; bash "$(dirname "$0")/modules/pbs/email/pbs_email_check_logs.sh"; pbs_email_menu_call ;;
        4) clear; bash "$(dirname "$0")/modules/pbs/email/pbs_email_restore_original.sh"; pbs_email_menu_call ;;
        0) pbs_main_menu ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pbs_email_menu_call ;;
    esac
}

# --- PBS Tweaks Menu Functions ---
pbs_tweaks_script_login_submenu_call() {
    clear
    echo -e "${MENU}====== PBS Tweaks: Script de Login ======${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Instala script para executar no login ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Desinstala script de execução no login ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu de Ajustes PBS ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) clear; bash "$(dirname "$0")/modules/pbs/tweaks/pbs_tweaks_script_login_install.sh"; pbs_tweaks_script_login_submenu_call ;;
        2) clear; bash "$(dirname "$0")/modules/pbs/tweaks/pbs_tweaks_script_login_uninstall.sh"; pbs_tweaks_script_login_submenu_call ;;
        0) pbs_tweaks_menu_call ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pbs_tweaks_script_login_submenu_call ;;
    esac
}

pbs_tweaks_menu_call() {
    clear
    echo -e "${MENU}====== PBS: Configurações e Ajustes ======${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Verifica temperatura ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Configura SWAP ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Informações do Host ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Instala ou desinstala o script ao carregar o usuário ${NORMAL}"
    # Opção 5 do script original (Remove o script ao carregar o usuario) está agrupada na 4.
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu PBS ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) clear; bash "$(dirname "$0")/modules/pbs/tweaks/pbs_tweaks_check_temp.sh"; pbs_tweaks_menu_call ;;
        2) clear; bash "$(dirname "$0")/modules/pbs/tweaks/pbs_tweaks_configure_swap.sh"; pbs_tweaks_menu_call ;;
        3) clear; bash "$(dirname "$0")/modules/pbs/tweaks/pbs_tweaks_host_info.sh"; pbs_tweaks_menu_call ;;
        4) pbs_tweaks_script_login_submenu_call; return ;;
        0) pbs_main_menu ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pbs_tweaks_menu_call ;;
    esac
}

# --- PBS Network Menu Functions ---
pbs_network_menu_call() {
    clear
    echo -e "${MENU}====== PBS: Configurações de Rede ======${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} Configura interfaces de rede (/etc/network/interfaces) ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Configura DNS (/etc/resolv.conf) ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Configura hosts (/etc/hosts) ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu PBS ${NORMAL}"
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL}"
    read -rsn1 opt
    case $opt in
        1) clear; bash "$(dirname "$0")/modules/pbs/network/pbs_network_configure_interfaces.sh"; pbs_network_menu_call ;;
        2) clear; bash "$(dirname "$0")/modules/pbs/network/pbs_network_configure_dns.sh"; pbs_network_menu_call ;;
        3) clear; bash "$(dirname "$0")/modules/pbs/network/pbs_network_configure_hosts.sh"; pbs_network_menu_call ;;
        0) pbs_main_menu ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pbs_network_menu_call ;;
    esac
}

pbs_main_menu() {
    clear
    echo -e "${MENU}************ Proxmox Backup Server Management ************${NORMAL}"
    echo -e "${MENU}********************** Por Marcelo Machado ****************************${NORMAL}"
    echo " "
    echo -e "${MENU}**${NUMBER} 1)${MENU} Atualização, instalação e upgrade do sistema ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} Ferramentas de disco ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Configuração do email ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} Configurações e ajustes ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 5)${MENU} Configurações de rede ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 0)${MENU} Voltar para o Menu Principal ${NORMAL}"
    echo " "
    echo -e "${MENU}***********************************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Digite uma opção: ${NORMAL} "
    read -rsn1 opt
    case $opt in
        1) pbs_update_menu_call; return ;;
        2) pbs_disk_menu_call; return ;; 
        3) pbs_email_menu_call; return ;;
        4) pbs_tweaks_menu_call; return ;;
        5) pbs_network_menu_call; return ;;
        0) main_menu; return ;;
        "") main_menu; return ;; # ENTER key behavior
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; pbs_main_menu ;;
    esac
}

# --- Main Menu ---
main_menu() {
    check_for_updates
    clear
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
    case $opt in
        1) pve_main_menu ;;
        2) pbs_main_menu ;; 
        0) clear; echo "Saindo..."; exit 0 ;;
        "") clear; echo "Saindo..."; exit 0 ;;
        *) echo -e "\n${RED_TEXT}Opção inválida!${NORMAL}"; read -n 1 -s -r -p "Pressione tecla..."; main_menu ;;
    esac
}

# Start the script by calling the main menu
main_menu
