FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append = "\
    file://nginx-logrotate.conf \
    file://nginx-varlib.volatiles \
"

do_install_append () {
	install -d ${D}${localstatedir}/lib/nginx/
	install -d ${D}${sysconfdir}/default/volatiles
	install -m 644 ${WORKDIR}/nginx-varlib.volatiles ${D}${sysconfdir}/default/volatiles/98_nginx_varlib

	install -m 755 -d ${D}${sysconfdir}/logrotate.d
	install -m 644 ${WORKDIR}/nginx-logrotate.conf ${D}${sysconfdir}/logrotate.d/nginx
}
