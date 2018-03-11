FILESEXTRAPATHS_prepend := "${THISDIR}/base-files:"

hostname := "homepilot"
volatiles := ""

DEPENDS_append = "virtual-fstab-${WANTED_ROOT_DEV}"
RDEPENDS_${PN}_append = "virtual-fstab-${WANTED_ROOT_DEV}"

do_compile_append () {
    mkdir -p ${S}
    echo "#!/bin/sh

/etc/init.d/urandom stop # saves seed
" > ${S}/cron-urandom-save-seed
}

do_install_append () {
    rm -f ${D}${sysconfdir}/fstab

    install -d ${D}/data
    rm -f ${D}${localstatedir}/log ${D}${localstatedir}/tmp ${D}${localstatedir}/run ${D}${localstatedir}/lock
    install -d ${D}${localstatedir}/log
    install -d ${D}${localstatedir}/tmp
    install -d ${D}${localstatedir}/run
    install -d ${D}${localstatedir}/lock

    install -d ${D}${sysconfdir}/cron.daily/
    install -m 755 ${S}/cron-urandom-save-seed ${D}${sysconfdir}/cron.daily/cron-urandom-save-seed
}
