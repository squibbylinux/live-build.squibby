#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Restore_cache ()
{
	DIRECTORY="${1}"

	if [ "${LB_CACHE}" = "true" ] && [ "${LB_CACHE_PACKAGES}" = "true" ]
	then
		if [ -d "${DIRECTORY}" ]
		then
			# Restore old cache
			if [ "$(stat --printf %d ${DIRECTORY})" = "$(stat --printf %d chroot/var/cache/apt/archives)" ]
			then
				# with hardlinks
				cp -fl "${DIRECTORY}"/*.deb chroot/var/cache/apt/archives
			else
				# without hardlinks
				cp "${DIRECTORY}"/*.deb chroot/var/cache/apt/archives
			fi
		fi
	fi
}

Save_cache ()
{
	DIRECTORY="${1}"

	if [ "${LB_CACHE}" = "true" ] && [ "${LB_CACHE_PACKAGES}" = "true" ]
	then
		# Cleaning current cache
		Chroot chroot "apt-get autoclean"

		if ls chroot/var/cache/apt/archives/*.deb > /dev/null 2>&1
		then
			# Creating cache directory
			mkdir -p "${DIRECTORY}"

			# Saving new cache
			for PACKAGE in chroot/var/cache/apt/archives/*.deb
			do
				if [ -e "${DIRECTORY}"/"$(basename ${PACKAGE})" ]
				then
					rm -f "${PACKAGE}"
				else
					mv "${PACKAGE}" "${DIRECTORY}"
				fi
			done
		fi
	else
		# Purging current cache
		rm -f chroot/var/cache/apt/archives/*.deb
	fi
}
