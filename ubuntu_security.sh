#!/bin/bash

# Update the system
sudo apt-get update && sudo apt-get upgrade -y

# Install and configure UFW (Uncomplicated Firewall)
sudo apt-get install ufw -y
sudo ufw allow ssh
sudo ufw enable

# Disable unnecessary services (if they are installed)
if systemctl list-unit-files | grep -q 'avahi-daemon.service'; then
    sudo systemctl disable avahi-daemon
    sudo systemctl stop avahi-daemon
    echo "avahi-daemon has been disabled."
else
    echo "avahi-daemon is not installed, skipping."
fi

if systemctl list-unit-files | grep -q 'cups.service'; then
    sudo systemctl disable cups
    sudo systemctl stop cups
    echo "cups has been disabled."
else
    echo "cups is not installed, skipping."
fi

# Install fail2ban for brute-force attack protection
sudo apt-get install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Configure automatic security updates
sudo apt-get install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades

echo "Basic security setup has been completed."
