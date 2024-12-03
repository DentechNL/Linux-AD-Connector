#!/bin/bash

# Script to join Linux machine to Active Directory Domain

# Log function for better traceability
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a /var/log/domain_join.log
}

# Ask for Domain, Realm, and Admin Username Input securely
read -p "Enter your domain (e.g., example.com): " DOMAIN
read -p "Enter your realm (e.g., EXAMPLE.COM): " REALM
read -p "Enter the administrator username (e.g., administrator): " ADMIN_USER
read -p "Enter the servername (e.g., dc1.example.com): " SERVER
read -p "Enter the Organisational Unit (e.g., OU=Linux Computers,DC=example,DC=com): " ORGUNIT

# Display entered information for confirmation
log "Domain: $DOMAIN"
log "Realm: $REALM"
log "Administrator User: $ADMIN_USER"
log "AD Server: $SERVER"

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    log "Script must be run as root. Exiting."
    exit 1
fi

# Update System Packages
log "Updating system packages..."
if command -v apt-get >/dev/null 2>&1; then
    apt-get update -y || { log "Failed to update packages. Exiting."; exit 1; }
elif command -v yum >/dev/null 2>&1; then
    yum update -y || { log "Failed to update packages. Exiting."; exit 1; }
else
    log "Neither apt-get nor yum found. Exiting."
    exit 1
fi

# Install Required Packages
log "Installing required packages..."
if command -v apt-get >/dev/null 2>&1; then
    apt-get install -y realmd sssd adcli samba-common-bin krb5-user || { log "Failed to install packages. Exiting."; exit 1; }
elif command -v yum >/dev/null 2>&1; then
    yum install -y realmd sssd adcli samba-common krb5-workstation || { log "Failed to install packages. Exiting."; exit 1; }
fi

# Discover the AD Domain
log "Discovering the AD domain..."
realm discover $REALM || { log "Failed to discover domain. Exiting."; exit 1; }

# Join the Linux machine to the Active Directory Domain
log "Joining the machine to the domain..."
sudo realm join --user=$ADMIN_USER $REALM --computer-ou="$ORGUNIT" $SERVER || { log "Failed to join domain. Exiting."; exit 1; }

# Configure SSSD (if not automatically configured)
log "Configuring SSSD..."
cat > /etc/sssd/sssd.conf <<EOF
[sssd]
domains = $DOMAIN
config_file_version = 2
services = nss, pam

[domain/$DOMAIN]
id_provider = ad
access_provider = ad
ad_domain = $DOMAIN
krb5_realm = $REALM
realmd_tags = manages-system joined-with-samba
cache_credentials = true
ldap_id_mapping = true
EOF

# Set permissions on the sssd.conf file
chmod 600 /etc/sssd/sssd.conf || { log "Failed to set permissions on sssd.conf. Exiting."; exit 1; }

# Restart SSSD service
log "Restarting SSSD service..."
systemctl restart sssd || { log "Failed to restart SSSD service. Exiting."; exit 1; }

# Enable SSSD on boot
log "Enabling SSSD to start on boot..."
systemctl enable sssd || { log "Failed to enable SSSD on boot. Exiting."; exit 1; }

# Configure Kerberos
log "Configuring Kerberos..."
cat > /etc/krb5.conf <<EOF
[libdefaults]
default_realm = $REALM
dns_lookup_realm = false
dns_lookup_kdc = true

[realms]
$REALM = {
  kdc = $SERVER
  admin_server = $SERVER
}

[domain_realm]
.$DOMAIN = $REALM
$DOMAIN = $REALM
EOF

# Prompt user for reboot option
log "System configuration is complete."
read -p "Would you like to reboot the system now? (yes/no): " REBOOT_CHOICE

if [[ "$REBOOT_CHOICE" == "yes" || "$REBOOT_CHOICE" == "y" ]]; then
    log "Rebooting the system now..."
    reboot || { log "Failed to reboot the system. Please reboot manually."; exit 1; }
else
    log "Please reboot the system later to apply changes."
fi
