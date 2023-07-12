FILESEXTRAPATHS:prepend := "${THISDIR}/sysvinit:"

SRC_URI:append = "\
    file://longer-history-in-boot-log.patch;striplevel=0 \
"

do_install:append () {
    mv ${D}${sysconfdir}/rcS.d/S07bootlogd ${D}${sysconfdir}/rcS.d/S04bootlogd
}
