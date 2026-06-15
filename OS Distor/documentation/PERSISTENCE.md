# Persistent Storage Setup Guide

Guide for configuring and using persistent storage on your CustomTails USB drive.

## What is Persistent Storage?

Persistent storage allows you to save files and settings between reboots. Without it, all changes are lost when you shut down.

**With Persistence**: Changes are saved to USB partition  
**Without Persistence**: Changes are lost on shutdown (more private)

## Creating Persistence Partition

### Automatic Creation (Recommended)

The `flash-to-usb.sh` script automatically creates a persistence partition:

```bash
sudo ./build-scripts/flash-to-usb.sh /dev/sdX
```

This creates three partitions:
- **Partition 1**: ISO filesystem (bootable)
- **Partition 2**: Boot data
- **Partition 3**: Persistent storage (labeled "TailsData")

### Manual Creation

If automatic creation fails, create manually:

```bash
# List devices
lsblk -d | grep -E "sd|nvme"

# Open partition editor
sudo cfdisk /dev/sdX

# Create new partition:
# 1. Select "New"
# 2. Accept default size to use remaining space
# 3. Select "Primary"
# 4. Write changes
# 5. Quit

# Format the new partition
sudo mkfs.ext4 -F -L TailsData /dev/sdX3

# Verify
lsblk /dev/sdX
```

## Using Persistent Storage

### First Boot

1. Boot from USB
2. Select "Live System with Persistence"
3. Wait for system to load
4. The persistent partition is automatically mounted at `/home/tails/Persistent`

### Saving Data

Create or copy files to persistent directories:

```bash
# Copy files to persistent storage
cp myfile.txt ~/Persistent/

# Create directories
mkdir ~/Persistent/documents
mkdir ~/Persistent/projects

# Navigate directly
cd ~/Persistent
```

### Between Reboots

- Files in `~/Persistent` are saved
- System changes are NOT saved (only if stored in Persistent)
- Tor cache is reset
- Temporary files are cleared

## Recommended Persistent Directory Structure

```
~/Persistent/
├── documents/        # Important documents
├── projects/         # Development projects
├── downloads/        # Downloaded files
├── .ssh/            # SSH keys (secure!)
├── .gnupg/          # GPG keys (secure!)
├── keepass/         # Password database
├── tor-backup/      # Tor configuration backups
└── notes.txt        # Quick notes
```

## Encrypting Persistent Storage

For additional security, encrypt the persistent partition:

### Using LUKS Encryption

```bash
# Install cryptsetup (if not already installed)
sudo apt-get install cryptsetup

# Encrypt the partition
sudo cryptsetup luksFormat /dev/sdX3

# Open encrypted partition
sudo cryptsetup luksOpen /dev/sdX3 persistent

# Format encrypted partition
sudo mkfs.ext4 /dev/mapper/persistent

# Mount
sudo mount /dev/mapper/persistent ~/Persistent

# Close when done
sudo cryptsetup luksClose persistent
```

### Automatic Mounting on Boot

Create a script to auto-mount encrypted partition:

```bash
#!/bin/bash
# /home/tails/.config/autostart/mount-persistent.sh

sudo cryptsetup luksOpen /dev/disk/by-label/TailsData persistent
sudo mount /dev/mapper/persistent ~/Persistent
```

## Selective Persistence

Some applications can be configured for persistence:

### Tor Browser
```bash
# Bookmarks and settings persist automatically
# Store sensitive sites in bookmarks

# Location: ~/Persistent/.mozilla/
```

### SSH Keys
```bash
# Create SSH directory
mkdir -p ~/Persistent/.ssh
chmod 700 ~/Persistent/.ssh

# Copy your keys
cp ~/.ssh/id_rsa ~/Persistent/.ssh/
chmod 600 ~/Persistent/.ssh/id_rsa

# Link from home
ln -s ~/Persistent/.ssh ~/.ssh
```

### GPG Keys
```bash
# Similar to SSH
mkdir -p ~/Persistent/.gnupg
gpg --import-ownertrust ~/Persistent/.gnupg/trustdb.txt
```

