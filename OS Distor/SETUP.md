# Setup Instructions for Different Systems

Guide for preparing to build CustomTails on various platforms.

## Using Linux (Ubuntu/Debian) - RECOMMENDED

### Quick Setup

```bash
# 1. Install required packages
sudo apt-get update
sudo apt-get install -y \
    wget curl xorriso grub-pc-bin grub-efi-amd64-bin \
    debootstrap squashfs-tools dosfstools mtools \
    build-essential git pv

# 2. Clone or navigate to project
cd OS\ Distor

# 3. Make scripts executable
chmod +x build-scripts/*.sh custom-packages/*.sh

# 4. Start building
sudo ./build-scripts/build-tails-distro.sh
```

### Fedora/RHEL/CentOS

```bash
# Install packages
sudo dnf install -y \
    xorriso grub2-tools grub2-efi-modules \
    debootstrap squashfs-tools dosfstools mtools \
    gcc make git pv

# Or for older systems
sudo yum install -y ...

# Rest is same as Ubuntu
```

### Arch Linux

```bash
# Install packages
sudo pacman -S \
    wget curl xorriso grub debootstrap \
    squashfs-tools dosfstools mtools \
    base-devel git pv

# Continue building
```

## Using Windows with WSL (Windows Subsystem for Linux)

### Setup WSL

```powershell
# In PowerShell as Administrator
wsl --install -d Ubuntu-22.04

# Or update existing
wsl --update
```

### Inside WSL Terminal

```bash
# Update Ubuntu
sudo apt-get update
sudo apt-get upgrade

# Install dependencies
sudo apt-get install -y \
    wget curl xorriso grub-pc-bin grub-efi-amd64-bin \
    debootstrap squashfs-tools dosfstools mtools \
    build-essential git pv

# Navigate to project
cd /mnt/c/Users/YourUsername/OneDrive/Desktop/kali/'OS Distor'

# Make executable
chmod +x build-scripts/*.sh custom-packages/*.sh

# Build (will take longer on WSL)
sudo ./build-scripts/build-tails-distro.sh
```

### Tips for WSL

- WSL2 is faster than WSL1
- Disable antivirus scanning of `/tmp` for speed
- Use SSD for best performance
- 8GB+ RAM allocated

## Using macOS with Virtual Machine

### Option A: Docker (Fastest)

```bash
# Install Docker Desktop for Mac
# https://www.docker.com/products/docker-desktop

# Create Docker image
docker run -it --privileged ubuntu:22.04 /bin/bash

# Inside Docker
apt-get update
apt-get install -y \
    wget curl xorriso grub-pc-bin grub-efi-amd64-bin \
    debootstrap squashfs-tools dosfstools mtools \
    build-essential git pv

# Copy project and build
# docker cp OS\ Distor /workspace/
# cd /workspace/OS\ Distor
# ./build-scripts/build-tails-distro.sh
```

### Option B: Virtual Machine

1. **Install VirtualBox or UTM**
   ```bash
   brew install virtualbox
   # or
   brew install utm
   ```

2. **Create Ubuntu 22.04 VM**
   - Allocate 8GB RAM
   - 50GB disk space
   - Enable 4+ CPU cores

3. **Follow Linux instructions above**

## Using Cloud Services

### AWS EC2

```bash
# Launch Ubuntu 22.04 LTS instance
# t3.large or larger (2+ GB RAM)
# Storage: 50GB EBS

# Connect via SSH
ssh -i key.pem ubuntu@instance-ip

# Install dependencies
sudo apt-get update
sudo apt-get install -y \
    wget curl xorriso grub-pc-bin grub-efi-amd64-bin \
    debootstrap squashfs-tools dosfstools mtools \
    build-essential git pv

# Copy project
scp -i key.pem -r OS\ Distor ubuntu@instance-ip:~/

# SSH in and build
ssh -i key.pem ubuntu@instance-ip
cd OS\ Distor
sudo ./build-scripts/build-tails-distro.sh

# Download ISO
scp -i key.pem ubuntu@instance-ip:~/OS\ Distor/iso/*.iso ./
```

### DigitalOcean Droplets

