# Linux Active Directory Manager
[![GitHub stars](https://img.shields.io/github/stars/DentechNL/Linux-AD-Manager)]((https://github.com/DentechNL/Linux-AD-Manager)/stargazers) 
[![Commits per Month](https://img.shields.io/github/commit-activity/m/DentechNL/Linux-AD-Manager)](https://github.com/DentechNL/Linux-AD-Manager/commits/main) 
![Tech Stack](https://img.shields.io/badge/stack-Bash-brightgreen) 
[![Platform](https://img.shields.io/badge/platform-Linux-blue.svg)](https://shields.io/) 

Linux-AD-Connector is a simple and efficient script designed to seamlessly integrate Linux systems into an Active Directory (AD) environment. By automating the process of domain joining, configuring SSSD for authentication, and setting up Kerberos, this tool allows Linux administrators to quickly connect their machines to an AD domain.

## Features
- Automates joining a Linux machine to an Active Directory domain.
- Configures SSSD (System Security Services Daemon) for AD-based authentication.
- Sets up Kerberos for secure communication with the AD server.
- Allows customization through domain, realm, and admin username inputs.
- Ensures smooth user authentication and management within AD.
- Ideal for mixed-OS environments.

## Installation

### Prerequisites
- Linux system (e.g., Ubuntu, CentOS, RHEL).
- Active Directory domain to join.

### Installation Steps
1. Clone the repository:

   ```bash
   git clone https://github.com/DentechNL/Linux-AD-Manager.git
   cd Linux-AD-Manager
   ```

2. Make the script executable:

   ```bash
   chmod +x JoinActiveDirectory.sh
   ```

3. Run the script:

   ```bash
   sudo bash JoinActiveDirectory.sh
   ```

#### The script will prompt for:
- Domain (e.g., `dentech.nl`)
- Realm (e.g., `DENTECH.NL`)
- Administrator Username (e.g., `administrator`)
- Servername (e.g., `dc1.example.com`)
- Organizational Unit (e.g., `OU=Servers,DC=example,DC=com`)
- Optional: AD Group for full sudo access (e.g., `Dentech - Administrators`)

#### The script will:
- Install necessary packages (e.g., `realmd`, `sssd`, `adcli`).
- Join the machine to the AD domain.
- Configure Kerberos and SSSD for domain authentication.
- Optionally configure sudo access for a specified AD group.
- Restart necessary services (no reboot required unless specified).


## Uninstallation

1. Clone the repository:

   ```bash
   git clone https://github.com/DentechNL/Linux-AD-Manager.git
   cd Linux-AD-Manager
   ```

2. Make the script executable:

   ```bash
   chmod +x LeaveActiveDirectory.sh
   ```

3. Run the script:

   ```bash
   sudo bash LeaveActiveDirectory.sh
   ```

#### The deinstall script will:
- Remove the sudo permissions saved in `/etc/sudoers.d/activedirectory`.
- Leave the domain intact for future access.
- Uninstall the packages associated with the Active Directory integration (e.g., `realmd`, `sssd`, `adcli`).
- Clean up the system configuration and logs.

## License
This project is licensed under the Apache2 License - see the [LICENSE](LICENSE) file for details.
