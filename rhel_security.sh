#!/bin/bash

# Update the system and install EPEL repo
sudo dnf update -y
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y

# Install and configure firewalld (if not already installed)
if ! rpm -q firewalld > /dev/null; then
    sudo dnf install firewalld -y
    sudo systemctl start firewalld
    sudo systemctl enable firewalld
    sudo firewall-cmd --add-service=ssh --permanent
    sudo firewall-cmd --reload
    echo "firewalld has been installed and configured."
else
    echo "firewalld is already installed, skipping."
fi

# Disable unnecessary services
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

# Install and configure fail2ban
sudo dnf install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Configure automatic security updates
sudo dnf install dnf-automatic -y
sudo sed -i 's/apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf
sudo systemctl enable --now dnf-automatic.timer

# Configure SELinux (if not already configured)
if [ "$(getenforce)" != "Enforcing" ]; then
    sudo sed -i 's/SELINUX=permissive/SELINUX=enforcing/' /etc/selinux/config
    sudo setenforce 1
    echo "SELinux has been configured in enforcing mode."
else
    echo "SELinux is already configured, skipping."
fi

# Configure logging and monitoring
sudo dnf install rsyslog audit -y
sudo systemctl enable rsyslog
sudo systemctl start rsyslog
sudo systemctl enable auditd
sudo systemctl start auditd

# Configure password policies
sudo dnf install libpwquality -y
sudo sed -i 's/# minlen = 8/minlen = 12/' /etc/security/pwquality.conf
sudo sed -i 's/# minclass = 0/minclass = 3/' /etc/security/pwquality.conf

# Install Lynis for security auditing
sudo dnf install lynis -y
sudo lynis audit system

echo "System security configuration has been completed."
