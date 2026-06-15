# Troubleshooting Guide

Solutions to common issues when building and using CustomTails Linux Distribution.

## Build Issues

### Issue 1: "debootstrap: command not found"

**Problem**: Build script fails immediately

**Solution**:
```bash
# Install debootstrap
sudo apt-get update
sudo apt-get install -y debootstrap

# Verify installation
debootstrap --version

# Retry build
sudo ./build-scripts/build-tails-distro.sh
```

### Issue 2: "Not enough disk space"

**Problem**: Build fails partway through with space error

**Solutions**:

```bash
# Check current disk space
df -h

# Check build directory size
du -sh /tmp/tails-build-*

# Clean up package cache
sudo apt-get clean
sudo apt-get autoclean

# Remove old build directories
sudo rm -rf /tmp/tails-build-*

# If still not enough, use external drive
mkdir /mnt/external-build
sudo ./build-scripts/build-tails-distro.sh

# Or set BUILD_DIR in script:
# nano build-scripts/build-tails-distro.sh
# Modify: BUILD_DIR="/mnt/external-build/tails-$$"
```

### Issue 3: "Some packages failed to install"

**Problem**: Script continues but shows "E: Unable to locate package"

**Solutions**:

```bash
# Update package lists
sudo apt-get update

# Check if package exists
apt-cache search packagename

# Remove problematic packages from config/packages-list.txt
nano config/packages-list.txt

# Common issues - remove these if unavailable:
# tails-tweaks (specific to Tails)
# tor-browser (use firefox instead)
# onion-circuits (separate tool)

# Verify package name
apt-cache show correct-package-name

# Rebuild
sudo ./build-scripts/build-tails-distro.sh
```

### Issue 4: "Cannot mount /proc"

**Problem**: Chroot mounting fails

**Solutions**:

```bash
# Manually unmount previous attempts
sudo umount /tmp/tails-build-*/chroot/* 2>/dev/null || true

# Check what's mounted
mount | grep tails-build

# Force unmount if needed
sudo umount -l /tmp/tails-build-*/chroot/* 2>/dev/null || true

# Clean up
sudo rm -rf /tmp/tails-build-*

# Retry with fresh start
sudo ./build-scripts/build-tails-distro.sh
```

### Issue 5: "xorrisofs: command not found"

**Problem**: ISO creation fails

**Solution**:
```bash
# Install xorriso
sudo apt-get install -y xorriso

# Install additional boot-related tools
sudo apt-get install -y \
    grub-pc-bin \
    grub-efi-amd64-bin \
    syslinux \
    mtools \
    dosfstools

# Retry build
sudo ./build-scripts/build-tails-distro.sh
```

### Issue 6: Build takes forever (>2 hours)

**Problem**: Script is still running after long time

**Solutions**:

Check if it's actually working:
```bash
# In another terminal
watch -n 5 'du -sh /tmp/tails-build-*'
```

If size is increasing: **It's working, be patient**

If size is constant:
```bash
# Kill the build
sudo pkill -f build-tails-distro.sh

# Restart with verbose output
sudo bash -x ./build-scripts/build-tails-distro.sh 2>&1 | tee build.log

# Check log for errors
tail -50 build.log
```

Performance tips:
```bash
# Use faster mirror
# Edit build script and change:
# deb.debian.org to a closer mirror

# Use local package cache
sudo apt-get install -y squid-deb-proxy

# Allocate more resources if possible
# Close other programs
# Increase swap (if needed)
```

## USB Flashing Issues

### Issue 1: "Device does not exist"

**Problem**: `/dev/sdX` not recognized

**Solutions**:

```bash
# List all devices
lsblk -d

# Try alternative names
ls -la /dev/disk/by-id/

# For NVMe drives use
/dev/nvme0n1

# Check if USB is mounted
mount | grep -E "sd|nvme"

# Unmount if mounted
sudo umount /dev/sdX*
```

### Issue 2: "Refusing to flash system drive"

**Problem**: Script won't flash to `/dev/sda` or `/dev/nvme0n1`

**Explanation**: Safety feature to prevent data loss

**Solution**: Use correct USB device:
```bash
# Identify USB correctly
lsblk -d | grep -v loop | tail -1  # Usually last device

# Example output might show:
# sdb     8:16   1 14.9G  0 disk

# Use: sudo ./flash-to-usb.sh /dev/sdb
```

