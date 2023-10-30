#! /bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive

echo "running security hardening script for server."

# Step 1: Update your system
echo -e "\e[33mStep 7: Updating your system\e[0m"
sudo apt-get update && sudo apt-get upgrade -y
echo ""

# Step 2: Document the host information
echo -e "\e[33mStep 1: Documenting host information\e[0m"
echo "Hostname: $(hostname)"
echo "Kernel version: $(uname -r)"
echo "Distribution: $(lsb_release -d | cut -f2)"
echo "CPU information: $(lscpu | grep 'Model name')"
echo "Memory information: $(free -h | awk '/Mem/{print $2}')"
echo "Disk information: $(lsblk | grep disk)"
echo 

# Step 3: BIOS protection
echo -e "\e[33mStep 2: BIOS protection\e[0m"
echo "Checking if BIOS protection is enabled..."
if [ -f /sys/devices/system/cpu/microcode/reload ]; then
  echo "BIOS protection is enabled"
else
  echo "BIOS protection is not enabled"
fi
echo ""

# Step 4: Hard disk encryption
echo -e "\e[33mStep 3: Hard disk encryption\e[0m"
echo "Checking if hard disk encryption is enabled..."
if [ -d /etc/luks ]; then
  echo "Hard disk encryption is enabled"
else
  echo "Hard disk encryption is not enabled"
fi
echo ""

# Step 5: Lock the boot directory
echo -e "\e[33mSstep 5: Lock the boot directory\e[0m"
echo "Locking the boot directory..."
sudo chmod 700 /boot
echo ""

# Step 6: Disable USB usage
echo -e "\e[33mStep 6: Disable USB usage\e[0m"
echo "Disabling USB usage..."
echo 'blacklist usb-storage' | sudo tee /etc/modprobe.d/blacklist-usbstorage.conf
echo ""

# Step 7: Update your system
echo -e "\e[33mStep 7: Updating your system\e[0m"
sudo apt-get install net-tools curl debsums gnupg openssl python3 -y
echo ""

# Step 8: Check the installed packages
echo -e "\e[33mStep 8: Checking the installed packages\e[0m"
dpkg --get-selections | grep -v deinstall
echo ""

# Step 9: Check for open ports
echo -e "\e[33mStep 9: Checking for open ports\e[0m"
sudo netstat -tulpn
echo ""

# Step 10: Secure SSH
echo -e "\e[33mStep 10: Securing SSH\e[0m"
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sudo systemctl restart sshd
echo

# Step 11: Enable SELinux
echo -e "\e[33mStep 11: Enabling SELinux\e[0m"
echo "Checking if SELinux is installed..."
if [ -f /etc/selinux/config ]; then
  echo "SELinux is already installed"
else
  echo "SELinux is not installed, installing now..."
  sudo apt-get install selinux-utils selinux-basics -y
fi
echo "Enabling SELinux..."
sudo selinux-activate
echo ""

# Step 12: Set network parameters
echo -e "\e[33mStep 12: Setting network parameters\e[0m"
echo "Setting network parameters..."
sudo sysctl -p
echo ""

# Step 13: Manage password policies
echo -e "\e[33mStep 13: Managing password policies\e[0m"
echo "Modifying the password policies..."
sudo sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t90/g' /etc/login.defs
sudo sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t7/g' /etc/login.defs
sudo sed -i 's/PASS_WARN_AGE\t7/PASS_WARN_AGE\t14/g' /etc/login.defs
echo ""

# Step 14: Permissions and verifications
echo -e "\e[33mStep 14: Permissions and verifications\e[0m"
echo "Setting the correct permissions on sensitive files..."
sudo chmod 700 /etc/shadow /etc/gshadow /etc/passwd /etc/group
sudo chmod 600 /boot/grub/grub.cfg
sudo chmod 644 /etc/fstab /etc/hosts /etc/hostname /etc/timezone /etc/bash.bashrc
echo "Verifying the integrity of system files..."
sudo debsums -c
echo ""

