FILESEXTRAPATHS_prepend := "${THISDIR}/logrotate:"

SRC_URI += "file://logrotate.conf"
SRC_URI += "file://clean-logrotate.cron"

do_install_append () {
	install -m 644 ${WORKDIR}/logrotate.conf ${D}${sysconfdir}/logrotate.conf
	install -m 755 ${WORKDIR}/clean-logrotate.cron ${D}${sysconfdir}/cron.daily/clean-logrotate
}
