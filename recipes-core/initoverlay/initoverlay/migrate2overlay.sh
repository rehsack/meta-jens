#!/bin/sh

set -x

ROOTDEV=`mount | grep "on / type" | sed -e 's/ on.*//'`
CHECK_DIRS=""
MIGRATE_DIRS=""
SPC=""

test -f /etc/fstab && (

#
#	Read through fstab line by line and mount overlay file systems
#
egrep '^(unionfs|overlay)' /etc/fstab | while read device mountpt fstype options freq passno
do
    case "$fstype" in
    unionfs)
        upperdir=`echo "$options" | sed -E 's/.*dirs=([^=]+)=rw.*/\1/g'`
        ;;
    overlayfs)
        upperdir=`echo "$options" | sed -E 's/.*upperdir=([^,]+).*/\1/g'`
        ;;
    overlay)
        upperdir=`echo "$options" | sed -E 's/.*upperdir=([^,]+).*/\1/g'`
        workdir=`echo "$options" | sed -E 's/.*workdir=([^,]+).*/\1/g'`
        ;;
    *)
        # skip
        continue
	;;
    esac

    mkdir -p "${upperdir}"
    test -n "$workdir" && mkdir -p "${workdir}"

    CHECK_DIRS="${CHECK_DIRS}${SPC}${upperdir}"
    SPC=" "
done
)

# must remain here to create above determined upperdir and workdir when cleanoverlay wiped them out
test $(echo ${ROOTDEV} | egrep '@ROOT_DEV_NAME@@ROOT_DEV_SEP@3$') && exit 0
check_md5=`echo ${CHECK_DIRS} | md5sum | awk '{print $1}'`
test -f "/var/volatile/tmp/overlay-migrated.${check_md5}" && exit 0
touch /var/volatile/tmp/overlay-migrated.${check_md5}

SPC=""

for upperdir in ${CHECK_DIRS}
do
    if [ -z "${PRIMDEV}" ]
    then
	PRIMDEV=`echo $ROOTDEV | awk -F/ '{print $3}' | sed -E 's/@ROOT_DEV_NAME@@ROOT_DEV_SEP@3$/@ROOT_DEV_NAME@@ROOT_DEV_SEP@2/g'`
	if [ ! -d /run/media ]
	then
	    mkdir -p "/run/media"
	    chmod 0755 /run/media
	fi

	if [ ! -d /run/media/${PRIMDEV} ]
	then
	    mkdir /run/media/${PRIMDEV}
	    mount -o ro /dev/${PRIMDEV} /run/media/${PRIMDEV}
	fi
    fi

    (
    egrep '^(unionfs|overlay)' /run/media/${PRIMDEV}/etc/fstab | while read pri_dev pri_mnt pri_fs pri_opt pri_freq pri_pno
    do
        case "${pri_fs}->${fstype}" in
        "unionfs->overlayfs" | "unionfs->overlay")
            pri_lower=`echo "$pri_opt" | sed -E 's/.*dirs=([^=]+)=rw.*/\1/g'`
            if [ "${pri_lower}" = "${upperdir}" ]
            then
                # yeah, we want to migrate
                MIGRATE_DIRS="${MIGRATE_DIRS}${SPC}${upperdir}"
                SPC=" "
            fi
            ;;
        esac
    done
    )
done

for upperdir in ${MIGRATE_DIRS}
do
    check_md5=`echo ${upperdir} | md5sum | awk '{print $1}'`
    test -f "/var/volatile/tmp/overlay-migrated.${check_md5}" && continue
    (
    find "$upperdir" | while read path_entry
    do
        bn=`basename "$path_entry"`
        dn=`dirname "$path_entry"`
        case "$bn" in
        .wh.__dir_opaque)
            rm -rf "${dn}/.wh.__dir_opaque"
            setfattr -n "trusted.overlay.opaque" -v "y" "${dn}"
            ;;
        .wh.*)
            opaque="n"
            if [ -d "${path_entry}" -a -e "${path_entry}/.wh.__dir_opaque" ]
            then
                opaque="y"
            fi
            rm -rf "$path_entry"
            pure_bn=`echo $bn | sed -e 's/.wh.//'`
            ln -sf "(overlay-whiteout)" "${dn}/${pure_bn}"
            setfattr -n "trusted.overlay.whiteout" -v "y" "${dn}/${pure_bn}"
            test "${opaque}" = "y" && setfattr -n "trusted.overlay.opaque" -v "y" "${dn}/${pure_bn}"
            ;;
        esac
    done
    )
    touch /var/volatile/tmp/overlay-migrated.${check_md5}
done

if [ -n "$PRIMDEV" -a -d /run/media/${PRIMDEV} ]
then
    busybox umount /run/media/${PRIMDEV}
    rmdir /run/media/${PRIMDEV}
fi

: exit 0
