FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://ntp-volatile.conf \
file://ntpd \
"

do_install_append () {
	install -d ${D}${sysconfdir}/default/volatiles
	install -m 0644 ${WORKDIR}/ntp-volatile.conf ${D}${sysconfdir}/default/volatiles/99_ntp
}

FILES_${PN} += "${sysconfdir}"
