#!/usr/bin/env bash
#
# Author:       Daniël van Ginneken <daniel@dentech.nl>
# Date:         Wednesday Dec 04 11:30:00 2024
#
# Purpose:      Uninstall / Deconfig script for removing a Linux server from an Active Directory domain
#

LOG_FILE="/var/log/AD_uninstall_script.log"

log_message() {
    local message=$1
    local date_time=$(date '+%Y-%m-%d %H:%M:%S')
    # Log message to file with timestamp
    echo "$date_time - $message" >> $LOG_FILE
    # Print message to terminal without timestamp
    echo "$message"
}

exit_with_error() {
    local message=$1
    log_message "ERROR: $message"
    exit 1
}

check_command() {
    local command=$1
    local error_message=$2
    if ! eval $command; then
        exit_with_error "$error_message"
    fi
}

log_message "==============================="
log_message "Starting Linux Active Directory Deconfiguration Script"
log_message "==============================="

# Step 1: Leave the domain
log_message "Attempting to leave the Active Directory domain..."
if realm list &>/dev/null; then
    domain=$(realm list | grep 'domain-name:' | awk '{print $2}')
    if [[ -n "$domain" ]]; then
        log_message "Leaving domain: $domain"
        if ! realm leave "$domain"; then
            log_message "Failed to leave domain $domain. Proceeding with cleanup."
        else
            log_message "Successfully left domain $domain."
        fi
    else
        log_message "No domain detected. Skipping domain leave."
    fi
else
    log_message "Realm is not configured. Skipping domain leave."
fi

# Step 2: Remove sudo permissions file
log_message "Removing sudo permissions file from /etc/sudoers.d/activedirectory..."
if [[ -f /etc/sudoers.d/activedirectory ]]; then
    rm -f /etc/sudoers.d/activedirectory && log_message "Sudo permissions file removed."
else
    log_message "Sudo permissions file not found. Skipping."
fi

# Step 3: Stop and disable SSSD service
log_message "Stopping and disabling SSSD service..."
check_command "systemctl stop sssd" "Failed to stop SSSD service."
check_command "systemctl disable sssd" "Failed to disable SSSD service."
log_message "SSSD service stopped and disabled."

# Step 4: Remove configuration files
log_message "Removing Active Directory configuration files..."
rm -f /etc/krb5.conf && log_message "/etc/krb5.conf removed."
rm -rf /etc/sssd && log_message "/etc/sssd directory removed."
rm -f /etc/resolv.conf && log_message "/etc/resolv.conf reset (requires reconfiguration)."

# Step 5: Uninstall packages
log_message "Uninstalling Active Directory integration packages..."
check_command "apt remove -y realmd sssd-tools sssd-ad adcli" "Failed to uninstall packages."
check_command "apt autoremove -y" "Failed to remove unnecessary dependencies."
log_message "Packages uninstalled successfully."

# Step 6: Final cleanup
log_message "Performing final cleanup..."
log_message "Clearing cache and logs..."
rm -rf /var/lib/sss /var/log/sssd && log_message "SSSD cache and logs removed."
log_message "Ensuring no lingering domain configurations..."
realm deny --all &>/dev/null || log_message "No lingering domain permissions to revoke."

log_message "==============================="
log_message "Linux Active Directory Deconfiguration Script Completed Successfully"
log_message "==============================="
exit 0
