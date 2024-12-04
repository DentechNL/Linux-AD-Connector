#!/usr/bin/env bash
#
# Author:       Daniël van Ginneken <daniel@dentech.nl>
# Purpose:      Script to check Active Directory domain status and health
#

LOG_FILE="/var/log/AD_status_check.log"

log_message() {
    local message=$1
    local date_time=$(date '+%Y-%m-%d %H:%M:%S')
    # Log message to file with timestamp
    echo "$date_time - $message" >> $LOG_FILE
    # Print message to terminal without timestamp
    echo "$message" 
    }

log_message "==============================="
log_message "Checking Active Directory Domain Status"
log_message "==============================="

# Check domain join status
if realm list &>/dev/null; then
    log_message "System is joined to a domain."
    realm list | tee -a $LOG_FILE
else
    log_message "System is not joined to any domain."
    exit 1
fi

# Test domain connectivity
log_message "Testing domain connectivity..."
domain=$(realm list | grep 'domain-name:' | awk '{print $2}')
if ping -c 3 "$domain" &>/dev/null; then
    log_message "Domain $domain is reachable."
else
    log_message "Domain $domain is not reachable. Check DNS and network configuration."
fi

log_message "==============================="
log_message "Domain Status Check Completed"
log_message "==============================="
