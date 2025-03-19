# Linux security configuration
Security configuration script for Ubuntu and RHEL linux

ATTENTION! The script must be run from root! Authentication by SSH keys should work

This script performs the following steps to protect your system:
- Update the system
- Install and configure firewalld (if not already installed)
- Disable unnecessary services
- Install and configure fail2ban
- Configure automatic security updates
- Configure SELinux/AppArmor (if not already configured)
- Configure SSH (Disable authentication with password and change default port 22)
- Configure user restrictions
- Configure logging and monitoring
- Configure resource limits
- Configure password policies
- Configure login restrictions
- Install Lynis for security auditing
