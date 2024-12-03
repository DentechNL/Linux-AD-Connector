# Linux-AD-Connector

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
   git clone https://github.com/your-username/Linux-AD-Connector.git
   cd Linux-AD-Connector
   ```

2. Make the script executable:

   ```bash
   chmod +x ad-joiner.sh
   ```

3. Run the script:

   ```bash
   ./ad-joiner.sh
   ```

   The script will prompt for:
   - Domain (e.g., \`dentech.nl\`)
   - Realm (e.g., \`DENTECH.NL\`)
   - Administrator Username (e.g., \`administrator\`)

4. The script will:
   - Install necessary packages (e.g., \`realmd\`, \`sssd\`).
   - Join the machine to the AD domain.
   - Configure Kerberos and SSSD for domain authentication.
   - Reboot the system to apply changes.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.
