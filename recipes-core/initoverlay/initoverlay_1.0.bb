# Copyright (C) 2015-2018 Jens Rehsack <sno@netbsd.org>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Initscipts for overlay filesystems"
OPN := "${PN}"
PN = "${OPN}-${WANTED_ROOT_DEV}"
FILESEXTRAPATHS_prepend := "${THISDIR}/${OPN}:"

LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

DEPENDS += "${@bb.utils.contains("VIRTUAL-RUNTIME_initscripts", "initscripts", "update-rc.d-native", "", d)}"
RDEPENDS_${PN} += "attr"

inherit rootdev-check

CONFLICT_ROOT_DEVS = "nfs"

SRC_URI = "file://mountoverlay.sh \
	file://cleanoverlay.sh \
	file://migrate2overlay.sh \
	file://default-cleanoverlay.conf \
	file://umountoverlay.sh \
"

do_compile () {
	sed -i	-e "s/@ROOT_DEV_NAME[@]/${ROOT_DEV_NAME}/g" -e "s/@ROOT_DEV_SEP[@]/${ROOT_DEV_SEP}/g" \
		-e "s/@ROOT_DEV_TYPE[@]/${ROOT_DEV_TYPE}/g" \
		${WORKDIR}/mountoverlay.sh ${WORKDIR}/cleanoverlay.sh ${WORKDIR}/migrate2overlay.sh ${WORKDIR}/umountoverlay.sh
}

do_install () {
	if test "${VIRTUAL-RUNTIME_initscripts}" = "initscripts"
	then
		install -d ${D}${sysconfdir}/default
		install -m 0644 ${WORKDIR}/default-cleanoverlay.conf ${D}${sysconfdir}/default/cleanoverlay.conf

		install -d ${D}${sysconfdir}/init.d
		install -m 0755 ${WORKDIR}/mountoverlay.sh ${D}${sysconfdir}/init.d
		install -m 0755 ${WORKDIR}/umountoverlay.sh ${D}${sysconfdir}/init.d
		install -m 0755 ${WORKDIR}/cleanoverlay.sh ${D}${sysconfdir}/init.d
		install -m 0755 ${WORKDIR}/migrate2overlay.sh ${D}${sysconfdir}/init.d

		update-rc.d -r ${D} umountoverlay.sh start 30 0 1 6 .
		# cleanoverlay is called at beginnof mountoverlay
		update-rc.d -r ${D} mountoverlay.sh start 16 2 3 4 5 S .
	fi
}
