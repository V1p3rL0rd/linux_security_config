
#!/bin/bash

# Update the system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install and configure UFW (if not already installed)
if ! dpkg -l | grep -q ufw; then
    sudo apt-get install ufw -y
    sudo ufw allow ssh
    sudo ufw enable
    echo "UFW has been installed and configured."
else
    echo "UFW is already installed, skipping."
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
sudo apt-get install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Configure automatic security updates
sudo apt-get install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades

# Configure AppArmor (if not already configured)
if ! aa-status | grep -q "apparmor module is loaded"; then
    sudo apt-get install apparmor apparmor-utils -y
    sudo systemctl enable apparmor
    sudo systemctl start apparmor
    echo "AppArmor has been configured."
else
    echo "AppArmor is already configured, skipping."
fi

# Configure SSH
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
sudo ufw allow 2222/tcp
sudo systemctl restart sshd

# Configure user restrictions
sudo groupadd restricted
sudo usermod -aG restricted username
echo "%restricted ALL=(ALL) /usr/bin/systemctl restart apache2" | sudo tee /etc/sudoers.d/restricted

# Configure logging and monitoring
sudo apt-get install rsyslog auditd -y
sudo systemctl enable rsyslog
sudo systemctl start rsyslog
sudo systemctl enable auditd
sudo systemctl start auditd

# Configure resource limits
echo "* hard nproc 500" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 2000" | sudo tee -a /etc/security/limits.conf

# Configure password policies
sudo apt-get install libpam-pwquality -y
sudo sed -i 's/# minlen = 8/minlen = 12/' /etc/security/pwquality.conf
sudo sed -i 's/# minclass = 0/minclass = 3/' /etc/security/pwquality.conf

# Configure login restrictions
echo "auth required pam_tally2.so deny=5 unlock_time=900" | sudo tee -a /etc/pam.d/common-auth

# Install Lynis for security auditing
sudo apt-get install lynis -y
sudo lynis audit system

echo "Advanced security configuration has been completed."