### Issue 3: "Device is busy"

**Problem**: Cannot unmount USB

**Solutions**:

```bash
# Find what's using the device
lsof | grep sdX

# Force kill processes
pkill -f sdX

# Or use fuser
sudo fuser -k /dev/sdX*

# Retry flashing
sudo ./flash-to-usb.sh /dev/sdX
```

### Issue 4: Flash completes but doesn't boot

**Problem**: USB created but won't boot

**Solutions**:

```bash
# Verify ISO was written completely
dd if=/dev/sdX bs=1M | sha256sum
sha256sum iso/custom-tails-*.iso

# If hashes don't match, reflash
sudo ./build-scripts/flash-to-usb.sh /dev/sdX

# Test in QEMU first
qemu-system-x86_64 -m 2G -usb -usbdevice disk:/dev/sdX

# Check BIOS boot order (on target computer)
# Enter BIOS setup (usually DEL, F2, or F10)
# Set USB to highest priority in Boot Order
```

### Issue 5: "Partition 1 not properly closed"

**Problem**: Warning appears during flashing

**Solution**: This is usually harmless but to fix:
```bash
# Erase USB completely first
sudo dd if=/dev/zero of=/dev/sdX bs=1M status=progress

# Wait for completion
# Then reflash
sudo ./build-scripts/flash-to-usb.sh /dev/sdX
```

## Boot Issues

### Issue 1: USB doesn't boot

**Problem**: Computer ignores USB drive

**Solutions**:

1. **Enter boot menu**:
   - DEL, F1, F2, F10, F12 (varies by manufacturer)
   - See motherboard manual

2. **Check USB priority**:
   ```
   - Enter BIOS Setup
   - Find "Boot Order" or "Boot Priority"
   - Move USB to top
   - Save and Exit
   ```

3. **Enable legacy/UEFI boot**:
   ```
   - In BIOS, find "Legacy Boot" or "CSM"
   - Enable Legacy mode if boot fails
   - Or disable Legacy and use UEFI only
   ```

4. **Try different USB port**:
   - Some ports may not work
   - Try all available USB ports
   - Use USB 2.0 if 3.0 doesn't work

### Issue 2: Black screen or frozen boot

**Problem**: USB boots but system hangs

**Solutions**:

1. **Boot with different options**:
   - At GRUB menu, select different boot option
   - Try "Live System (Failsafe)"
   - Try "Live System (Verbose)"

2. **Boot parameters adjustment**:
   - Press 'e' at GRUB menu
   - Add parameters:
     ```
     nomodeset - Disable graphics acceleration
     acpi=off  - Disable ACPI
     noapic    - Disable APIC
     ```
   - Press Ctrl+X to boot

3. **Check hardware compatibility**:
   - Very old or new hardware might have issues
   - Try on different computer
   - Update BIOS if possible

### Issue 3: System boots but very slow

**Problem**: Takes 10+ minutes to load

**Solutions**:

```bash
# Try toram option (loads to RAM)
- At GRUB menu, select "Live System (RAM)"

# Or optimize boot:
- Reduce timeout in GRUB menu
- Remove unnecessary packages
- Use persistence to cache data
```

### Issue 4: Can't find persistence partition

**Problem**: "Persistence" option doesn't load data

**Solutions**:

```bash
# Check partition exists
lsblk /dev/sdX

# Should show something like:
# sdX1  ISO filesystem
# sdX2  Boot
# sdX3  Persistent storage

# If sdX3 missing:
sudo cfdisk /dev/sdX
# Create new partition in remaining space

# Verify label
sudo blkid | grep sdX

# Should show: LABEL="TailsData"

# Correct label if needed
sudo e2label /dev/sdX3 TailsData
```

## Runtime Issues

### Issue 1: No internet connection

**Problem**: Can't connect to network

**Solutions**:

```bash
# Check if Tor is running
sudo systemctl status tor

# Restart Tor
sudo systemctl restart tor

# Check network interface
ip addr show
ifconfig

# Restart networking
sudo systemctl restart networking

# Try manual DHCP
sudo dhclient eth0

# Check for Tor connection
curl -x socks5://localhost:9050 https://check.torproject.org

# Or check IP
curl https://ipinfo.io
```

