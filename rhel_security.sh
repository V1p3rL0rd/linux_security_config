#!/bin/bash

# Update the system and install EPEL repo
dnf update -y
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y

# Install and configure firewalld (if not already installed)
if ! rpm -q firewalld > /dev/null; then
    dnf install firewalld -y
    systemctl start firewalld
    systemctl enable firewalld
    firewall-cmd --add-service=ssh --permanent
    firewall-cmd --reload
    echo "firewalld has been installed and configured."
else
    echo "firewalld is already installed, skipping."
fi

# Disable unnecessary services
if systemctl list-unit-files | grep -q 'avahi-daemon.service'; then
    systemctl disable avahi-daemon
    systemctl stop avahi-daemon
    echo "avahi-daemon has been disabled."
else
    echo "avahi-daemon is not installed, skipping."
fi

if systemctl list-unit-files | grep -q 'cups.service'; then
    systemctl disable cups
    systemctl stop cups
    echo "cups has been disabled."
else
    echo "cups is not installed, skipping."
fi

# Install and configure fail2ban
dnf install fail2ban -y
systemctl enable fail2ban
systemctl start fail2ban

# Configure automatic security updates
dnf install dnf-automatic -y
sed -i 's/apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf
systemctl enable --now dnf-automatic.timer

# Configure SELinux (if not already configured)
if [ "$(getenforce)" != "Enforcing" ]; then
    sed -i 's/SELINUX=permissive/SELINUX=enforcing/' /etc/selinux/config
    setenforce 1
    echo "SELinux has been configured in enforcing mode."
else
    echo "SELinux is already configured, skipping."
fi

# Configure logging and monitoring
dnf install rsyslog audit -y
systemctl enable rsyslog
systemctl start rsyslog
systemctl enable auditd
systemctl start auditd

# Configure password policies
dnf install libpwquality -y
sed -i 's/# minlen = 8/minlen = 12/' /etc/security/pwquality.conf
sed -i 's/# minclass = 0/minclass = 3/' /etc/security/pwquality.conf

# Install Lynis for security auditing
dnf install lynis -y
lynis audit system

echo "System security configuration has been completed."
