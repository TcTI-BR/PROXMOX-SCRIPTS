# Proxmox Management Scripts

This repository contains a collection of shell scripts designed to simplify the management and configuration of Proxmox Virtual Environment (PVE) and Proxmox Backup Server (PBS).

## ⚠️ Important Disclaimer ⚠️

**These scripts are provided AS-IS, without any warranty of any kind, express or implied.**

**The user assumes ALL RESPONSIBILITY AND RISK for the use of these scripts.** The author(s) or contributor(s) are not responsible for any damage, data loss, or system instability that may arise from their use, even if due to errors within the scripts themselves.

It is **STRONGLY RECOMMENDED** that you:
*   Thoroughly understand what each script and option does before execution.
*   Test them in a non-production environment first.
*   Have adequate backups of your systems and data.

**By choosing to use these scripts, you acknowledge and accept these terms and risks.**

These scripts are inspired by the `proxmox_toolbox` by Tontonjo.

## Detailed Functionality of `proxmox-conf.sh`

The `proxmox-conf.sh` script is the centerpiece of this repository. It is a comprehensive, menu-driven shell script that acts as an interactive toolbox for managing both Proxmox Virtual Environment (PVE) and Proxmox Backup Server (PBS). Upon execution, it presents a main menu where users can choose between PVE or PBS management, leading to further sub-menus with specific operations.

### Proxmox Virtual Environment (PVE) Management

For PVE, the script offers the following categories of operations:

1.  **Updates, Installation & Upgrade:**
    *   Handles system updates and upgrades (e.g., from PVE 5.x to 6.x, 6.x to 7.x, 7.x to 8.x).
    *   Installs commonly used applications and utilities (e.g., `libsasl2-modules`, `lm-sensors`, `ifupdown2`, `ntfs-3g`, `ethtool`, `zip`, `mutt`).
    *   Manages Proxmox repository configurations (e.g., switching to no-subscription repositories).

2.  **Disk Management:**
    *   Configures disks for use as PVE storage: formats disks (ext4), creates mount points, updates `/etc/fstab`, and adds storage to PVE (`pvesm add dir`).
    *   Performs disk speed tests using `hdparm`.
    *   Checks for bad sectors using `badblocks`.
    *   Retrieves S.M.A.R.T. disk health status using `smartctl`.
    *   Removes the `local-lvm` storage and resizes the `root` partition.

3.  **Backup Tasks:**
    *   Configures the host as an NFS server to allow network backups from other Proxmox servers.
    *   Installs Proxmox Backup Server (PBS) alongside PVE on the same host.
    *   Schedules automated backups of PVE host configuration files (e.g., `/etc/pve`, `/etc/network/interfaces`, cron jobs, VM configurations).
    *   Restores PVE host configuration files from a backup.

4.  **Email Configuration:**
    *   Configures Postfix for sending email notifications.
    *   Allows setting up mail server details, authentication, and sender/receiver addresses.
    *   Includes options to test email setup and check mail logs for troubleshooting.
    *   Provides functionality to restore original Postfix configurations.

5.  **System Tweaks & Adjustments:**
    *   Monitors hardware temperature using `lm-sensors`.
    *   Manages Virtual Machines (VMs): unlocks stuck VMs, forcefully stops VMs, and restarts VMs.
    *   Configures system SWAP behavior (swappiness).
    *   Displays detailed host information (system load, memory usage, uptime, IP address, disk space).
    *   Installs/uninstalls the `proxmox-conf.sh` script to run automatically on user login.
    *   Installs a desktop environment (XFCE) and Chromium browser for accessing the PVE web UI locally.
    *   Configures watchdog services to monitor and automatically restart VMs if they become unresponsive.

6.  **Network Configuration:**
    *   Provides shortcuts to edit network interface files (`/etc/network/interfaces`).
    *   Allows editing DNS resolver configuration (`/etc/resolv.conf`).
    *   Facilitates editing the local hosts file (`/etc/hosts`).

7.  **Useful Commands & Information:**
    *   Displays a list of commonly used Linux and PVE commands.
    *   Provides quick access to important PVE file paths (e.g., VM configuration files, ISO template locations).

### Proxmox Backup Server (PBS) Management

For PBS, the script offers a similar, tailored set of functionalities:

1.  **Updates, Installation & Upgrade:**
    *   Handles system updates and upgrades (e.g., from PBS 1.x to 2.x).
    *   Installs essential applications (e.g., `libsasl2-modules`, `lm-sensors`, `ifupdown2`, `ethtool`, `hdparm`).
    *   Manages PBS repository configurations.

2.  **Disk Management:**
    *   Configures disks for use as PBS datastores: formats disks (ext4), creates mount points, updates `/etc/fstab`, and adds datastores to PBS (`proxmox-backup-manager datastore create`).
    *   Performs disk speed tests using `hdparm`.
    *   Checks for bad sectors using `badblocks`.
    *   Retrieves S.M.A.R.T. disk health status using `smartctl`.

3.  **Email Configuration:**
    *   Configures Postfix for sending email notifications (similar to the PVE email configuration).
    *   Allows setting up mail server details, authentication, and sender/receiver addresses.
    *   Includes options to test email setup and check mail logs.

4.  **System Tweaks & Adjustments:**
    *   Monitors hardware temperature using `lm-sensors`.
    *   Configures system SWAP behavior.
    *   Displays detailed host information.
    *   Installs/uninstalls the `proxmox-conf.sh` script to run automatically on user login.

5.  **Network Configuration:**
    *   Provides shortcuts to edit network interface files.
    *   Allows editing DNS resolver configuration.
    *   Facilitates editing the local hosts file.

