#
# This is for djbware - software written by D.J.Bernstein
#

LICENSE ?= "PD"
LIC_FILES_CHKSUM ?= "file://${COMMON_LICENSE_DIR}/PD;md5=b3597d12946881e13cb3b548d1173851"

DJB_CONFIG_DIR ?= "${S}/src"
DJB_BUILD_ARGS ?= ""
# ${STAGING_DIR_NATIVE}
DJB_CONFIG_PREFIX ?= "${prefix}"
DJB_CONFIG_HOME ?= "conf-home"

S ?= "${WORKDIR}/admin/${PN}-${PV}"

djbware_do_configure () {
        cd "${DJB_CONFIG_DIR}"
        for i in conf-*; do cp ${i} ${i}.orig_dist; done;
        echo ${SYSROOT_DESTDIR}${DJB_CONFIG_PREFIX} > conf-destdir
        [ -f "${DJB_CONFIG_HOME}" ] && \
                echo "${DJB_CONFIG_PREFIX}" > ${DJB_CONFIG_HOME}
        [ -f conf-cc ] && \
                echo "${CC} ${CFLAGS} ${CPPFLAGS}" > conf-cc
        [ -f conf-ld ] && \
                echo "${CCLD} ${LDFLAGS}" > conf-ld
        [ -f conf-bin ] && \
                echo "${bindir}" > conf-bin
        [ -f conf-man ] && \
                echo "${mandir}" > conf-man
	:
}

djbware_do_compile () {
        package/compile ${DJB_BUILD_ARGS}
}

djbware_do_install () {
        install -d ${D}/${bindir}
        for i in `cat package/commands`
        do
            install -m 0755 ${S}/command/$i ${D}/${bindir}/
        done
}

EXPORT_FUNCTIONS do_configure do_compile do_install
