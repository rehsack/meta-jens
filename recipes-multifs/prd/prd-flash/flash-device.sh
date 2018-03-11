#!/bin/sh
### BEGIN INIT INFO
# Provides:             flash-production
# Required-Start:       $local_fs
# Required-Stop:      $local_fs
# Default-Start:
# Default-Stop:
# Short-Description:  Flash internal/external sd-card
### END INIT INFO

set -x

logger -s "Prove being the one and only ..."
test "${FLOCKER}" != "@ARGV0@" && exec env FLOCKER="@ARGV0@" flock -en "@ARGV0@" "@ARGV0@" || :
logger -s "Starting flash ..."

# use last image container
for c in /data/.flashimg/*-complete.cpi /data/flashimg/*-complete
do
    if [ -f "${c}" -o -d "${c}" ]
    then
	IMAGE_CONTAINER="${c}"

	break
    fi
done

test -z "${IMAGE_CONTAINER}" && exit 0

. @LIBEXEC@/hw
. @LIBEXEC@/init
test -f @LIBEXEC@/post && . @LIBEXEC@/post

for tmp in /var/tmp /data/tmp /tmp
do
    touch ${tmp}/$$ && rm ${tmp}/$$ && TEMP_DIR=${tmp} && break
done

cd ${TEMP_DIR}/

if [ -d "${IMAGE_CONTAINER}" ]
then
    . "${IMAGE_CONTAINER}"/.settings
    . @LIBEXEC@/algorithms

    prove_image

    DEV_FOUND=0

    for w in ${AVAIL_ROOT_DEVS}
    do
	devnm="ROOT_DEV_NAME_${w}"
	dev=$(eval echo /dev/\$${devnm})
	if test -e $dev
	then
	    test ${DEV_FOUND} -eq 1 && continue
	    if [ "${WANTED_ROOT_DEV}" != "$w" ]
	    then
		logger -s "Cannot flash incompatible image ($dev but no $w image)"
		trigger_error
	    fi
	    DEV_FOUND=1
	fi
    done

    DEVICE_PATH="/dev/${ROOT_DEV_NAME}"
    DEVICE_PREFIX="/dev/${ROOT_DEV_NAME}${ROOT_DEV_SEP}"

    ETH0_ADDR=`cat /sys/class/net/eth0/address | sed -e 's/://g'`
    BOOT_MNT=${TEMP_DIR}/flashimg/root/boot/${ETH0_ADDR}
    DATA_MNT=${TEMP_DIR}/flashimg/root/data/${ETH0_ADDR}
    mkdir -p ${BOOT_MNT} ${DATA_MNT}

    . @LIBEXEC@/init.${ROOT_DEV_TYPE}

    trigger_root
    trigger_recover

    prepare_device

    if require_update_uboot
    then
        flash_uboot
        uboot_setenv
    fi
    flash_rootfs
    flash_recoveryfs

    (cd "${IMAGE_CONTAINER}" && tar cf - ${KERNEL}) | (cd ${BOOT_MNT} && tar xf - && chown -R root:root . && eval ${KERNEL_PREPARE} && eval ${KERNEL_SANITIZE})

    mkdir -p ${DATA_MNT}/tmp
    chmod 01777 ${DATA_MNT}/tmp
    (cd ${DATA_MNT} && mkdir -p ${UNION_SHADOWS})

    declare -f post_flash >/dev/null && post_flash

    sync

    umount ${BOOT_MNT}
    umount ${DATA_MNT}

    sync

    silence_recover
    silence_root

    test "@INTERNAL_ROOT_DEV@" = "${WANTED_ROOT_DEV}" && @FINALIZE_FLASH@
elif [ -f "${IMAGE_CONTAINER}" ]
then
    tar xjf "${IMAGE_CONTAINER}" .settings
    . ./.settings
    rm -f .settings

    if [ "${MACHINE}" != "`echo @MACHINE@ | sed -e 's/-*//'`" ]
    then
	logger -s "Cannot perform an update for ${MACHINE}."
	trigger_error
    fi

    if [ "$WANTED_ROOT_DEV" != "@WANTED_ROOT_DEV@" ]
    then
	logger -s "Cannot write to ${WANTED_ROOT_DEV}, flashing limited to @WANTED_ROOT_DEV@."
	trigger_error
    fi

    . @LIBEXEC@/init.@ROOT_DEV_TYPE@

    DEVICE_PATH="/dev/${ROOT_DEV_NAME}"
    DEVICE_PREFIX="/dev/${ROOT_DEV_NAME}${ROOT_DEV_SEP}"
    ROOTDEV=`mount | grep "on / type" | sed -e 's/ on.*//'`

    if [ $(echo ${ROOTDEV} | egrep "${ROOT_DEV_SEP}2\$") ]
    then
	REGULAR=Y
	logger "Updating phase 1"

	trigger_recover

	update_fs

	logger "Going to extract recovery image"
	wipe_recoveryfs
	tar xjf "${IMAGE_CONTAINER}" -O ${RECOVERIMG} | update_recoveryfs

	mount /boot

	logger "Going to extract kernel"
	(cd /boot && tar xjf "${IMAGE_CONTAINER}" ${KERNEL} && chown -R root:root . && eval ${KERNEL_PREPARE})

	if require_update_uboot
	then
	    logger "Going to extract u-boot"
	    tar xjf "${IMAGE_CONTAINER}" -O ${UBOOT_BIN} | update_uboot
	    uboot_setenv
	else
	    logger "u-boot is fine, remains untouched"
	fi

	logger "Force rebuild of volatiles.cache next boot"
        rm -f /etc/volatile.cache

	logger "Requesting reboot"
	reboot
    elif [ $(echo ${ROOTDEV} | egrep "${ROOT_DEV_SEP}3\$") ]
    then
	RECOVERY=Y
	logger "Updating phase 2"

	trigger_root

	logger "Going to extract rootfs image"
	wipe_rootfs
	tar xjf "${IMAGE_CONTAINER}" -O ${ROOTIMG} | update_rootfs

	logger "Sanitize kernel"
	mount /boot
	(cd /boot && eval ${KERNEL_SANITIZE})
	(cd /data && mkdir -p ${UNION_SHADOWS})

	touch /etc/overlay.mrproper

	logger "Going to cleanup relics"
	if [ -d  /data/.shadow/.var_lib ]
	then
	    test -d /data/.var/lib || mkdir -p /data/.var/lib
		# XXX remove unionfs files
	    (cd /data/.shadow/.var_lib && tar cf - nginx dropbear) | (cd /data/.var/lib && tar xf -)
	    test -d  /data/.shadow/.var_lib && echo "/data/.shadow/.var_lib" >> /etc/overlay.mrproper
	fi

	logger "Cleanup deprecated set-update-channel scripts"
	test -d /data/.shadow/.etc/init.d/ && echo "/data/.shadow/.etc/init.d/" >> /etc/overlay.mrproper
	test -d /data/.shadow/.etc/rc5.d/ && echo "/data/.shadow/.etc/rc5.d/" >> /etc/overlay.mrproper

	logger "Cleanup thermaldetails data"
	test -d /data/thermaldetails && rm -rf "/data/thermaldetails"

	logger "Cleanup collectd data"
	test -d /var/lib/collectd && rm -rf "/var/lib/collectd"

	logger "Cleanup services"
	test -d /data/.shadow/.etc/daemontools/service && echo "/data/.shadow/.etc/daemontools/service" >> /etc/overlay.mrproper
	test -f /data/.shadow/.etc/sysimg_update.json && echo "/data/.shadow/.etc/sysimg_update.json" >> /etc/overlay.mrproper

	logger "Cleanup deprecated xbmc folder"
	test -d /data/.shadow/.home/xbmc/.xbmc && echo "/data/.shadow/.home/xbmc/.xbmc" >> /etc/overlay.mrproper

	if [ -f /data/.shadow/.etc/modules-load.d/wifi.conf ]
	then
		logger "Migrate wireless configuration"
		grep -q "^8189es$" /data/.shadow/.etc/modules-load.d/wifi.conf && touch /etc/wpa_supplicant.enabled

		logger "Cleanup modules-load.d"
		echo "/data/.shadow/.etc/modules-load.d/wifi.conf" >> /etc/overlay.mrproper
	fi

	if [ -f /data/.shadow/.etc/wpa_supplicant.conf ]
	then
		logger -s "Trying to merge /etc/wpa_supplicant.conf"
		mkdir -p /run/media/${ROOT_DEV_NAME}${ROOT_DEV_SEP}3
		mount -o bind / /run/media/${ROOT_DEV_NAME}${ROOT_DEV_SEP}3
		cp /run/media/${ROOT_DEV_NAME}${ROOT_DEV_SEP}3/etc/wpa_supplicant.conf /data/.shadow/.etc/wpa_supplicant.conf.new
		perl -le 'open(my $fh, "<", "/data/.shadow/.etc/wpa_supplicant.conf"); my $cnt; { local $/; $cnt = <$fh> }; $cnt =~ m/^(network=\{.+?^\})/ms; print $1' >> /data/.shadow/.etc/wpa_supplicant.conf.new
		test -f /etc/wpa_supplicant.conf.new && mv /etc/wpa_supplicant.conf.new /etc/wpa_supplicant.conf
		umount /run/media/${ROOT_DEV_NAME}${ROOT_DEV_SEP}3
	fi

	logger "Removing update container"
	rm -f "${IMAGE_CONTAINER}"
	logger "Force rebuild of volatiles.cache next boot"
        rm -f /etc/volatile.cache

	logger "Requesting reboot"
	reboot
    else
	rm -f .settings
	logger -s "Cannot detect normal mode nor recovery mode. Fix and retry."
	trigger_error
    fi
fi
