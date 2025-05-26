# Proxmox Toolkit NG (Nova Geração)

Este repositório contém uma coleção de scripts shell projetados para simplificar a gestão e configuração do Proxmox Virtual Environment (PVE) e Proxmox Backup Server (PBS) através de uma interface de menu interativa.

## ⚠️ Important Disclaimer ⚠️

**Estes scripts são fornecidos COMO ESTÃO, sem qualquer garantia de qualquer tipo, expressa ou implícita.**

**O usuário assume TODA A RESPONSABILIDADE E RISCO pelo uso destes scripts.** O(s) autor(es) ou contribuidor(es) não são responsáveis por quaisquer danos, perda de dados ou instabilidade do sistema que possam surgir do seu uso, mesmo que devido a erros nos próprios scripts.

É **FORTEMENTE RECOMENDADO** que você:
*   Entenda completamente o que cada script e opção faz antes da execução.
*   Teste-os em um ambiente de não produção primeiro.
*   Tenha backups adequados de seus sistemas e dados.

**Ao optar por usar estes scripts, você reconhece e aceita estes termos e riscos.**

Este projeto é uma refatoração e modularização do script `proxmox-conf.sh` originalmente inspirado no `proxmox_toolbox` de Tontonjo.

## Estrutura Modular

O Proxmox Toolkit NG foi refatorado de um script monolítico para uma estrutura modular, proporcionando maior flexibilidade e facilidade de manutenção. Cada funcionalidade acessível através dos menus é agora um script individual localizado dentro de uma estrutura de diretórios organizada.

A estrutura principal do projeto é a seguinte:

*   **`/TcTI/PROXMOX_TOOLKIT/proxmox-launcher.sh`**: O ponto de entrada principal para o toolkit. Este é o script que você executará para iniciar a interface do menu.
*   **`/TcTI/PROXMOX_TOOLKIT/modules/common/`**: Contém scripts e variáveis compartilhadas usadas por múltiplos módulos (ex: `variables.sh`).
*   **`/TcTI/PROXMOX_TOOLKIT/modules/pve/`**: Contém módulos específicos para Proxmox VE, organizados em subdiretórios por categoria:
    *   `update/` (atualizações, upgrades)
    *   `disk/` (ferramentas de disco)
    *   `backup/` (tarefas de backup)
    *   `email/` (configuração de email)
    *   `tweaks/` (ajustes de sistema, VM, GUI, watchdog, etc.)
    *   `network/` (configuração de rede)
    *   `info/` (comandos e informações úteis)
*   **`/TcTI/PROXMOX_TOOLKIT/modules/pbs/`**: Contém módulos específicos para Proxmox Backup Server, organizados de forma similar:
    *   `update/`
    *   `disk/`
    *   `email/`
    *   `tweaks/`
    *   `network/`
*   **`/TcTI/PROXMOX_TOOLKIT/versions/`**:
    *   `manifest.txt`: (Simulado no repositório, mas representa o manifesto remoto) Define as versões mais recentes de cada módulo.
    *   `local_manifest.txt`: Armazena as versões dos módulos atualmente instalados localmente.

## Mecanismo de Atualização

O Proxmox Toolkit NG inclui um mecanismo para manter os módulos atualizados:

1.  **Verificação na Inicialização**: Ao executar `proxmox-launcher.sh`, ele primeiro chama uma função `check_for_updates()`.
2.  **Manifesto Remoto**: Esta função (atualmente) simula o download de um arquivo `manifest.txt` (localizado em `/TcTI/PROXMOX_TOOLKIT/versions/manifest.txt`, que por sua vez é preenchido pelo `cria-estrutura-NG.sh` a partir do arquivo no repositório) que atua como a "fonte da verdade" para as versões mais recentes de cada script modular.
3.  **Comparação e Download Individual**:
    *   O launcher compara as versões no manifesto "remoto" com as versões registradas em `local_manifest.txt` (ou se o arquivo local não existir/script estiver faltando).
    *   Se um script estiver desatualizado ou faltando, o launcher (atualmente) simula o download do módulo individualmente a partir de um caminho base (assumindo que os scripts atualizados estão disponíveis no repositório na mesma estrutura de caminhos). Na prática real, usaria `wget` ou `curl`.
    *   Após um "download" bem-sucedido, o `local_manifest.txt` é atualizado com a nova versão do script.
4.  **Atualização do Launcher**:
    *   O mecanismo de atualização atual foca nos módulos. Se houver mudanças significativas no próprio `proxmox-launcher.sh` ou no `check_for_updates()`, pode ser necessário reexecutar `cria-estrutura-NG.sh` para obter a versão mais recente do launcher e do manifesto mestre.
    *   O script `cria-estrutura-NG.sh` também é versionado no `manifest.txt`, então o `check_for_updates` notificará se uma nova versão do `cria-estrutura-NG.sh` estiver disponível, sugerindo uma atualização manual.

## Instalação e Uso

1.  **Configuração Inicial**:
    *   Baixe o script `cria-estrutura-NG.sh` do repositório.
    *   Torne-o executável: `chmod +x cria-estrutura-NG.sh`.
    *   Execute-o com privilégios de root: `sudo ./cria-estrutura-NG.sh`.
    *   Este script criará a estrutura de diretórios necessária em `/TcTI/PROXMOX_TOOLKIT/`, "baixará" (copiará localmente na simulação) o `proxmox-launcher.sh` e o `versions/manifest.txt`.

