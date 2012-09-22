#!/bin/sh

## live-build(7) - System Build Scripts
## Copyright (C) 2006-2011 Daniel Baumann <daniel@debian.org>
##
## live-build comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
## This is free software, and you are welcome to redistribute it
## under certain conditions; see COPYING for details.


Losetup ()
{
	DEVICE="${1}"
	FILE="${2}"
	PARTITION="${3:-1}"

	${LB_ROOT_COMMAND} ${LB_LOSETUP} "${DEVICE}" "${FILE}"
	FDISK_OUT="$(${LB_FDISK} -l -u ${DEVICE} 2>&1)"
	${LB_ROOT_COMMAND} ${LB_LOSETUP} -d "${DEVICE}"

	LOOPDEVICE="$(echo ${DEVICE}p${PARTITION})"

	if [ "${PARTITION}" = "0" ]
	then
		Echo_message "Mounting %s with offset 0" "${DEVICE}"

		${LB_ROOT_COMMAND} ${LB_LOSETUP} "${DEVICE}" "${FILE}"
	else
		SECTORS="$(echo "$FDISK_OUT" | sed -ne "s|^$LOOPDEVICE[ *]*\([0-9]*\).*|\1|p")"
		OFFSET="$(expr ${SECTORS} '*' 512)"

		Echo_message "Mounting %s with offset %s" "${DEVICE}" "${OFFSET}"

		${LB_ROOT_COMMAND} ${LB_LOSETUP} -o "${OFFSET}" "${DEVICE}" "${FILE}"
	fi
}

Calculate_partition_size ()
{
	ORIGINAL_SIZE="${1}"
	FILESYSTEM="${2}"

	case "${FILESYSTEM}" in
		ext2|ext3)
			PERCENT="5"
			;;
		*)
			PERCENT="3"
			;;
	esac

	echo $(expr ${ORIGINAL_SIZE} + ${ORIGINAL_SIZE} \* ${PERCENT} / 100 + 1)
}
