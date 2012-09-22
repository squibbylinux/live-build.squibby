#! /bin/sh

# This is a hook for live-build(7) to remove the GNOME icon cache for
# Kubuntu builds.
# To enable it, copy or symlink this hook into your config/chroot_local-hooks
# directory.

rm -f /usr/share/icons/*/icon-theme.cache
