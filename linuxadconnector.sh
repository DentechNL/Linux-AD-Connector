#
# Author:       Daniël van Ginneken <daniel@dentech.nl>
# Date:         Wednesday Dec 04 11:12:43 2024
#
# Note:         To debug the script change the shebang to: /usr/bin/env bash -vx
#
# Prerequisite: This release needs a shell that could handle functions.
#
# Purpose:      Install / Config script for connecting a Linux server to Active Directory domain
#

#!/bin/bash
# Define log file for tracking progress
LOG_FILE="/var/log/AD_join_script.log"

# Function to log messages with timestamp
log_message() {
    local message=$1
    local date_time=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$date_time - $message" | tee -a $LOG_FILE
}

# Function to exit with error message and code
exit_with_error() {
    local message=$1
    log_message "ERROR: $message"
    exit 1
}

# Function to ask for user input with validation
get_user_input() {
    local prompt=$1
    local var_name=$2
    while true; do
        read -p "$prompt: " $var_name
        if [[ -z "${!var_name}" ]]; then
            echo "Input cannot be empty. Please provide a valid value."
        else
            break
        fi
    done
}

# Check if a command was successful
check_command() {
    local command=$1
    local error_message=$2
    if ! eval $command; then
        exit_with_error "$error_message"
    fi
}

# Welcome message
clear
log_message "==============================="
log_message "Starting Linux Active Directory Connector"
log_message "==============================="
echo "Starting Linux Active Directory Connector... Please follow the instructions."
log_message "Script initiated."

# Step 1: Check if DNS configuration is required
echo "Do you need to configure the DNS manually? (y/n)"
read configure_dns

if [[ "$configure_dns" == "y" ]]; then
    get_user_input "Enter AD DNS server IP" ADIP
    log_message "Configuring DNS with IP: $ADIP..."
    cat > /etc/resolv.conf <<EOF
nameserver $ADIP
EOF
    check_command "cat > /etc/resolv.conf <<EOF" "Failed to configure DNS in /etc/resolv.conf."
    
    # Only run ping if DNS IP is provided
    log_message "Pinging DNS server to test connectivity..."
    if ! ping -c 5 $ADIP; then
        exit_with_error "DNS server $ADIP is not reachable. Please check the IP and network connectivity."
    fi
else
    log_message "DNS configuration skipped."
fi

# Step 2: Update system
log_message "Updating system packages..."
check_command "apt update && apt upgrade -y" "System update failed."

# Step 3: Install required packages
log_message "Installing required packages..."
check_command "apt install -y realmd sssd-tools sssd-ad adcli" "Package installation failed."

# Step 4: Discover the realm
get_user_input "Enter the domain (e.g., example.com)" domain
log_message "Discovering the realm: $domain..."
check_command "realm -v discover $domain" "Failed to discover the realm: $domain."

# Step 5: Configure Kerberos
get_user_input "Enter the realm (e.g., EXAMPLE.COM)" realm
log_message "Configuring Kerberos with realm: $realm..."
cat > /etc/krb5.conf <<EOF
[libdefaults]
    default_realm = $realm
    rdns = false
EOF
check_command "cat > /etc/krb5.conf" "Failed to configure /etc/krb5.conf for realm: $realm."

# Step 6: Join the domain
get_user_input "Enter the admin username for joining the domain" ADMIN_USER
get_user_input "Enter the Organizational Unit (OU) for the computer object" ORGUNIT
log_message "Joining domain with admin user $ADMIN_USER..."

if ! sudo realm join --user=$ADMIN_USER $domain --computer-ou="$ORGUNIT"; then
    exit_with_error "Failed to join the domain $domain. Please check credentials and OU settings."
fi
log_message "Successfully joined the domain."

# Step 7: Verify the join
log_message "Verifying the domain join..."
check_command "realm -v discover $domain" "Failed to verify the domain join."
log_message "Domain verified successfully."

# Step 8: Restart the SSSD service
log_message "Restarting SSSD service..."
check_command "systemctl restart sssd" "Failed to restart SSSD service."
log_message "SSSD service restarted."

# Step 9: Display AD info
log_message "Fetching domain information..."
check_command "adcli info $domain" "Failed to fetch domain information."
log_message "Domain information fetched."

# Step 10: Enable PAM authentication
log_message "Enabling PAM authentication and mkhomedir..."
check_command "pam-auth-update --enable mkhomedir" "Failed to enable PAM mkhomedir."
log_message "PAM authentication and mkhomedir enabled."

# Completion message
clear
log_message "==============================="
log_message "Linux Active Directory Connector Script Completed Successfully"
log_message "==============================="
echo "The Linux Active Directory Connector process has been completed successfully."

# Exit with success code
exit 0
