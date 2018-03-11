# Copyright (C) 2015 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Extended mount.blacklist for WANTED_ROOT_DEV"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
PR = "r0"
OPN := "${PN}"
PN = "${OPN}-${WANTED_ROOT_DEV}"

DEPENDS = "udev-extraconf"
RDEPENDS_${PN} = "udev-extraconf"

def avail_root_dev_names(d):
    root_dev_names = []
    avail_root_devs = (d.getVar('AVAIL_ROOT_DEVS', True) or "").split()
    for a in avail_root_devs:
        a_nm = d.getVar('ROOT_DEV_NAME-' + a, True)
        a_sep = (d.getVar('ROOT_DEV_SEP-' + a, True) or "")
        root_dev_names.append(a_nm + a_sep)
    return " ".join(root_dev_names)

BLACKLIST_D_DIR = "${sysconfdir}/udev/mount.blacklist.d"

do_install() {
    set -x
    install -d ${D}${BLACKLIST_D_DIR}
    if [ "${WANTED_ROOT_DEV}" = "nfs" ]
    then
        rm -f ${D}${BLACKLIST_D_DIR}/avail
        for d in ${@avail_root_dev_names(d)}
        do
            echo "/dev/${d}*" >> ${D}${BLACKLIST_D_DIR}/avail
        done
    else
        echo "/dev/${ROOT_DEV_NAME}${ROOT_DEV_SEP}*" > ${D}${BLACKLIST_D_DIR}/${WANTED_ROOT_DEV}
        if test "${WANTED_ROOT_DEV}" != "${INTERNAL_ROOT_DEV}";
        then
            echo "/dev/${ROOT_DEV_NAME-${INTERNAL_ROOT_DEV}}${ROOT_DEV_SEP-${INTERNAL_ROOT_DEV}}*" > ${D}${BLACKLIST_D_DIR}/${INTERNAL_ROOT_DEV}
        fi
    fi
}

FILES_${PN} = "${BLACKLIST_D_DIR}"
