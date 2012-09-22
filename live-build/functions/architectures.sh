#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Check_architectures ()
{
	ARCHITECTURES="${@}"
	VALID="false"

	for ARCHITECTURE in ${ARCHITECTURES}
	do
		if [ "$(echo ${LB_ARCHITECTURES} | grep ${ARCHITECTURE})" ]
		then
			VALID="true"
			break
		fi
	done

	if [ "${VALID}" = "false" ]
	then
		Echo_warning "skipping %s, foreign architecture(s)." "${0}"
		exit 0
	fi
}

Check_crossarchitectures ()
{
	if [ -x /usr/bin/dpkg ]
	then
		HOST="$(dpkg --print-architecture)"
	else
		HOST="$(uname -m)"
	fi

	case "${HOST}" in
		amd64|i386|x86_64)
			CROSS="amd64 i386"
			;;

		powerpc|ppc64)
			CROSS="powerpc ppc64"
			;;

		*)
			CROSS="${HOST}"
			;;
	esac

	Check_architectures "${CROSS}"
}

Check_multiarchitectures ()
{
	if [ "$(echo ${LB_ARCHITECTURES} | wc -w)" -gt "1" ]
	then
		# First, only support multiarch on iso
		case "${LB_BINARY_IMAGES}" in
			iso*)
				# Assemble multi-arch
				case "${LB_CURRENT_ARCHITECTURE}" in
					amd64)
						DESTDIR="${DESTDIR}.amd"
						DESTDIR_LIVE="${DESTDIR_LIVE}.amd"
						DESTDIR_INSTALL="${DESTDIR_INSTALL}.amd"
						;;

					i386)
						DESTDIR="${DESTDIR}.386"
						DESTDIR_LIVE="${DESTDIR_LIVE}.386"
						DESTDIR_INSTALL="${DESTDIR_INSTALL}.386"
						;;

					powerpc)
						DESTDIR="${DESTDIR}.ppc"
						DESTDIR_LIVE="${DESTDIR_LIVE}.ppc"
						DESTDIR_INSTALL="${DESTDIR_INSTALL}.ppc"
						;;
				esac
				;;
		esac
	fi
}
