# Customization Guide

Advanced customization options for CustomTails Linux Distribution.

## Modifying Package List

### Add New Packages

Edit `config/packages-list.txt`:

```bash
nano config/packages-list.txt

# Add at the end:
# Development
postgresql
postgresql-contrib
golang-go
rust
rustc

# Multimedia  
mpv
youtube-dl

# System
docker.io
podman
```

Then rebuild:
```bash
sudo ./build-scripts/build-tails-distro.sh
```

### Remove Packages

Delete or comment out lines in `config/packages-list.txt`:

```bash
# Comment out (line will be ignored)
# postgresql-contrib

# Or delete the line entirely
```

### Find Available Packages

Search for packages in Debian repository:

```bash
apt-cache search keyword
apt-cache show package-name

# Examples
apt-cache search database
apt-cache show postgresql
```

## Modifying Boot Configuration

Edit `config/grub-config.cfg` to customize boot menu:

### Add Custom Boot Option

```bash
nano config/grub-config.cfg

# Add new menuentry:
menuentry 'My Custom Boot Option' {
    insmod gzio
    insmod part_msdos
    insmod ext2
    insmod squash4
    set root='(hd0,msdos1)'
    
    linux /boot/vmlinuz boot=live my-custom-param quiet splash
    initrd /boot/initrd.img
}
```

### Boot Parameters Reference

| Parameter | Effect |
|-----------|--------|
| `quiet` | Minimal boot messages |
| `splash` | Show splash screen |
| `verbose` | Detailed boot messages |
| `persistence` | Enable persistent storage |
| `toram` | Load entire system to RAM |
| `noapic` | Disable APIC |
| `nomodeset` | Disable kernel mode setting |
| `acpi=off` | Disable ACPI |
| `mem=XG` | Limit RAM usage |
| `ip=dhcp` | Configure networking |

### Change Boot Timeout

In `grub-config.cfg`:
```bash
set timeout=10  # Change 10 to desired seconds
```

## Custom Startup Scripts

Create custom initialization scripts in `custom-packages/`:

### Example: Auto-Connect VPN

Create `custom-packages/auto-vpn.sh`:

```bash
#!/bin/bash

echo "[*] Configuring VPN..."

# Install OpenVPN
apt-get install -y openvpn

# Copy VPN config
mkdir -p /etc/openvpn/config
# Copy your .ovpn file here

# Enable VPN
systemctl enable openvpn@config
systemctl start openvpn@config

echo "[+] VPN configured"
```

### Example: Auto-Mount Network Shares

Create `custom-packages/network-mounts.sh`:

```bash
#!/bin/bash

echo "[*] Setting up network mounts..."

# Install NFS/SMB tools
apt-get install -y nfs-common smbclient cifs-utils

# Create mount points
mkdir -p /mnt/network/nfs
mkdir -p /mnt/network/smb

# Add to /etc/fstab for auto-mount
cat >> /etc/fstab <<EOF
192.168.1.10:/exported/path  /mnt/network/nfs  nfs  defaults  0 0
//192.168.1.20/share         /mnt/network/smb  cifs  defaults  0 0
EOF

echo "[+] Network mounts configured"
```

### Example: Development Environment

Create `custom-packages/dev-setup.sh`:

```bash
#!/bin/bash

echo "[*] Setting up development environment..."

# Install development tools
apt-get install -y \
    build-essential \
    git \
    docker.io \
    nodejs \
    npm \
    python3-dev

# Add docker group
usermod -aG docker tails

# Install useful dev tools
npm install -g \
    typescript \
    @angular/cli \
    webpack

echo "[+] Development environment ready"
```

## Creating Custom Wallpapers and Themes

### Add Custom Wallpaper

1. Create `custom-packages/wallpaper/` directory:
```bash
mkdir -p custom-packages/wallpaper
cp my-wallpaper.jpg custom-packages/wallpaper/
```

2. Create setup script:
```bash
nano custom-packages/set-wallpaper.sh

#!/bin/bash
cp /root/wallpaper/*.jpg /usr/share/pixmaps/
# Configure X11 to use wallpaper
```

### Apply Custom Theme

Create `custom-packages/apply-theme.sh`:

```bash
#!/bin/bash

echo "[*] Applying custom theme..."

# Install theme engine
apt-get install -y gtk2-engines-murrine

# Copy theme files
mkdir -p /usr/share/themes/CustomTails
cp -r custom-packages/themes/* /usr/share/themes/CustomTails/

# Set as default
echo "gtk-theme-name = \"CustomTails\"" > /etc/gtk-2.0/gtkrc

echo "[+] Theme applied"
```

## Adding Custom Applications

### Pre-configure Application

Create `custom-packages/app-config.sh`:

```bash
#!/bin/bash

# Firefox preferences
mkdir -p /root/.mozilla/firefox/default
cat > /root/.mozilla/firefox/default/prefs.js <<EOF
user_pref("browser.startup.homepage", "about:blank");
user_pref("browser.privatebrowsing.autostart", true);
user_pref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");
EOF

# Tor Browser configuration
mkdir -p /root/.config/Tor\ Browser
echo "SOCKSPort 9050" > /root/.config/Tor\ Browser/torrc

echo "[+] Applications configured"
```

