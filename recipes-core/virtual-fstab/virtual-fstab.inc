# Copyright (C) 2015 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Dedicate, MACHINE dependend provider for fstab by WANTED_ROOT_DEV"

LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

PACKAGE_ARCH = "${MACHINE_ARCH}"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

DEV_PFX="${ROOT_DEV_NAME}${ROOT_DEV_SEP}"

do_compile () {
    set -x
    cp ${WORKDIR}/fstab ${B}/fstab.${WANTED_ROOT_DEV}
    sed -i -e "s,@DEV_PFX@,${DEV_PFX},g" \
         -e "s,@overlay@,${OVERLAY},g" -e "s,@overlayfs@,${OVERLAYFS},g" -e "s,@unionfs@,${UNIONFS},g" \
        ${B}/fstab.${WANTED_ROOT_DEV}
    test "${MACHINE}" = "bohr" -a "${WANTED_ROOT_DEV}" = "nand" && sed -i -e "s,ext[24],ubifs,g" \
        ${B}/fstab.${WANTED_ROOT_DEV}
    :
}

do_install () {
    mkdir -p ${D}${sysconfdir}
    install -m 0644 ${B}/fstab.${WANTED_ROOT_DEV} ${D}${sysconfdir}/fstab
}
