#!/opt/homebrew/bin/bash
# mount-nas-shares.sh — trigger NFS automounts so they're ready before apps launch
# The actual mounting is handled by macOS autofs (/etc/auto_nas).
# This script just accesses each mount point to wake autofs up at login.
# Managed by chezmoi.

NAS_MOUNTS=(/nas/media /nas/users)

log() { echo "$(date '+%Y-%m-%d %H:%M:%S') [nas-mount] $*"; }

for mountpoint in "${NAS_MOUNTS[@]}"; do
    if ls "$mountpoint" &>/dev/null; then
        log "$mountpoint ready"
    else
        log "WARNING: $mountpoint did not mount (NAS unreachable?)"
    fi
done