### Add Desktop Shortcuts

Create `custom-packages/add-shortcuts.sh`:

```bash
#!/bin/bash

mkdir -p /usr/share/applications/

# Create .desktop files
cat > /usr/share/applications/custom-tool.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Custom Tool
Exec=/usr/local/bin/custom-tool
Icon=utilities-terminal
Categories=Utility;
EOF

chmod +x /usr/share/applications/custom-tool.desktop
```

## Performance Tuning

### Lightweight Configuration

For systems with limited resources, edit `custom-packages/custom-setup.sh`:

```bash
#!/bin/bash

# Disable unnecessary services
systemctl disable bluetooth
systemctl disable cups
systemctl disable avahi-daemon

# Remove heavy packages from list
# Comment out in config/packages-list.txt:
# - gimp
# - libreoffice
# - thunderbird

# Use lightweight alternatives
apt-get install -y \
    xfce4 \
    xfce4-terminal \
    mousepad \
    ristretto

echo "[+] Lightweight configuration applied"
```

### Maximum Performance Configuration

```bash
#!/bin/bash

# Disable swap (if sufficient RAM)
swapoff -a

# Optimize kernel parameters
sysctl -w kernel.sched_migration_cost_ns=5000000
sysctl -w kernel.sched_autogroup_enabled=0

# Disable swapping
echo "vm.swappiness = 0" >> /etc/sysctl.conf

# Use preload
apt-get install -y preload
systemctl enable preload
```

## Network Customization

### Configure Static IP

In `custom-packages/network-setup.sh`:

```bash
#!/bin/bash

cat > /etc/network/interfaces <<EOF
auto eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
EOF
```

### Enable Wireless

```bash
#!/bin/bash

# Install wireless tools
apt-get install -y wpasupplicant wireless-tools

# Configure wlan0
cat >> /etc/network/interfaces <<EOF

auto wlan0
iface wlan0 inet dhcp
    wpa-ssid YourSSID
    wpa-psk YourPassword
EOF
```

### VPN by Default

```bash
#!/bin/bash

apt-get install -y openvpn

# Create systemd service to start VPN at boot
cat > /etc/systemd/system/openvpn-startup.service <<EOF
[Unit]
Description=OpenVPN at startup
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/sbin/openvpn /etc/openvpn/config.ovpn

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable openvpn-startup.service
```

## Language and Locale Customization

Edit `custom-packages/locale-setup.sh`:

```bash
#!/bin/bash

# Generate additional locales
locale-gen de_DE.UTF-8
locale-gen es_ES.UTF-8
locale-gen fr_FR.UTF-8

# Set default locale
update-locale LANG=es_ES.UTF-8

# Set keyboard layout
loadkeys es  # Spanish
# Or us, de, fr, etc.
```

## Advanced Customizations

### Add Custom Repositories

```bash
#!/bin/bash

# Add PPA (if using Ubuntu-based)
# add-apt-repository ppa:custom/repo
# apt-get update

# Or add Debian backports
echo "deb http://deb.debian.org/debian bullseye-backports main contrib" >> /etc/apt/sources.list
apt-get update
```

### Kernel Customization

For advanced users:

```bash
# Build custom kernel
apt-get install -y build-essential fakeroot linux-source

# Extract kernel source
cd /usr/src
tar xjf linux-source*.tar.bz2

# Configure and compile (takes time!)
cd linux-source*
make menuconfig
make -j$(nproc)
make install
make modules_install
```

### Build Custom Package

Create your own `.deb` package:

```bash
mkdir -p myapp/DEBIAN
mkdir -p myapp/usr/local/bin

cat > myapp/DEBIAN/control <<EOF
Package: myapp
Version: 1.0
Architecture: amd64
Maintainer: Your Name <you@example.com>
Description: My Custom Application
EOF

cp myapp-binary myapp/usr/local/bin/

dpkg-deb --build myapp myapp_1.0_amd64.deb
```

## Testing Custom Changes

### Test Without Rebuilding

1. Boot system normally
2. Install/configure changes manually
3. Test functionality
4. If good, add to build scripts
5. Rebuild when confident

### Test in Virtual Machine

```bash
# Boot ISO in QEMU
qemu-system-x86_64 -m 2G -smp 2 \
    -iso iso/custom-tails-*.iso \
    -boot d

# Test all features before deploying
```

## Documentation for Your Customizations

Create `CUSTOMIZATION-LOG.md`:

```bash
# CustomTails Customization Log

## Changes Made

### Packages Added
- postgresql (database)
- golang (development)

### Services Configured
- VPN auto-connect enabled
- Firewall rules added
- SSH key auto-load configured

### Performance Tweaks
- Kernel parameters optimized
- Swap disabled
- Preload enabled

### Custom Scripts
- /usr/local/bin/backup-persistence.sh
- /usr/local/bin/secure-delete-files.sh

## Testing Results
- [x] Boot with persistence
- [x] Boot without persistence
- [x] VPN connection works
- [ ] Add more tests

## Known Issues
- None currently

## Future Improvements
- Add KDE desktop environment
- Implement automatic backup
```

## Next Steps

- See `BUILDING.md` for rebuild instructions
- See `TROUBLESHOOTING.md` for issues
- See `PERSISTENCE.md` for data storage
