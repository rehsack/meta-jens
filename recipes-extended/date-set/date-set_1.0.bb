DESCRIPTION = "Set date on startup"

LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "file://date-set.sh"

inherit update-rc.d

ALTERNATIVE_PRIORITY = "100"
ALTERNATIVE_LINK_NAME[date_set] = "${D}${sysconfdir}/init.d/date-set"

do_install () {
	#create init.d directory
	install -d ${D}${sysconfdir}/init.d/

	#install init.d script and make it executable
	install -m 0755 ${WORKDIR}/date-set.sh ${D}${sysconfdir}/init.d/date-set
}

INITSCRIPT_NAME = "date-set"
INITSCRIPT_PARAMS = "start 02 S ."
