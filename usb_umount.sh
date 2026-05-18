#!/bin/bash

# Ensure a target was provided
if [ -z "$1" ]; then
    echo "Usage: $(basename "$0") <mount_point_or_device>"
    echo "Example: $(basename "$0") /media/backup  OR  $(basename "$0") /dev/sdb1"
    exit 1
fi

TARGET="$1"
DEV_PART=""

# 1. Resolve target to a block device if a mount point/directory was passed
if [ -d "$TARGET" ] || ! [[ "$TARGET" =~ ^/dev/ ]]; then
    DEV_PART=$(findmnt -no SOURCE "$TARGET")
    if [ -z "$DEV_PART" ]; then
        echo "❌ Error: Could not find a mounted device at '$TARGET'"
        exit 1
    fi
else
    DEV_PART="$TARGET"
fi

# Verify it's actually a valid block device
if [ ! -b "$DEV_PART" ]; then
    echo "❌ Error: '$DEV_PART' is not a valid block device."
    exit 1
fi

# 2. Find the parent disk (e.g., extract 'sdb' from 'sdb1')
PARENT_DISK=$(lsblk -no pkname "$DEV_PART")

if [ -z "$PARENT_DISK" ]; then
    PARENT_DEV="$DEV_PART"  # It's already the parent disk
    else
    PARENT_DEV="/dev/$PARENT_DISK"
fi

# 3. Execute the safe shutdown sequence
echo "💾 1. Flushing caches (sync)..."
sync

echo "🔓 2. Unmounting partition ($DEV_PART)..."
if udisksctl unmount -b "$DEV_PART"; then
    echo "🔌 3. Powering down hardware ($PARENT_DEV)..."
    # Sleep for a brief moment to ensure the unmount event settles
    sleep 1
    if udisksctl power-off -b "$PARENT_DEV"; then
        echo "✅ Success! The drive cache is clear and power is cut. Safe to unplug."
    else
        echo "⚠️ Unmounted successfully, but failed to power off the hardware link."
    fi
else
    echo "❌ Error: Failed to unmount $DEV_PART. Power-off aborted to prevent data loss."
    exit 1
fi