### Git Configuration
```bash
# Store git config in persistent
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# These are stored automatically in persistent
```

## Backup Persistent Data

### Before Major Updates

```bash
# Create backup
sudo tar -czf ~/Persistent-backup-$(date +%Y%m%d).tar.gz ~/Persistent/

# Move to external drive
sudo cp ~/Persistent-backup-*.tar.gz /media/usb/
```

### Incremental Backups

```bash
#!/bin/bash
# Incremental backup script

BACKUP_DIR="/media/backup"
PERSISTENT_DIR="$HOME/Persistent"

mkdir -p "$BACKUP_DIR"

# Create incremental backup
tar -czf "$BACKUP_DIR/backup-$(date +%Y%m%d-%H%M%S).tar.gz" \
    --newer-mtime-than "$BACKUP_DIR/last-backup.txt" \
    "$PERSISTENT_DIR"

touch "$BACKUP_DIR/last-backup.txt"
```

## Resizing Persistent Partition

If you need more space:

```bash
# Boot into Linux (not Tails)
# Using GParted or similar partition tool

# Or command line
sudo parted /dev/sdX
resizepart 3 100%  # Resize partition 3 to full available space
quit

# Resize filesystem
sudo e2fsck -f /dev/sdX3
sudo resize2fs /dev/sdX3
```

## Removing Persistent Data

To completely remove persistent data:

```bash
# Securely erase partition
sudo shred -vfz -n 10 /dev/sdX3

# Or with dd
sudo dd if=/dev/zero of=/dev/sdX3 bs=1M status=progress

# Remove partition
sudo parted /dev/sdX rm 3
```

## Performance Tips

### Optimize Persistence

**For faster access:**
```bash
# Disable journaling (risky, but faster)
sudo tune2fs -O ^has_journal /dev/sdX3

# Or optimize for speed
sudo tune2fs -c 0 -i 0 /dev/sdX3
```

**For better reliability:**
```bash
# Enable additional journaling
sudo tune2fs -j /dev/sdX3

# Set mount options
sudo nano /etc/fstab
# Change: defaults to: defaults,noatime,nodiratime
```

### Check Partition Health

```bash
# Check disk errors
sudo e2fsck -n /dev/sdX3

# Get usage information
du -sh ~/Persistent/*
df -h ~/Persistent

# Monitor I/O
iostat -x 1
```

## Troubleshooting

### Persistent Partition Not Found

**Problem**: Boot menu doesn't show persistence option

**Solution**:
```bash
# Check if partition exists
lsblk /dev/sdX

# Verify label
sudo blkid /dev/sdX3

# Correct label if needed
sudo e2label /dev/sdX3 TailsData
```

### Permission Denied on Persistent

**Problem**: Cannot write to persistent directory

**Solution**:
```bash
# Check permissions
ls -ld ~/Persistent

# Fix permissions
sudo chown $(whoami):$(whoami) ~/Persistent
chmod 755 ~/Persistent
```

### Corrupted Persistent Data

**Problem**: Files cannot be accessed in persistent

**Solution**:
```bash
# Check filesystem
sudo e2fsck -f /dev/sdX3

# Repair if needed
sudo e2fsck -p /dev/sdX3

# Restore from backup if available
```

## Security Considerations

⚠️ **Important Security Notes:**

1. **Encryption**: Always encrypt sensitive data
   ```bash
   gpg -c important-file.txt
   ```

2. **Access Control**: Set proper permissions
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_rsa
   ```

3. **Cleanup**: Remove temporary sensitive files
   ```bash
   shred -vfz sensitive-file.txt
   ```

4. **Backups**: Keep encrypted backups
   ```bash
   gpg -r your-key-id -e backup.tar.gz
   ```

5. **Avoid Patterns**: Don't always use persistence
   - Mix boots with and without persistence
   - Unpredictable patterns

## Next Steps

- See `BUILDING.md` for distribution building
- See `CUSTOMIZATION.md` for advanced setup
- See `TROUBLESHOOTING.md` for common issues
