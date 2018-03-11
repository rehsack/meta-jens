FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PACKAGE_ARCH = "${MACHINE_ARCH}"

do_install_append () {
    mv ${D}${sysconfdir}/rcS.d/S02sysfs.sh ${D}${sysconfdir}/rcS.d/S01sysfs.sh
}

# XXX be aware when doing an update of bohr-update stick - then checkroot should be part there ...
do_install[postfuncs] = "tidy_install"

tidy_install () {
    rm ${D}${sysconfdir}/rcS.d/S06checkroot.sh
}
