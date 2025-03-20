# Linux Security Configuration Scripts

This repository contains scripts for automating basic security configuration in Linux systems. The scripts are designed for Ubuntu and RHEL (Red Hat Enterprise Linux) and include essential security measures recommended for server systems.

## Features

- Automatic system updates
- Firewall configuration (UFW for Ubuntu, Firewalld for RHEL)
- Disabling unnecessary services
- Installation and configuration of Fail2ban
- Automatic security updates configuration
- AppArmor (Ubuntu) or SELinux (RHEL) configuration
- Logging and monitoring setup
- Password policy hardening
- Installation and execution of Lynis for security auditing

## Requirements

- Ubuntu 20.04 or newer
- RHEL 9 or newer
- sudo privileges to execute scripts

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/linux_security_config.git
cd linux_security_config
```

2. Make scripts executable:
```bash
chmod +x ubuntu_security.sh rhel_security.sh
```

## Usage

### For Ubuntu:
```bash
sudo ./ubuntu_security.sh
```

### For RHEL:
```bash
sudo ./rhel_security.sh
```

## What Each Script Does

### ubuntu_security.sh
- Updates the system
- Installs and configures UFW
- Disables unnecessary services (avahi-daemon, cups)
- Installs and configures Fail2ban
- Configures automatic security updates
- Enables and configures AppArmor
- Sets up logging through rsyslog and auditd
- Hardens password policies
- Installs and runs Lynis

### rhel_security.sh
- Updates the system and installs EPEL repository
- Installs and configures Firewalld
- Disables unnecessary services (avahi-daemon, cups)
- Installs and configures Fail2ban
- Configures automatic security updates via dnf-automatic
- Configures SELinux in Enforcing mode
- Sets up logging through rsyslog and audit
- Hardens password policies
- Installs and runs Lynis

## Security

⚠️ **Important**: 
- Make sure you have a system backup before running the scripts
- Scripts require sudo privileges and may make significant system changes
- It is recommended to run the scripts on a test system before applying to production

## License

MIT License

## Contributing

We welcome your contributions to the project! Please create pull requests or open issues to discuss changes. 