## Scripts in this Repository

This repository contains three main scripts:

*   **`cria-estrutura`**:
    *   **Role**: Initial Setup Script.
    *   **Description**: This script is intended to be run first. It prepares the environment by creating the necessary directory structure (`/TcTI/SCRIPTS/`), then downloads `proxmox-ini.sh` into this directory, makes it executable, and runs it. This effectively bootstraps the system for using the other scripts.

*   **`proxmox-ini.sh`**:
    *   **Role**: Updater and Launcher Script.
    *   **Description**: This script acts as an intermediary. Its primary function is to ensure that you are always using the latest version of the main configuration script. It does this by backing up any existing `proxmox-conf.sh`, downloading the newest version from this GitHub repository, making it executable, and then immediately running `proxmox-conf.sh`.

*   **`proxmox-conf.sh`**:
    *   **Role**: Main Interactive Management Script.
    *   **Description**: This is the core script of the repository. It provides a comprehensive, menu-driven interface for managing various aspects of Proxmox VE (PVE) and Proxmox Backup Server (PBS). Its features are detailed in the "Detailed Functionality of `proxmox-conf.sh`" section above.

## Purpose

The main goal of these scripts is to consolidate common Proxmox PVE and PBS management tasks into an easy-to-use, interactive shell interface, reducing the need for manual command-line operations for routine procedures. This can be particularly helpful for users who prefer guided menus or want to automate common setup and maintenance tasks.

## Target Audience

These scripts are primarily intended for **system administrators** and **IT professionals** who are responsible for deploying, managing, and maintaining Proxmox Virtual Environment (PVE) and Proxmox Backup Server (PBS) instances. The toolbox is designed to simplify routine tasks and configurations for users who:

*   Manage one or more Proxmox servers.
*   Prefer a menu-driven interface for common operations.
*   Want to streamline setup and configuration processes.
*   Need to perform tasks like PVE/PBS updates, disk management, backup configuration, and system monitoring.

While the scripts can be used by anyone interested in learning more about Proxmox management, a basic understanding of Linux command-line and Proxmox concepts is beneficial.

## Update Mechanism: Staying Current

The scripts are designed to ensure that you can easily run the latest version of the main `proxmox-conf.sh` script with minimal manual intervention. This is achieved through the interaction of `cria-estrutura` and `proxmox-ini.sh`:

1.  **Initial Setup (`cria-estrutura`)**:
    *   When you first obtain the scripts, you typically start by running `cria-estrutura`.
    *   This script performs a one-time setup: it creates a dedicated directory (usually `/TcTI/SCRIPTS/`) on your Proxmox host.
    *   It then downloads `proxmox-ini.sh` directly from the [TcTI-BR/PROXMOX-SCRIPTS](https://github.com/TcTI-BR/PROXMOX-SCRIPTS) GitHub repository into this directory.
    *   Finally, it makes `proxmox-ini.sh` executable and runs it.

2.  **Fetching/Updating and Launching (`proxmox-ini.sh`)**:
    *   Each time `proxmox-ini.sh` is executed (either directly by the user after the initial setup, or as the last step of `cria-estrutura`), it performs the following actions:
        *   It backs up your current `proxmox-conf.sh` script (if one exists in `/TcTI/SCRIPTS/`) to `proxmox-conf-bkp.sh`. This preserves any local modifications you might have made, though it's generally recommended to contribute improvements back to the main repository.
        *   It downloads the latest version of `proxmox-conf.sh` from the `main` branch of the [TcTI-BR/PROXMOX-SCRIPTS](https://github.com/TcTI-BR/PROXMOX-SCRIPTS) GitHub repository, placing it in `/TcTI/SCRIPTS/`.
        *   It makes this newly downloaded `proxmox-conf.sh` executable.
        *   It then immediately executes `/TcTI/SCRIPTS/proxmox-conf.sh`, launching the main menu-driven interface.

**In essence**:
*   `cria-estrutura` is for the very first setup.
*   `proxmox-ini.sh` is the script you will typically run thereafter. It acts as an "updater and launcher," ensuring that `proxmox-conf.sh` is always fetched from the repository before being run. This means you don't need to manually download `proxmox-conf.sh` every time there's an update.

This mechanism ensures that bug fixes, new features, and improvements made to `proxmox-conf.sh` in the GitHub repository are easily accessible by simply re-running `proxmox-ini.sh`.

## Usage

1.  It's recommended to first run `cria-estrutura` on your Proxmox host. This script will create the `/TcTI/SCRIPTS` directory, download `proxmox-ini.sh`, and execute it.
    ```bash
    # Example of how you might download and run cria-estrutura
    # wget https://raw.githubusercontent.com/TcTI-BR/PROXMOX-SCRIPTS/main/cria-estrutura
    # chmod +x cria-estrutura
    # ./cria-estrutura
    ```
2.  Subsequently, `proxmox-ini.sh` (typically located in `/TcTI/SCRIPTS/`) can be run. It will automatically download the latest `proxmox-conf.sh` and launch the main menu.
    ```bash
    # Example:
    # /TcTI/SCRIPTS/proxmox-ini.sh
    ```

The main script `proxmox-conf.sh` will then guide you through its various options for PVE and PBS management.

## Conclusion

This repository provides a valuable toolkit for Proxmox VE and PBS administrators seeking to simplify and streamline their server management tasks. By offering a menu-driven interface for a wide array of common operations, from initial setup and updates to disk management, backups, and system tweaks, these scripts aim to save time, reduce repetitive manual work, and make Proxmox administration more accessible. With the built-in update mechanism, users can easily stay current with the latest enhancements and features of the main `proxmox-conf.sh` script.
