#!/bin/bash

# ===== CONFIGURATION =====
# LVM Configuration
VG_NAME="vg0"
LV_ROOT="root"
LV_DATA="data"
LV_ROOT_SIZE="500G"
LUKS_NAME="luksroot"
RAID_DEVICE="/dev/md0"

# ===== HELPER FUNCTIONS =====
# Mount boot partitions across all NVMe drives
function mountBootPartitions() {
  for i in {0..3}; do
    mkdir -p /mnt/boot$((i + 1))
    mount /dev/nvme"$i"n1p1 /mnt/boot$((i + 1))
  done
}

# Format boot partitions across all NVMe drives
function formatBootPartitions() {
  for i in {0..3}; do
    wipefs --all --force /dev/nvme"$i"n1p1
    mkfs.fat -F 32 /dev/nvme"$i"n1p1
  done
}

# ===== MAIN FUNCTIONS =====
# Stops active drive configurations without erasing data
function stopActiveDriveConfigs() {
  echo "Stopping active drive configurations..."

  # Unmount any mounted partitions
  lsblk | grep '/mnt' | awk '{print $7}' | while read -r partition; do
    echo "Unmounting $partition..."
    umount "$partition" || echo "Failed to unmount $partition"
  done

  # Remove volume mappings
  ls -r /dev/mapper | grep -e "$VG_NAME" -e "$LUKS_NAME" | while read -r volume; do
    echo "Removing $volume"
    dmsetup remove -f "$volume"
  done

  # Stop RAID arrays
  umount -lf /dev/md{0..127} >/dev/null 2>&1
  mdadm --stop /dev/md{0..127} >/dev/null 2>&1
  mdadm --remove /dev/md{0..127} >/dev/null 2>&1
}

# Full destructive wipe of all disk configurations
function eraseAllDiskConfig() {
  echo "Erasing all disk configurations..."

  for drive in /dev/nvme{0..3}n1; do
    echo "Wiping $drive..."
    wipefs --all --force "$drive"
    blkdiscard "$drive" -f
    partprobe "$drive"
  done
}

# Partial destructive wipe that preserves data volumes
function erasePartial() {
  echo "Performing partial erase (OS and boot only)..."

  # Assemble RAID array
  mdadm --assemble --scan

  # Open LUKS container
  cryptsetup open \
    --allow-discards \
    "$RAID_DEVICE" "$LUKS_NAME"

  # Activate volume groups
  pvscan
  vgscan
  vgchange -ay

  # Format and mount root volume
  wipefs --all --force /dev/"$VG_NAME"/"$LV_ROOT"
  mkfs.ext4 -F /dev/"$VG_NAME"/"$LV_ROOT"
  mount /dev/"$VG_NAME"/"$LV_ROOT" /mnt

  # Format and mount boot partitions
  formatBootPartitions
  mountBootPartitions
}

# Create partitions, RAID, LUKS, and LVM from scratch
function createPartitionsFromEmpty() {
  echo "Creating new partition scheme..."

  # Create boot and data partitions on each drive
  for drive in /dev/nvme{0..3}n1; do
    parted -s "$drive" mklabel gpt
    parted -s "$drive" mkpart EFI fat32 1MiB 2049MiB
    parted -s "$drive" set 1 boot on
    parted -s "$drive" mkpart primary 2049MiB 100%
    mkfs.fat -F 32 "$drive"p1
  done

  # Create RAID array
  echo "Creating RAID array..."
  mdadm --create --verbose "$RAID_DEVICE" \
    --metadata=1.0 \
    --level=10 \
    --raid-devices=4 \
    /dev/nvme{0..3}n1p2

  # Wait for RAID initialization
  while [ "$(cat /proc/mdstat | grep -c "resync = ")" -eq 0 ]; do
    echo "Waiting for RAID array to initialize..."
    sleep 3
  done

  lsblk
  cat /proc/mdstat

  # Create and open LUKS container
  echo "Setting up encryption..."
  cryptsetup luksFormat \
    --type luks2 \
    --cipher aes-xts-plain64 \
    --key-size 512 \
    --hash sha256 \
    --batch-mode \
    "$RAID_DEVICE"

  cryptsetup open \
    --allow-discards \
    "$RAID_DEVICE" "$LUKS_NAME"

  # Set up LVM
  echo "Setting up LVM volumes..."
  partprobe /dev/mapper/"$LUKS_NAME"
  pvcreate /dev/mapper/"$LUKS_NAME"
  vgcreate "$VG_NAME" /dev/mapper/"$LUKS_NAME"
  lvcreate -L "$LV_ROOT_SIZE" -n "$LV_ROOT" "$VG_NAME"
  lvcreate -l 100%FREE -n "$LV_DATA" "$VG_NAME"

  # Format and mount volumes
  mkfs.ext4 /dev/"$VG_NAME"/"$LV_ROOT"
  mkfs.ext4 /dev/"$VG_NAME"/"$LV_DATA"

  mkdir -p /mnt
  mount /dev/"$VG_NAME"/"$LV_ROOT" /mnt

  # Mount boot partitions
  mountBootPartitions

  # Show mount information
  df -h | grep /mnt
}

# Install NixOS to the prepared partitions
function installNixOS() {
  echo "Installing NixOS..."

  # Get RAID array UUID for hardware configuration
  ARRAY_UUID_NVME_R10=$(mdadm --detail --scan "$RAID_DEVICE" | grep -o 'UUID=[^ ]*' | cut -d= -f2)
  sed -i "s/\(ARRAY_UUID_NVME_R10\s*=\s*\).*/\1\"$ARRAY_UUID_NVME_R10\";/" ../hardware.nix

  # Copy NixOS configuration
  mkdir -p /mnt/etc/nixos
  cp -ra ../../../* /mnt/etc/nixos/

  # Install and configure
  echo "Running nixos-install..."
  nixos-install --root /mnt --no-root-passwd --flake /mnt/etc/nixos#coeus

  echo "Setting user password..."
  nixos-enter --root /mnt -c 'passwd smissingham'

  echo "Installation completed. Please reboot your system to start NixOS."
}

# ===== MAIN MENU =====
while true; do
  clear
  echo "===== Installation Menu ====="
  echo "1. Keep Persistent Data Volume, Erase OS and Boot & Reinstall"
  echo "2. Erase All Existing Disk Configurations, Then Reinstall"
  echo "3. Just Erase All Disk Configs, No Reinstall"
  echo "4. Exit"
  echo "5. Reboot"
  echo "==================================="
  read -rp "Select an option [1-5]: " choice

  case $choice in
  1)
    stopActiveDriveConfigs
    erasePartial
    installNixOS
    read -rp "Press enter to return to menu..."
    ;;
  2)
    stopActiveDriveConfigs
    eraseAllDiskConfig
    createPartitionsFromEmpty
    installNixOS
    read -rp "Press enter to return to menu..."
    ;;
  3)
    stopActiveDriveConfigs
    eraseAllDiskConfig
    read -rp "Press enter to return to menu..."
    ;;
  4)
    echo "Exiting..."
    break
    ;;
  5)
    echo "Rebooting..."
    sudo reboot
    ;;
  *)
    echo "Invalid option. Please choose 1-5."
    sleep 2
    ;;
  esac
done
