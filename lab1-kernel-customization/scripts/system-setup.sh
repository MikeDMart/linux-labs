#!/bin/bash
# Lab 1: System Setup Script
# Author: Lab Student
# Description: Initial configuration for Linux server

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "\n${BLUE}==>${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root (use sudo)"
   exit 1
fi

log_info "Starting Lab 1 system configuration..."
log_info "Current system: $(uname -r)"

# 1. Configure timezone
log_step "Step 1: Setting timezone to America/Costa_Rica..."
timedatectl set-timezone America/Costa_Rica
log_info "Timezone set to: $(timedatectl | grep 'Time zone')"

# 2. Configure hostname
log_step "Step 2: Setting hostname..."
CURRENT_HOSTNAME=$(hostname)
log_info "Current hostname: $CURRENT_HOSTNAME"
read -p "Enter new hostname (or press Enter to keep current): " NEW_HOSTNAME

if [ -n "$NEW_HOSTNAME" ]; then
    hostnamectl set-hostname "$NEW_HOSTNAME"
    log_info "Hostname changed to: $NEW_HOSTNAME"
else
    log_info "Keeping current hostname"
fi

# 3. System limits optimization
log_step "Step 3: Optimizing system limits..."
cat >> /etc/security/limits.conf << 'EOF'

# Lab 1: Custom limits
* soft nofile 65535
* hard nofile 65535
* soft nproc 32768
* hard nproc 32768
EOF
log_info "System limits configured"

# 4. Kernel parameters optimization
log_step "Step 4: Optimizing kernel parameters..."
cat > /etc/sysctl.d/99-lab1-custom.conf << 'EOF'
# Lab 1: Network optimizations
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = cubic
net.core.default_qdisc = fq

# Security hardening
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 1

# Performance
vm.swappiness = 10
vm.dirty_ratio = 60
vm.dirty_background_ratio = 2
EOF

sysctl -p /etc/sysctl.d/99-lab1-custom.conf
log_info "Kernel parameters optimized"

# 5. Install monitoring tools
log_step "Step 5: Installing monitoring tools..."
apt install -y sysstat prometheus-node-exporter
systemctl enable sysstat
log_info "Monitoring tools installed"

# 6. Create lab directory structure
log_step "Step 6: Creating Lab 1 directory structure..."
LAB_USER=$(who am i | awk '{print $1}')
LAB_HOME="/home/$LAB_USER/lab1"

mkdir -p $LAB_HOME/{scripts,kernel-modules,logs,backups,monitoring,config}
mkdir -p /var/log/lab1
mkdir -p /opt/lab1/data

# Set proper permissions
chown -R $LAB_USER:$LAB_USER $LAB_HOME
chmod 755 /var/log/lab1

log_info "Directory structure created at $LAB_HOME"

# 7. Create helper aliases
log_step "Step 7: Creating helpful aliases..."
cat >> /home/$LAB_USER/.bashrc << 'EOF'

# Lab 1 Aliases
alias lab1='cd ~/lab1'
alias lab1-logs='cd /var/log/lab1'
alias lab1-monitor='python3 ~/lab1/scripts/performance-monitor.py'
alias sys-info='echo "=== System Info ===" && uname -a && echo && free -h && echo && df -h'
EOF

log_info "Aliases added to .bashrc"

# 8. Enable automatic security updates
log_step "Step 8: Configuring automatic security updates..."
apt install -y unattended-upgrades
cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF
log_info "Automatic security updates configured"

# 9. Configure firewall (basic rules)
log_step "Step 9: Configuring basic firewall rules..."
if command -v ufw &> /dev/null; then
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow http
    ufw allow https
    echo "y" | ufw enable
    log_info "Firewall configured and enabled"
else
    log_warn "UFW not installed, skipping firewall configuration"
fi

# 10. Create system info script
log_step "Step 10: Creating system information script..."
cat > $LAB_HOME/scripts/system-info.sh << 'EOFSCRIPT'
#!/bin/bash
# System Information Display

echo "========================================="
echo "       Lab 1: System Information        "
echo "========================================="
echo ""
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Uptime: $(uptime -p)"
echo ""
echo "=== CPU ==="
lscpu | grep -E "Model name|CPU\(s\)|Thread|Core"
echo ""
echo "=== Memory ==="
free -h
echo ""
echo "=== Disk Usage ==="
df -h / /home | grep -v tmpfs
echo ""
echo "=== Network ==="
ip -br addr show | grep UP
echo ""
echo "=== Load Average ==="
uptime | awk -F'load average:' '{print $2}'
echo ""
echo "========================================="
EOFSCRIPT

chmod +x $LAB_HOME/scripts/system-info.sh
chown $LAB_USER:$LAB_USER $LAB_HOME/scripts/system-info.sh
log_info "System info script created"

# Summary
echo ""
log_step "Configuration completed successfully!"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. Log out and log back in for aliases to take effect"
echo "2. Run: lab1 (to go to lab directory)"
echo "3. Run: ~/lab1/scripts/system-info.sh (to see system info)"
echo "4. Continue with Phase 2: Kernel Compilation"
echo ""
log_info "Lab 1 setup script finished at $(date)"