2.  **Execução do Toolkit**:
    *   Após a configuração inicial, execute o launcher principal:
        ```bash
        sudo /TcTI/PROXMOX_TOOLKIT/proxmox-launcher.sh
        ```
    *   Na primeira execução (e em execuções subsequentes), o launcher verificará por atualizações dos módulos conforme descrito no "Mecanismo de Atualização".

## Scripts Principais do Toolkit NG

*   **`cria-estrutura-NG.sh`**:
    *   **Função**: Script de configuração inicial.
    *   **Descrição**: Prepara o ambiente criando a nova estrutura de diretórios em `/TcTI/PROXMOX_TOOLKIT/`. Simula o download do `proxmox-launcher.sh` e do `versions/manifest.txt` para seus respectivos locais. Define permissões de execução para o launcher. **Este script substitui o antigo `cria-estrutura`.**

*   **`proxmox-launcher.sh`**:
    *   **Função**: Ponto de entrada principal e gerenciador de menus.
    *   **Descrição**: Apresenta o menu principal para selecionar entre gerenciamento PVE ou PBS. Contém o mecanismo de atualização de módulos e chama os scripts modulares apropriados com base na seleção do usuário. **Este script substitui a funcionalidade de menu e atualização do antigo `proxmox-ini.sh` e a maior parte do `proxmox-conf.sh`.**

*   **Módulos (`modules/**/*.sh`)**:
    *   **Função**: Scripts individuais para cada funcionalidade específica.
    *   **Descrição**: Contêm a lógica real para as tarefas de gerenciamento, como atualizações, configuração de disco, etc. As funcionalidades do antigo `proxmox-conf.sh` foram migradas para estes módulos.

### Scripts Depreciados

*   `cria-estrutura`: O script de configuração original. **Use `cria-estrutura-NG.sh` em vez deste.**
*   `proxmox-ini.sh`: O antigo script de atualização e inicialização. Sua funcionalidade de atualização de scripts foi incorporada ao `proxmox-launcher.sh`, e a inicialização é feita diretamente pelo `proxmox-launcher.sh`.
*   `proxmox-conf.sh` (monolítico): O script principal original. Suas funcionalidades foram divididas nos diversos módulos dentro de `modules/pve/` e `modules/pbs/`.

## Funcionalidades Detalhadas (via Módulos)

O `proxmox-launcher.sh` organiza o acesso às seguintes funcionalidades, agora implementadas como módulos individuais:

### Proxmox Virtual Environment (PVE) Management
(As seções de funcionalidades PVE e PBS permanecem relevantes, pois descrevem o que os módulos fazem)
1.  **Updates, Installation & Upgrade:**
    *   Handles system updates and upgrades (e.g., from PVE 5.x to 6.x, 6.x to 7.x, 7.x to 8.x).
    *   Installs commonly used applications and utilities.
    *   Manages Proxmox repository configurations.

2.  **Disk Management:**
    *   Configures disks for use as PVE storage.
    *   Performs disk speed tests, bad sector checks, S.M.A.R.T. status.
    *   Manages LVM storage.

3.  **Backup Tasks:**
    *   Configures NFS for backups, installs PBS alongside PVE.
    *   Schedules and restores PVE host configuration backups.

4.  **Email Configuration:**
    *   Configures Postfix for email notifications.

5.  **System Tweaks & Adjustments:**
    *   Monitors temperature, manages VMs (unlock, stop, start).
    *   Configures SWAP, displays host info.
    *   Installs/uninstalls login script, GUI, watchdog.

6.  **Network Configuration:**
    *   Edits network interfaces, DNS, and hosts file.

7.  **Useful Commands & Information:**
    *   Lists common Linux/PVE commands and paths.

### Proxmox Backup Server (PBS) Management

1.  **Updates, Installation & Upgrade:**
    *   Handles system updates and PBS version upgrades.
    *   Installs essential applications.

2.  **Disk Management:**
    *   Configures disks for PBS datastores.
    *   Performs disk speed tests, bad sector checks, S.M.A.R.T. status.

3.  **Email Configuration:**
    *   Configures Postfix for email notifications.

4.  **System Tweaks & Adjustments:**
    *   Monitors temperature, manages SWAP, displays host info.
    *   Installs/uninstalls login script.

5.  **Network Configuration:**
    *   Edits network interfaces, DNS, and hosts file.

## Propósito

O objetivo principal destes scripts é consolidar tarefas comuns de gerenciamento do Proxmox PVE e PBS em uma interface shell interativa e fácil de usar, reduzindo a necessidade de operações manuais na linha de comando para procedimentos de rotina.

## Público Alvo

Estes scripts destinam-se principalmente a **administradores de sistemas** e **profissionais de TI** responsáveis pela implantação, gerenciamento e manutenção de instâncias Proxmox VE e Proxmox Backup Server.

## Conclusão

Este repositório fornece um valioso conjunto de ferramentas para administradores Proxmox VE e PBS que buscam simplificar e agilizar suas tarefas de gerenciamento de servidores. Com o mecanismo de atualização integrado, os usuários podem facilmente manter-se atualizados com as últimas melhorias e funcionalidades dos módulos.
