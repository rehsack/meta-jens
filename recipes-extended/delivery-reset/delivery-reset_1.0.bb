# Copyright (C) 2016 Jens Rehsack <sno@netbsd.org>
# Released under the LGPLv2 license

DESCRIPTION = "Delivery Reset"
HOMEPAGE = "http://act.yapc.eu/gpw2018/index.html"
LICENSE = "LGPLv2.1"
DEPENDS:append = " update-rc.d-native"

LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/LGPL-2.1;md5=1a6d268fd218675ffea8be556788b780"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI = "\
    file://delivery-reset.common \
    file://delivery-reset.sh \
    file://delivery-reset.startup \
"

MEDIA_MNT_BASE = "/run/media/"
CLEANUP_SPEC="overlay.mrproper"

do_compile () {
    set -x

    cp ${WORKDIR}/delivery-reset.* ${B}
    sed -i -e "s,@LIBEXEC[@],${libexecdir},g" -e "s,@ROOT_DEV_NAME[@],${ROOT_DEV_NAME},g" \
        -e "s,@MEDIA_MNT_BASE[@],${MEDIA_MNT_BASE},g" -e "s,@CLEANUP_SPEC[@],${CLEANUP_SPEC},g" \
        ${B}/delivery-reset.common ${B}/delivery-reset.sh ${B}/delivery-reset.startup
}

do_install () {
    install -d ${D}${bindir}
    install -d ${D}${libexecdir}
    install -d ${D}${sysconfdir}/init.d

    install -m 0644 ${B}/delivery-reset.common ${D}${libexecdir}/delivery-reset
    install -m 0755 ${B}/delivery-reset.sh ${D}${bindir}/delivery-reset
    install -m 0755 ${B}/delivery-reset.startup ${D}${sysconfdir}/init.d/delivery-reset.sh

    update-rc.d -r ${D} delivery-reset.sh start 14 S .
}
