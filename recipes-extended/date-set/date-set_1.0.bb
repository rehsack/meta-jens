DESCRIPTION = "Set date on startup"

LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "file://date-set.sh"

DEPENDS += " update-rc.d-native"

ALTERNATIVE_PRIORITY = "100"
ALTERNATIVE_LINK_NAME[date_set] = "${D}${sysconfdir}/init.d/date-set"

do_install () {
    #create init.d directory
    install -d ${D}${sysconfdir}/init.d/

    #install init.d script and make it executable
    install -m 0755 ${WORKDIR}/date-set.sh ${D}${sysconfdir}/init.d/date-set
    update-rc.d -r ${D} date-set start 02 S .
}
