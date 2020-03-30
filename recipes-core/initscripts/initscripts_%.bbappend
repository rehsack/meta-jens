FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = "\
	file://volatiles.nfs \
"

PACKAGE_ARCH = "${MACHINE_ARCH}"

do_install_append () {
	mv ${D}${sysconfdir}/rcS.d/S02sysfs.sh ${D}${sysconfdir}/rcS.d/S01sysfs.sh
	test "${WANTED_ROOT_DEV}" = "nfs" && \
		install -m 0644    ${WORKDIR}/volatiles.nfs	${D}${sysconfdir}/default/volatiles/00_core
	:
}

# XXX be aware when doing an update of bohr-update stick - then checkroot should be part there ...
do_install[postfuncs] = "tidy_install"

tidy_install () {
    rm ${D}${sysconfdir}/rcS.d/S06checkroot.sh
}