# Step 15: Additional distro process hardening
echo -e "\e[33mStep 15: Additional distro process hardening\e[0m"
echo "Disabling core dumps..."
sudo echo '* hard core 0' | sudo tee /etc/security/limits.d/core.conf
echo "Restricting access to kernel logs..."
sudo chmod 640 /var/log/kern.log
echo "Setting the correct permissions on init scripts..."
sudo chmod 700 /etc/init.d/*
echo ""

# Step 16: Remove unnecessary services
echo -e "\e[33mStep 16: Removing unnecessary services\e[0m"
echo "Removing unnecessary services..."
sudo apt-get purge rpcbind rpcbind-* -y
sudo apt-get purge nis -y
echo ""

# Step 17: Check for security on key files
echo -e "\e[33mStep 17: Checking for security on key files\e[0m"
echo "Checking for security on key files..."
sudo find /etc/ssh -type f -name 'ssh_host_*_key' -exec chmod 600 {} \;
echo ""

# # Step 18: Limit root access using SUDO
# echo -e "\e[33mStep 18: Limiting root access using SUDO\e[0m"
# echo "Limiting root access using SUDO..."
# sudo apt-get install sudo -y
# sudo groupadd admin
# sudo usermod -a -
# sudo sed -i 's/%sudo\tALL=(ALL:ALL) ALL/%admin\tALL=(ALL:ALL) ALL/g' /etc/sudoers
# echo ""

# Step 19: Only allow root to access CRON
echo -e "\e[33mStep 19: Restricting access to CRON\e[0m"
echo "Only allowing root to access CRON..."
sudo chmod 600 /etc/crontab
sudo chown root:root /etc/crontab
sudo chmod 600 /etc/crontab
# sudo chmod 600 /etc/cron.hourly/*
# sudo chmod 600 /etc/cron.daily/*
# sudo chmod 600 /etc/cron.weekly/*
# sudo chmod 600 /etc/cron.monthly/*
# sudo chmod 600 /etc/cron.d/*
echo ""

# Step 20: Remote access and SSH basic settings
echo -e "\e[33mStep 20: Remote access and SSH basic settings\e[0m"
echo "Disabling root login over SSH..."
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
echo "Disabling password authentication over SSH..."
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
echo "Disabling X11 forwarding over SSH..."
sudo sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config
echo "Reloading the SSH service..."
sudo systemctl reload sshd
echo ""

# Step 21: Disable Xwindow
echo -e "\e[33mStep 21: Disabling Xwindow\e[0m"
echo "Disabling Xwindow..."
sudo systemctl set-default multi-user.target
echo ""

# Step 22: Minimize Package Installation
echo -e "\e[33mStep 22: Minimizing Package Installation\e[0m"
echo "Installing only essential packages..."
sudo apt-get install --no-install-recommends -y systemd-sysv apt-utils
sudo apt-get --purge autoremove -y
echo ""

# Step 23: Checking accounts for empty passwords
echo -e "\e[33mStep 23: Checking accounts for empty passwords\e[0m"
echo "Checking for accounts with empty passwords..."
sudo awk -F: '($2 == "" ) {print}' /etc/shadow
echo ""

# Step 24: Monitor user activities
echo -e "\e[33mStep 24: Monitoring user activities\e[0m"
echo "Installing auditd for user activity monitoring..."
sudo apt-get install auditd -y
echo "Configuring auditd..."
sudo echo "-w /var/log/auth.log -p wa -k authentication" | sudo tee -a /etc/audit/rules.d/audit.rules
sudo echo "-w /etc/passwd -p wa -k password-file" | sudo tee -a /etc/audit/rules.d/audit.rules
sudo echo "-w /etc/group -p wa -k group-file" | sudo tee -a /etc/audit/rules.d/audit.rules
sudo systemctl restart auditd
echo ""

# Step 25: Install and configure fail2ban
echo -e "\e[33mStep 25: Installing and configuring fail2ban\e[0m"
echo "Installing fail2ban..."
sudo apt-get install fail2ban -y
echo "Configuring fail2ban..."
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo sed -i 's/bantime  = 10m/bantime  = 1h/g' /etc/fail2ban/jail.local
sudo sed -i 's/maxretry = 5/maxretry = 3/g' /etc/fail2ban/jail.local
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
echo ""

# Step 26: Rootkit detection
echo -e "\e[33mStep 26: Installing and running Rootkit detection...\e[0m"
sudo apt-get install chkrootkit -y
sudo chkrootkit 
echo ""

# Step 27: Monitor system logs
echo -e "\e[33mStep 27: Monitoring system logs\e[0m"
echo "Installing logwatch for system log monitoring..."
sudo apt-get install logwatch -y
echo ""

# Step 28: Enable 2-factor authentication
# echo -e "\e[33mStep 28: Enabling 2-factor authentication\e[0m"
# echo "Installing Google Authenticator for 2-factor authentication..."
# sudo apt-get install libpam-google-authenticator -y
# echo "Enabling 2-factor authentication..."
# sudo google-authenticator
# echo "Editing PAM settings for 2-factor authentication..."
# sudo sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
# sudo sed -i 's/UsePAM no/UsePAM yes/g' /etc/ssh/sshd_config
# sudo sed -i 's/#auth required pam_google_authenticator.so/auth required pam_google_authenticator.so/g' /etc/pam.d/sshd
# sudo systemctl reload sshd
# echo ""

echo -e "\e[32mHardening complete!\e[0m"
