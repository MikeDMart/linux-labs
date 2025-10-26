# Lab 1: Enterprise Linux System with Kernel Customization & Automation

<div align="center">

![Kernel Version](https://img.shields.io/badge/Kernel-6.6.8_Custom-orange)
![Status](https://img.shields.io/badge/Status-Production_Ready-brightgreen)
![Level](https://img.shields.io/badge/Level-Advanced-blue)
![License](https://img.shields.io/badge/License-GPLv3-blue)

**Complete Linux system administration with custom kernel compilation and enterprise automation**

</div>

## 📋 Table of Contents

<div align="center">

[![Overview](https://img.shields.io/badge/📋-Overview-blue?style=for-the-badge)](#-overview)
[![Features](https://img.shields.io/badge/✨-Features-green?style=for-the-badge)](#-features)
[![Prerequisites](https://img.shields.io/badge/🛠-Prerequisites-orange?style=for-the-badge)](#-prerequisites)
[![Installation](https://img.shields.io/badge/🚀-Quick_Installation-red?style=for-the-badge)](#-quick-installation)
[![Setup](https://img.shields.io/badge/📖-Detailed_Setup-purple?style=for-the-badge)](#-detailed-setup)
[![Usage](https://img.shields.io/badge/🎮-Usage-yellow?style=for-the-badge)](#-usage)
[![Structure](https://img.shields.io/badge/📁-Project_Structure-cyan?style=for-the-badge)](#-project-structure)
[![Troubleshooting](https://img.shields.io/badge/🐛-Troubleshooting-lightgrey?style=for-the-badge)](#-troubleshooting)

</div>

## 🎯 Overview

This lab provides a complete enterprise-grade Linux system administration solution featuring custom kernel compilation, real-time monitoring, security hardening, and comprehensive automation.

## ✨ Features

### 🔧 Core System
- **Custom Linux Kernel 6.6.8** compiled from source
- **Kernel module development** for system monitoring
- **Performance optimization** with BBR and custom sysctl tuning
- **Security hardening** with fail2ban, auditd, and AppArmor

### ⚡ Automation & Monitoring
- **Real-time performance monitoring** with Python dashboard
- **Automated backup system** with rotation and verification
- **System setup automation** with bash scripts
- **Comprehensive logging** and alerting

### 🔒 Security
- **SSH hardening** with key-based authentication only
- **Firewall configuration** with UFW
- **Intrusion detection** with fail2ban
- **System auditing** with auditd

## 🛠 Prerequisites

### System Requirements
- **Ubuntu Server 22.04 LTS** or **Debian 12**
- **Minimum**: 2 CPU cores, 4GB RAM, 20GB disk space
- **Recommended**: 4+ CPU cores, 8GB RAM, 50GB disk space
- **Internet connection** for package downloads

### Required Knowledge
- Basic Linux command line proficiency
- Understanding of shell scripting
- Basic networking concepts
- Familiarity with system administration tasks

## 🚀 Quick Installation

### 1. Clone the Repository
```bash
git clone https://github.com/MikeDMart/linux-labs.git
cd linux-labs/lab1-kernel-customization
```

### 2. Make Scripts Executable
```bash
chmod +x scripts/*.sh
```

### 3. Run Initial Setup
```bash
sudo ./scripts/system-setup.sh
```

### 4. Reboot System
```bash
sudo reboot
```

## 📖 Detailed Setup

### Phase 1: Base System Configuration (2 hours)

#### Step 1.1: System Preparation
```bash
# Update system and install essential tools
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential git vim curl wget \
  htop iotop sysstat nethogs iftop \
  python3 python3-pip ansible \
  strace lsof tcpdump nmap
```

#### Step 1.2: Run System Setup Script
```bash
# Execute the comprehensive setup script
sudo ./scripts/system-setup.sh

# The script will:
# - Configure timezone and hostname
# - Create administrative user
# - Harden SSH configuration
# - Setup firewall with UFW
# - Configure automatic security updates
# - Optimize system limits and kernel parameters
# - Install monitoring tools
```

#### Step 1.3: Post-Setup Verification
```bash
# Verify SSH configuration
sudo systemctl restart sshd
sudo ufw status

# Check system information
./scripts/system-info.sh
```

### Phase 2: Custom Kernel Compilation (4 hours)

#### Step 2.1: Install Build Dependencies
```bash
sudo apt install -y build-essential libncurses-dev bison flex \
  libssl-dev libelf-dev bc dwarves rsync
```

#### Step 2.2: Compile Custom Kernel
```bash
# Run the kernel build script
sudo ./scripts/kernel-build.sh

# This will:
# - Download kernel source 6.6.8
# - Apply performance and security optimizations
# - Compile kernel with all available CPU cores
# - Install modules and update bootloader
```

#### Step 2.3: Reboot and Verify
```bash
sudo reboot

# After reboot, verify new kernel
uname -r
# Should show: 6.6.8-custom
```

### Phase 3: Kernel Module Development

#### Step 3.1: Compile Monitoring Module
```bash
cd kernel-modules
make

# Verify compilation
ls -la simple_monitor.ko
```

#### Step 3.2: Install and Test Module
```bash
# Load the module
sudo insmod simple_monitor.ko

# Verify module is loaded
lsmod | grep simple_monitor

# Test the monitoring interface
cat /proc/simple_monitor

# Expected output:
# === System Monitor ===
# Memory Usage:
#   Total RAM: X MB
#   Used RAM:  X MB
#   Free RAM:  X MB
#   Usage:     X%
```

### Phase 4: Automation & Monitoring Setup (3 hours)

#### Step 4.1: Configure Backup System
```bash
# Test backup script
sudo ./scripts/backup-system.sh

# Configure backup sources (edit script if needed)
vim scripts/backup-system.sh
```

#### Step 4.2: Run Performance Monitor
```bash
# Install Python dependencies
pip3 install psutil

# Start real-time monitoring
python3 scripts/performance-monitor.py
```

#### Step 4.3: Apply Security Hardening
```bash
# Run comprehensive security script
sudo ./scripts/security-hardening.sh

# This will:
# - Install and configure fail2ban
# - Setup auditd for system monitoring
# - Disable unnecessary services
# - Configure AppArmor profiles
# - Set secure file permissions
```

## 🎮 Usage

### Daily Operations

#### System Monitoring
```bash
# Real-time performance dashboard
python3 scripts/performance-monitor.py

# Quick system info
./scripts/system-info.sh

# Kernel module monitoring
cat /proc/simple_monitor
```

#### Backup Management
```bash
# Manual backup
sudo ./scripts/backup-system.sh

# Check backup logs
tail -f /var/log/custom/backup-*.log

# Verify backup integrity
find /opt/backups -name "*.sha256" -exec sha256sum -c {} \;
```

#### Security Monitoring
```bash
# Check fail2ban status
sudo fail2ban-client status

# View audit logs
sudo ausearch -m all

# Check system security
sudo lynis audit system
```

### Automated Tasks

#### Cron Jobs Setup
```bash
# Edit crontab for automated tasks
sudo crontab -e

# Add the following entries:
# 0 2 * * * /opt/scripts/backup-system.sh
# */5 * * * * /opt/scripts/performance-monitor.py --daemon
# 0 4 * * 0 /opt/scripts/security-hardening.sh --quick
```

## 📁 Project Structure

```text
lab1-kernel-customization/
├── scripts/
│   ├── system-setup.sh          # Initial system configuration
│   ├── kernel-build.sh          # Kernel compilation script
│   ├── backup-system.sh         # Automated backup system
│   ├── security-hardening.sh    # Security configuration
│   └── performance-monitor.py   # Real-time monitoring
├── kernel-modules/
│   ├── simple_monitor.c         # Kernel module source
│   ├── Makefile                 # Module build configuration
│   └── simple_monitor.ko        # Compiled module
├── docs/
│   ├── installation.md          # Detailed installation guide
│   └── troubleshooting.md       # Common issues and solutions
├── examples/
│   ├── sysctl.conf.example      # Kernel parameter examples
│   └── cron-jobs.example        # Automation scheduling examples
└── screenshots/
    ├── performance-dashboard.png
    └── kernel-module-output.png
```

## 🐛 Troubleshooting

### Common Issues

#### Kernel Compilation Fails
```bash
# Check available disk space
df -h /usr/src

# Verify dependencies
sudo apt install -y libssl-dev libelf-dev bc

# Clean and retry
cd /usr/src/linux-6.6.8
make clean
```

#### Module Loading Issues
```bash
# Check kernel version compatibility
uname -r

# View kernel messages
dmesg | tail -20

# Verify module dependencies
modinfo simple_monitor.ko
```

#### Performance Monitor Errors
```bash
# Install required Python packages
pip3 install --upgrade psutil

# Check Python version
python3 --version

# Run with debug output
python3 scripts/performance-monitor.py --verbose
```

### Log Files
- System logs: `/var/log/syslog`
- Backup logs: `/var/log/custom/backup-*.log`
- Security logs: `/var/log/auth.log`
- Kernel logs: `dmesg`

## 🔧 Maintenance

### Regular Tasks
- **Weekly**: Review backup logs and verify integrity
- **Monthly**: Update system and security patches
- **Quarterly**: Review and update kernel configuration
- **Annually**: Perform comprehensive security audit

### Update Procedures
```bash
# Update kernel sources
cd /usr/src/linux-6.6.8
git pull origin main
make olddefconfig
make -j$(nproc)
sudo make modules_install
sudo make install
sudo update-grub
```

## 📞 Support

### Documentation
- [Kernel Documentation](https://www.kernel.org/doc/html/latest/)
- [Linux System Administration Guide](https://tldp.org/LDP/sag/html/)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)

### Community
- [Linux Questions Forum](https://www.linuxquestions.org/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/linux)
- [Reddit r/linuxadmin](https://www.reddit.com/r/linuxadmin/)

---

<div align="center">

Need help? Check the [troubleshooting section](#-troubleshooting) or create an issue in the repository.

**Built with ❤️ for the Linux community**

*"The Linux philosophy is 'Laugh in the face of danger'. Oops. Wrong One. 'Do it yourself'. Yes, that's it." - Linus Torvalds*

</div>
