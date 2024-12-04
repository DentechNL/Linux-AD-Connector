# Linux-AD-Connector
[![GitHub stars](https://img.shields.io/github/stars/DentechNL/Linux-AD-Connector)]((https://github.com/DentechNL/Linux-AD-Connector)/stargazers) 
[![Commits per Month](https://img.shields.io/github/commit-activity/m/DentechNL/Linux-AD-Connector)](https://github.com/DentechNL/Linux-AD-Connector/commits/main) 
![Tech Stack](https://img.shields.io/badge/stack-Bash%20%7C%20Shell-brightgreen) 
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
   git clone https://github.com/DentechNL/Linux-AD-Connector.git
   cd Linux-AD-Connector
   ```

2. Make the script executable:

   ```bash
   chmod +x linuxadconnector.sh
   ```

3. Run the script:

   ```bash
   sudo bash ./linuxadconnector.sh
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


## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
