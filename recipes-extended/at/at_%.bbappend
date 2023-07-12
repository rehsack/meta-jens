FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://at.volatiles"

do_install:append () {
	install -d ${D}${sysconfdir}/default/volatiles

	install -m 644 ${WORKDIR}/at.volatiles ${D}${sysconfdir}/default/volatiles/97_at
}
