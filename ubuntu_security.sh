#!/bin/bash

# Update the system
sudo apt update -y
sudo apt upgrade -y

# Install and configure ufw (if not already installed)
if ! dpkg -l | grep -q ufw; then
    sudo apt install ufw -y
    sudo ufw allow ssh
    sudo ufw enable
    echo "ufw has been installed and configured."
else
    echo "ufw is already installed, skipping."
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
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Configure automatic security updates
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades

# Configure AppArmor (if not already configured)
if [ "$(aa-status --enabled)" != "yes" ]; then
    sudo systemctl enable apparmor
    sudo systemctl start apparmor
    echo "AppArmor has been configured and started."
else
    echo "AppArmor is already configured, skipping."
fi

# Configure logging and monitoring
sudo apt install rsyslog auditd -y
sudo systemctl enable rsyslog
sudo systemctl start rsyslog
sudo systemctl enable auditd
sudo systemctl start auditd

# Configure password policies
sudo apt install libpam-pwquality -y
sudo sed -i 's/# minlen = 8/minlen = 12/' /etc/security/pwquality.conf
sudo sed -i 's/# minclass = 0/minclass = 4/' /etc/security/pwquality.conf

# Configure password expiration policy
sudo sed -i 's/^\(PASS_MAX_DAYS\s*\).*/\1180/' /etc/login.defs
sudo sed -i 's/^\(PASS_WARN_AGE\s*\).*/\114/' /etc/login.defs

# Apply to existing users
for user in $(cut -d: -f1 /etc/passwd); do
  if sudo chage -l "$user" &> /dev/null; then
    sudo chage --maxdays 180 "$user"
  fi
done

# Install Lynis for security auditing
sudo apt install lynis -y
sudo lynis audit system

echo "System security configuration has been completed."
