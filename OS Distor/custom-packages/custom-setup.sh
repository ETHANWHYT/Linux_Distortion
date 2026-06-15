#!/bin/bash

################################################################################
# CustomTails Custom Setup Script
# Runs during system initialization
# Place custom commands and configurations here
################################################################################

echo "[*] Running CustomTails custom setup..."

# Create a non-root user for general use
if ! id "tails" &>/dev/null; then
    echo "[+] Creating tails user..."
    useradd -m -s /bin/bash -G sudo tails
    echo "tails:tails" | chpasswd
fi

# Configure Tor to start automatically
echo "[+] Configuring Tor..."
systemctl enable tor
systemctl start tor

# Configure Privoxy
echo "[+] Configuring Privoxy..."
systemctl enable privoxy
systemctl start privoxy

# Set up Tor for transparent proxying (optional)
# This requires iptables configuration
# Uncomment if you want full system-wide Tor

# Create custom aliases
cat >> /home/tails/.bashrc <<'EOF'

# CustomTails specific aliases
alias tor-status='systemctl status tor'
alias tor-restart='systemctl restart tor'
alias check-ip='curl https://ipinfo.io'
alias check-tor='curl https://check.torproject.org'
alias cleartemp='rm -rf /tmp/* /var/tmp/*'
alias secshred='shred -vfz -n 3'  # Securely delete files

# Useful functions
function wipedata() {
    echo "WARNING: This will securely erase data"
    echo "Usage: wipedata [file/directory]"
    shred -vfz -n 10 "$1"
}

function checkram() {
    free -h | grep -E "Mem:|total"
}

function diskusage() {
    du -sh /* 2>/dev/null | sort -rh | head -20
}
EOF

# Create a motd (message of the day)
cat > /etc/motd <<'EOF'
╔═══════════════════════════════════════════════════════════════╗
║         Welcome to CustomTails Linux Distribution             ║
║                                                               ║
║  A privacy-focused, bootable Linux system based on Tails OS   ║
║                                                               ║
║  Key Features:                                                ║
║  • Tor integration for anonymity                              ║
║  • Persistent storage support                                 ║
║  • Common Linux tools and utilities                           ║
║  • Leave no traces on host system                             ║
║                                                               ║
║  Quick Commands:                                              ║
║  check-tor    - Verify Tor connection                         ║
║  check-ip     - Check current IP address                      ║
║  tor-restart  - Restart Tor service                           ║
║                                                               ║
║  For help: man tor, man torsocks, help                        ║
║                                                               ║
║  ⚠️  Use responsibly and legally                              ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF

# Set permissions
chmod 644 /etc/motd

# Configure SSH (if running as server)
# Uncomment to enable SSH by default
# echo "[+] Configuring SSH..."
# systemctl enable ssh
# ssh-keygen -A  # Generate server keys

# Configure firewall (ufw)
# Uncomment if you want automatic firewall setup
# echo "[+] Setting up firewall..."
# ufw default deny incoming
# ufw default allow outgoing
# ufw allow 22/tcp  # SSH
# ufw enable

# Clean up package manager cache
echo "[+] Cleaning package cache..."
apt-get autoclean
apt-get autoremove -y

# Create system info file
echo "[+] Creating system information..."
cat > /root/SYSTEM-INFO.txt <<'EOF'
CustomTails Linux Distribution
===============================

Build Information:
- Based on: Debian Bullseye
- Focus: Privacy and security
- Default Boot Mode: Persistence enabled

User Accounts:
- root: No password set (use 'sudo' for privilege)
- tails: Created for normal use (password: tails)

Services:
- Tor: Automatic Tor anonymization
- Privoxy: Web filtering and proxying
- SSH: Available for remote access

Persistence Storage:
- Location: Third partition on USB drive
- Label: TailsData
- Mount point: /home/tails/Persistent

Useful Commands:
- tor-status: Check Tor service status
- check-ip: Display current IP address
- check-tor: Verify Tor connection
- cleartemp: Securely clear temporary files

Security Notes:
- All changes are isolated (when not using persistence)
- Tor runs in the background
- No data is saved by default

For more information, see the documentation/
directory on the boot media.
EOF

echo "[+] CustomTails setup complete!"
echo "[+] System ready for use"

exit 0
