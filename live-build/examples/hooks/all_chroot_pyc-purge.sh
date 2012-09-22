#!/bin/sh

# This is a hook for live-build(7) to remove byte-compiled Python modules.
# To enable it, copy or symlink this hook into your config/chroot_local-hooks
# directory.

find /usr -name \*.pyc -print0 | xargs -0r rm -f
