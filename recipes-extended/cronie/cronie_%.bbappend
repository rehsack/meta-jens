FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://cronie.volatiles"

do_install_append () {
	install -d ${D}${sysconfdir}/default/volatiles

	install -m 644 ${WORKDIR}/cronie.volatiles ${D}${sysconfdir}/default/volatiles/97_cronie
}

CONFFILES_${PN} += "${sysconfdir}/crontab"