### Issue 2: Tor connection fails

**Problem**: Cannot connect through Tor

**Solutions**:

```bash
# Check Tor logs
sudo journalctl -u tor -n 50

# Restart Tor
sudo service tor restart

# Check if ports are blocked
sudo netstat -tlnp | grep tor

# Try using system Tor socket
export SOCKS5_SERVER=localhost:9050
torsocks curl https://check.torproject.org
```

### Issue 3: Persistent storage not saving

**Problem**: Changes lost after reboot

**Solutions**:

```bash
# Check if persistence mounted
mount | grep Persistent

# Should show something like:
# /dev/sdX3 on /home/tails/Persistent

# If not mounted:
sudo mkdir -p /home/tails/Persistent
sudo mount -L TailsData /home/tails/Persistent

# Fix permissions
sudo chown tails:tails /home/tails/Persistent
chmod 700 /home/tails/Persistent

# Check disk space
df -h | grep Persistent

# If full, delete old files
du -sh ~/Persistent/*
rm -rf ~/Persistent/old-files
```

### Issue 4: Application crashes

**Problem**: Programs crash unexpectedly

**Solutions**:

```bash
# Run from terminal to see error
application-name

# Check system resources
free -h      # RAM
df -h        # Disk space
top          # CPU usage

# If out of memory
# Either use less applications
# Or reboot with 'toram' option

# Check application logs
journalctl -n 50
```

### Issue 5: File system errors

**Problem**: Permission denied or read-only errors

**Solutions**:

```bash
# Check persistent partition health
sudo e2fsck -n /dev/sdX3

# Fix errors (unmount first)
sudo umount /dev/sdX3
sudo e2fsck -p /dev/sdX3
sudo mount /dev/sdX3

# Fix permissions
sudo chmod 755 ~/Persistent
sudo chown tails:tails ~/Persistent -R
```

## Performance Issues

### System is very slow

**Problem**: Everything takes long time

**Solutions**:

```bash
# Check system resources
free -h        # RAM usage
df -h          # Disk space
ps aux         # Running processes
top            # Interactive view

# Kill unnecessary processes
sudo killall program-name

# Clear cache
sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches

# Use toram to load to memory
# Select at boot menu instead of persistence
```

### High disk I/O

**Problem**: Disk light constantly on, system slow

**Solutions**:

```bash
# Monitor disk I/O
sudo iotop

# Check what's writing
lsof | grep REG | awk '{print $9}' | sort | uniq -c | sort -rn

# Reduce logging
sudo vi /etc/rsyslog.conf

# Disable unnecessary services
sudo systemctl disable service-name
sudo systemctl stop service-name
```

## Data Recovery

### Lost files on persistent storage

**Problem**: Important files accidentally deleted

**Recovery options** (limited):

```bash
# Check if in trash
ls -la ~/.local/share/Trash/

# Check filesystem journal
sudo dumpe2fs -h /dev/sdX3 | grep "Journal"

# Professional recovery may be needed
# Stop using USB immediately
# Use 'photorec' or similar tools
sudo apt-get install -y testdisk
photorec /dev/sdX3
```

## Reporting Issues

If you encounter issues not listed here:

1. **Collect information**:
   ```bash
   # System info
   uname -a
   lsb_release -a
   inxi -b
   
   # Build environment
   debootstrap --version
   xorrisofs --version
   
   # Error log
   sudo ./build-scripts/build-tails-distro.sh 2>&1 | tee error.log
   ```

2. **Check resources**:
   - Tails documentation: https://tails.boum.org/
   - Debian documentation: https://debian.org/
   - This project's documentation

3. **Common resources**:
   - Stack Overflow
   - Unix & Linux Stack Exchange
   - Debian support forums

## Getting Help

See the other documentation files:
- `BUILDING.md` - Build process details
- `PERSISTENCE.md` - Storage setup
- `CUSTOMIZATION.md` - Custom modifications

## Prevention Tips

✓ Always test in virtual machine first
✓ Keep backups of persistent data
✓ Use strong encryption for sensitive files
✓ Document any customizations you make
✓ Keep system updated
✓ Test on multiple computers when possible
