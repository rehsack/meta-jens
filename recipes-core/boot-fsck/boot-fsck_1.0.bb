DESCRIPTION = "This runs fsck(8) for r/w fs at boot"
HOMEPAGE = "http://www.rademacher.de"

LICENSE = "GPL-2.0+"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "\
    file://boot-fsck.sh \
"

DEPENDS += " update-rc.d-native"

do_install () {
    #create init.d directory
    install -d ${D}${sysconfdir}/init.d/
    
    #install init.d script and make it executable
    install -m 0755 ${WORKDIR}/boot-fsck.sh ${D}${sysconfdir}/init.d/boot-fsck
    update-rc.d -r ${D} boot-fsck start 02 S .
}