```bash
# Create droplet: Ubuntu 22.04, 2GB RAM, 50GB storage

# SSH in
ssh root@your-droplet-ip

# Install dependencies (same as above)

# Follow Linux build process
```

### Google Cloud / Azure

Similar process - create Ubuntu 22.04 VM with adequate resources.

## Using Cross-Platform Tools

### Vagrant

```bash
# Install Vagrant
# https://www.vagrantup.com/downloads

# Create Vagrant file
cat > Vagrantfile <<EOF
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.provider "virtualbox" do |v|
    v.memory = 8192
    v.cpus = 4
  end
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y xorriso grub-pc-bin grub-efi-amd64-bin \
      debootstrap squashfs-tools dosfstools mtools \
      build-essential git pv curl wget
  SHELL
end
EOF

# Start and build
vagrant up
vagrant ssh
cd /vagrant/OS\ Distor
sudo ./build-scripts/build-tails-distro.sh
```

## Building on Remote Server

### General Steps

1. **Connect to server**
   ```bash
   ssh user@server.com
   ```

2. **Upload project**
   ```bash
   scp -r OS\ Distor user@server.com:~/
   ```

3. **Install dependencies**
   ```bash
   ssh user@server.com
   sudo apt-get install -y [dependencies from above]
   ```

4. **Build**
   ```bash
   cd OS\ Distor
   sudo ./build-scripts/build-tails-distro.sh
   ```

5. **Download result**
   ```bash
   # On local machine
   scp user@server.com:~/OS\ Distor/iso/*.iso ./
   ```

## Minimum System Requirements

### CPU
- x86-64 processor
- 2+ cores recommended
- Modern CPU preferred (faster build)

### RAM
- **Minimum**: 2GB
- **Recommended**: 4GB
- **Optimal**: 8GB+

### Storage
- **Temporary**: 8GB for build
- **Final**: 4GB for ISO + persistence
- **Total needed**: 15GB free space

### Network
- Consistent internet connection
- ~2GB download
- No bandwidth throttling

## Troubleshooting Setup

### "Command not found"

```bash
# Install missing tool
sudo apt-get install packagename

# Update paths
export PATH="/usr/local/bin:$PATH"
```

### "Permission denied"

```bash
# Make scripts executable
chmod +x script.sh

# Run with sudo if needed
sudo ./script.sh
```

### "Out of space"

```bash
# Check space
df -h

# Clean up
sudo apt-get clean
sudo apt-get autoclean
rm -rf /tmp/tails-build-*
```

### WSL specific issues

```bash
# Fix slow performance
# Edit .wslconfig
code $USERPROFILE\.wslconfig

[wsl2]
memory=8GB
processors=4
swap=4GB
```

## System Comparison

| System | Speed | Ease | Notes |
|--------|-------|------|-------|
| Native Linux | ★★★★★ | ★★★★★ | Best option |
| WSL2 | ★★★★☆ | ★★★★☆ | Good for Windows |
| Virtual Machine | ★★★☆☆ | ★★★☆☆ | Requires setup |
| Cloud Service | ★★★☆☆ | ★★☆☆☆ | Pay per use |
| Docker | ★★★★☆ | ★★★☆☆ | Portable |

## Next Steps

1. Choose your platform from above
2. Complete the setup for that platform
3. Return to `QUICKSTART.md` for build instructions
4. Or read `BUILDING.md` for detailed guide

## Environment Variables (Optional)

```bash
# Set faster mirror (replace with local mirror)
export DEBIAN_MIRROR="http://deb.debian.org/debian/"

# Set build directory
export BUILD_DIR="/mnt/external/tails-build"

# Set output directory
export OUTPUT_DIR="./iso"

# Set temporary directory
export TMPDIR="/mnt/large/tmp"
```

## Getting Help

- Check platform-specific documentation
- See `TROUBLESHOOTING.md` for build issues
- Visit appropriate Linux distro documentation
- Check cloud provider documentation for cloud setups

## Summary

- **Best**: Native Linux on x86-64 machine
- **Good**: WSL2 on Windows, VM on Mac
- **Acceptable**: Cloud services, Docker
- **All need**: 8GB+ disk, good internet, 30-45 minutes

Choose the option that works best for your situation and follow the corresponding instructions above.
