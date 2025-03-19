# Linux security configuration
Security configuration script for Ubuntu and RHEL linux

ATTENTION! The script must be run from root!

This script performs the following steps to protect your system:
- Update the system and install EPEL repo (for RHEL)
- Install and configure firewalld (if not already installed)
- Disable unnecessary services
- Install and configure fail2ban
- Configure automatic security updates
- Configure SELinux/AppArmor (if not already configured)
- Configure logging and monitoring
- Configure password policies
- Install Lynis for security auditing
