FILESEXTRAPATHS_prepend := "${THISDIR}/sysvinit:"

SRC_URI_append = "\
    file://longer-history-in-boot-log.patch;striplevel=0 \
"

do_install_append () {
    mv ${D}${sysconfdir}/rcS.d/S07bootlogd ${D}${sysconfdir}/rcS.d/S04bootlogd
}
