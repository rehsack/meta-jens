DESCRIPTION = "This runs fsck(8) for r/w fs at boot"
HOMEPAGE = "http://www.rademacher.de"

LICENSE = "GPL-2.0+"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "file://boot-fsck.sh"

inherit update-rc.d

do_install () {
	#create init.d directory
	install -d ${D}${sysconfdir}/init.d/
	
	#install init.d script and make it executable
	install -m 0755 ${WORKDIR}/boot-fsck.sh ${D}${sysconfdir}/init.d/boot-fsck
}

INITSCRIPT_NAME = "boot-fsck"
INITSCRIPT_PARAMS = "start 02 S ."
