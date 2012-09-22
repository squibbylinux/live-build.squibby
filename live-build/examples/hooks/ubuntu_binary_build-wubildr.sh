#! /bin/sh
set -e

# This is a hook for live-build(7) to build the wubildr bootloader for Wubi
# To enable it, copy or symlink this hook into your config/binary_local-hooks
# directory.

CHROOT="$(mktemp -d)"
# grub-mkimage needs to be able to find the source file of the loopback image
# in the location that losetup knows it is; however, in a chroot this file wont
# be present, so we need to make it so by the magic of bind mounts:
mkdir -p "ubuntu/disks"
# FIXME: swap these next two lines around when the buildds can handle ext4:
# mv "binary/boot/filesystem.ext4" "ubuntu/disks/root.disk"
mv "binary/boot/filesystem.ext3" "ubuntu/disks/root.disk"
mount -o loop "ubuntu/disks/root.disk" "$CHROOT"
# Save the directory structure mkdir created, so that it can be removed later.
REMOVE="$(mkdir -pv "$CHROOT$PWD" | head -n1 | sed "s,.*\`\(.*\)',\1,")"
mount -o bind "$PWD" "$CHROOT$PWD"
chroot "$CHROOT" mount -t proc proc /proc
# Expected to already exist.
touch wubildr
# grub-install cries unless you point it at something.
chroot "$CHROOT" grub-install /dev/null
umount "$CHROOT/proc"
umount "$CHROOT$PWD"
rm -rf "$REMOVE"
# /host is normally created by partman-auto-loop.
mkdir "$CHROOT/host"
umount "$CHROOT"
mv wubildr binary/boot
# Link output files somewhere BuildLiveCD will be able to find them.
PREFIX="livecd.$PROJECT${SUBARCH:+-$SUBARCH}"
mv ubuntu/disks/root.disk binary/boot/root.disk
rmdir -p ubuntu/disks
tar cf - -C binary/boot root.disk wubildr | xz -9 > "$PREFIX.tar.xz"
