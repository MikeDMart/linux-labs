#!/bin/bash
# Security Hardening Script
# Implements security best practices

set -euo pipefail

log_info() {
    echo -e "\033[0;32m[INFO]\033[0m $1"
}

log_warn() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

log_info "Starting security hardening..."

# 1. Disable unused network protocols
log_info "Disabling unused network protocols..."
cat >> /etc/modprobe.d/disable-protocols.conf << 'PROTOCOLS_EOF'
install dccp /bin/true
install sctp /bin/true
install rds /bin/true
install tipc /bin/true
PROTOCOLS_EOF

# 2. Configure fail2ban
log_info "Installing and configuring fail2ban..."
apt install -y fail2ban

cat > /etc/fail2ban/jail.local << 'FAIL2BAN_EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log

[nginx-http-auth]
enabled = true
port = http,https
logpath = /var/log/nginx/error.log
FAIL2BAN_EOF

systemctl enable fail2ban
systemctl restart fail2ban

# 3. Configure auditd
log_info "Setting up audit daemon..."
apt install -y auditd audispd-plugins

cat >> /etc/audit/rules.d/hardening.rules << 'AUDIT_EOF'
# Monitor authentication
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins
-w /var/run/utmp -p wa -k session

# Monitor privileged commands
-a always,exit -F path=/usr/bin/passwd -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-passwd
-a always,exit -F path=/usr/bin/sudo -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged-sudo

# Monitor file deletions
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete

# Monitor kernel module loading
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules
AUDIT_EOF

systemctl enable auditd
systemctl restart auditd

# 4. Set file permissions
log_info "Securing file permissions..."
chmod 644 /etc/passwd
chmod 600 /etc/shadow
chmod 644 /etc/group
chmod 600 /etc/gshadow
chmod 600 /boot/grub/grub.cfg

# 5. Disable unnecessary services
log_info "Disabling unnecessary services..."
SERVICES_TO_DISABLE=(
    "bluetooth"
    "cups"
    "avahi-daemon"
)

for service in "${SERVICES_TO_DISABLE[@]}"; do
    if systemctl is-enabled "$service" 2>/dev/null; then
        systemctl disable "$service"
        systemctl stop "$service"
        log_info "Disabled $service"
    fi
done

# 6. Configure AppArmor
log_info "Enabling AppArmor profiles..."
apt install -y apparmor apparmor-utils
systemctl enable apparmor
systemctl start apparmor
aa-enforce /etc/apparmor.d/*

# 7. Configure SSH security
log_info "Hardening SSH configuration..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d)

cat >> /etc/ssh/sshd_config << 'SSH_EOF'

# Security enhancements
PermitRootLogin no
PasswordAuthentication no
Protocol 2
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
LoginGraceTime 60
SSH_EOF

systemctl restart ssh

# 8. Configure kernel security parameters
log_info "Configuring kernel security parameters..."
cat >> /etc/sysctl.d/99-security.conf << 'SYSCTL_EOF'
# Network security
net.ipv4.ip_forward=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.default.send_redirects=0
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.accept_source_route=0
net.ipv4.conf.default.accept_source_route=0
net.ipv4.conf.all.log_martians=1
net.ipv4.conf.default.log_martians=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.icmp_ignore_bogus_error_responses=1
net.ipv4.tcp_syncookies=1

# Memory protection
kernel.dmesg_restrict=1
kernel.kptr_restrict=2
kernel.yama.ptrace_scope=1

# Filesystem protection
fs.suid_dumpable=0
SYSCTL_EOF

sysctl -p /etc/sysctl.d/99-security.conf

# 9. Install and configure unattended-upgrades
log_info "Configuring automatic security updates..."
apt install -y unattended-upgrades

cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'UPGRADES_EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESM:${distro_codename}";
};
Unattended-Upgrade::Package-Blacklist {
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
UPGRADES_EOF

systemctl enable unattended-upgrades
systemctl start unattended-upgrades

log_info "Security hardening completed successfully!"
log_info "Please review the changes and reboot the system for some settings to take effect."
