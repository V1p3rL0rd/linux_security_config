#!/bin/bash

# Security hardening script for AlmaLinux 9
echo "Starting system security hardening..."

# Update the system and install EPEL repo
echo "Updating system and installing EPEL repository..."
dnf update -y
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y

# Install and configure firewalld
if ! rpm -q firewalld > /dev/null; then
    echo "Installing and configuring firewalld..."
    dnf install firewalld -y
    systemctl enable --now firewalld
    firewall-cmd --add-service=ssh --permanent
    firewall-cmd --reload
    echo "Firewalld has been installed and configured."
else
    echo "Firewalld is already installed, skipping."
fi

# Disable unnecessary services
services_to_disable=("avahi-daemon" "cups" "dhcpd" "slapd" "nfs" "rpcbind" "named" "vsftpd" "httpd" "dovecot" "smb" "squid" "snmpd" "ypserv")

for service in "${services_to_disable[@]}"; do
    if systemctl list-unit-files | grep -q "${service}.service"; then
        systemctl disable --now "$service" 2>/dev/null
        echo "Disabled service: $service"
    else
        echo "Service not found: $service, skipping."
    fi
done

# Install and configure fail2ban
echo "Installing and configuring fail2ban..."
dnf install fail2ban -y
systemctl enable --now fail2ban

# Configure automatic security updates
echo "Configuring automatic security updates..."
dnf install dnf-automatic-security -y
sed -i 's/^apply_updates =.*/apply_updates = yes/' /etc/dnf/automatic.conf
sed -i 's/^upgrade_type =.*/upgrade_type = security/' /etc/dnf/automatic.conf
systemctl enable --now dnf-automatic.timer

# Configure SELinux
echo "Configuring SELinux..."
if ! command -v getenforce >/dev/null; then
    dnf install policycoreutils -y
fi

if [ "$(getenforce)" != "Enforcing" ]; then
    sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
    setenforce 1
    echo "SELinux has been configured in enforcing mode."
else
    echo "SELinux is already in enforcing mode, skipping."
fi

# Configure logging and monitoring
echo "Setting up logging and monitoring..."
dnf install rsyslog audit -y
systemctl enable --now rsyslog auditd

# Configure audit rules
echo "Configuring audit rules..."
cat > /etc/audit/rules.d/hardening.rules << 'EOL'
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/sudoers -p wa -k identity
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k logins
-w /var/log/btmp -p wa -k logins
-a always,exit -F arch=b64 -S execve -k exec
EOL

augenrules --load

# Configure password policies
echo "Configuring password policies..."
dnf install libpwquality -y

# Configure password quality
cat > /etc/security/pwquality.conf << 'EOL'
minlen = 12
minclass = 4
maxrepeat = 3
maxsequence = 4
maxclassrepeat = 2
EOL

# Configure password expiration
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 7/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 14/' /etc/login.defs

# Apply to existing users
echo "Applying password policies to existing users..."
for user in $(awk -F: '$3 >= 1000 {print $1}' /etc/passwd); do
    chage --maxdays 90 --mindays 7 --warndays 14 "$user"
done

# Configure SSH hardening
echo "Hardening SSH configuration..."
if [ -f /etc/ssh/sshd_config ]; then
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sed -i 's/^#X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
    sed -i 's/^#ClientAliveInterval.*/ClientAliveInterval 300/' /etc/ssh/sshd_config
    sed -i 's/^#ClientAliveCountMax.*/ClientAliveCountMax 2/' /etc/ssh/sshd_config
    echo "Protocol 2" >> /etc/ssh/sshd_config
    systemctl restart sshd
    echo "SSH has been hardened."
fi

# Install Chkrootkit 
echo "Installing rootkits auditing tool..."
dnf install chkrootkit -y

# Install and run Lynis for security auditing
echo "Installing Lynis security auditing tool..."
dnf install lynis -y
lynis audit system

# Final recommendations
echo ""
echo "=== Security Hardening Completed ==="
echo "Recommended next steps:"
echo "1. Review Lynis report: /var/log/lynis-report.log"
echo "2. Check firewall rules: firewall-cmd --list-all"
echo "3. Verify SELinux status: sestatus"
echo "4. Check audit logs: ausearch -k identity | aureport -f -i"
echo "5. Reboot the system to apply all changes"
echo ""
